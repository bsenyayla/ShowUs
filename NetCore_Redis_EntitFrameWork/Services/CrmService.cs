using CRCAPI.Services.Attributes;
using CRCAPI.Services.Interfaces;
using CRCAPI.Services.Settings;
using Newtonsoft.Json;
using RestSharp;
using RestSharp.Authenticators;
using SharedCRCMS.SapIntegration;
using SharedStandartLibrary.Models.SapIntegrationModels.WorkOrderDetails.Request;
using StandartLibrary.Models.Constants;
using StandartLibrary.Models.DataModels;
using StandartLibrary.Models.Enums;
using StandartLibrary.Models.SapIntegrationModels.Common;
using StandartLibrary.Models.SapIntegrationModels.PartManagement.Request;
using StandartLibrary.Models.SapIntegrationModels.PartManagement.Response;
using StandartLibrary.Models.SapIntegrationModels.Proposal;
using StandartLibrary.Models.SapIntegrationModels.WorkOrderDetails.Response;
using StandartLibrary.Models.ViewModels.Common;
using StandartLibrary.Models.ViewModels.PartManagement;
using StandartLibrary.Models.ViewModels.Proposal;
using StandartLibrary.Models.ViewModels.WorkOrder;
using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using Microsoft.Extensions.Options;
using System.IO;
using StandartLibrary.Models.SapIntegrationModels.CRCDocumentAttachment.Request;
using StandartLibrary.Models.SapIntegrationModels.CRCDocumentAttachment.Response;
using StandartLibrary.Models.ViewModels.Request;
using StandartLibrary.Models.DataModels.ShortPlan;

namespace CRCAPI.Services.Services
{
    [ScopedDependency(ServiceType = typeof(ICrmService))]
    public class CrmService : ICrmService
    {
        private readonly IRedisCoreManager redisCoreManager;
        private readonly ILogCoreMan logMan;
        private readonly IUnitOfWork<CrcmsDbContext> unitOfWork;
        private readonly IUnitOfWork<ShortPlanContext> dbShort;
        private readonly AppSettings appSettings;

        private readonly SapIntegrationConstants _sapIntegrationConstants;

        public CrmService(IRedisCoreManager redisCoreManager, ILogCoreMan logMan, IUnitOfWork<CrcmsDbContext> unitOfWork, IOptions<AppSettings> options, IUnitOfWork<ShortPlanContext> _dbShort)
        {
            this.redisCoreManager = redisCoreManager;
            this.logMan = logMan;
            this.unitOfWork = unitOfWork;
            this.dbShort = _dbShort;
            this.appSettings = options.Value;

            _sapIntegrationConstants = GetSapIntegrationConstants();
        }

        /// <summary>
        /// Parça durumlarını crmden çeken servis...
        /// </summary>
        /// <param name="workOrderNumberList"></param>
        /// <returns></returns>
        public PartManagementResult GetPartStatus(List<string> workOrderNumberList)
        {
            IRestClient _restClient = GetSapClient();

            var request = new RestRequest("/zwsport", Method.POST);

            var req = new PartManagementRequest();
            foreach (var item in workOrderNumberList)
            {
                req.IMPORT.IT_WORKORDERS.Add(new PartManagementRequestItem
                {
                    WORKORDER_ID = item
                });
            }
            // Json to post.
            string jsonToSend = req.ToJson();

            request.AddParameter("application/json; charset=utf-8", jsonToSend, ParameterType.RequestBody);
            request.RequestFormat = DataFormat.Json;

            var response = _restClient.Post(request);

            //response status Completed değilse sorun var demektir null dön... foskan 31-12-2019...
            if (response.ResponseStatus != ResponseStatus.Completed)
            {
                return null;
            }

            var returnedObject = JsonConvert.DeserializeObject<PartManagementResponse>(response.Content);

            var mess = returnedObject?.EXPORT?.RESULT;
            if (mess != null)
            {
                if (mess.ErrorCode != "00")
                {
                    return null;
                }
            }


            PartManagementResult res = new PartManagementResult();

            if (returnedObject.EXPORT?.ET_PART_DETAILS != null)
            {
                res.PartManagementDetailList = returnedObject?.EXPORT?.ET_PART_DETAILS?.Select(x => new StandartLibrary.Models.ViewModels.PartManagement.PartManagementDetail()
                {
                    WorkOrderNumber = x.WorkOrderNumber,
                    Item = x.Item,
                    MainItem = x.MainItem,
                    Source = x.Source,
                    PartName = x.PartName,
                    PartNumber = x.PartNumber,
                    Unit = x.Unit,
                    Status = x.Status,
                    StatusCode = x.StatusCode,
                    ConfirmedCount = x.ConfirmedCount,
                    CustomsCount = x.CustomsCount,
                    DecisionCount = x.DecisionCount,
                    OpenCount = x.OpenCount,
                    OrderedCount = x.OrderedCount,
                    RemainingCount = x.RemainingCount,
                    ReservationCount = x.ReservationCount,
                    RoadCount = x.RoadCount,
                    ServiceCount = x.ServiceCount,
                    ShipmentCount = x.ShipmentCount,
                    ItemCreateDate = x.ItemCreateDate,
                    ItemGuid = x.ItemGuid,
                    ItemUpdateDate = x.ItemUpdateDate,
                    MainItemGuid = x.MainItemGuid,
                    PartOrderCreateDate = x.PartOrderCreateDate,
                    PartOrderNumber = x.PartOrderNumber,
                    DeliveryDate = x.DeliveryDate

                }).ToList();
            }

            return res;
        }


        /// <summary>
        /// writes work order info to db...
        /// </summary>
        /// <param name="workOrderNumber"></param>
        /// <returns></returns>
        public int BindWorkOrder(string workOrderNumber)
        {
            var wekingIntegrationInfo = redisCoreManager.GetObject<WekingIntegration>(RedisConstants.WEKING_INTEGRATION);
            try
            {
                var result = GetWorkOrderDetails(workOrderNumber);

                //if (!result.WorkOrderHeadDetails.Organization.Equals(wekingIntegrationInfo.WeKingOrganizationId))
                //{
                //    logMan.Error("CrmRenewalService Organization info Error", new Exception());
                //    return (int)WorkOrderBindingError.WrongOrganization;
                //}

                bool itemDetailsMissing = false;

                foreach (var item in result.WorkOrderItemDetails)
                {
                    if (string.IsNullOrWhiteSpace(item.ComponentCode) || string.IsNullOrWhiteSpace(item.JobCode))
                    {
                        itemDetailsMissing = true;
                        break;
                    }
                }

                if (itemDetailsMissing)
                {
                    return (int)WorkOrderBindingError.MissingItemDetail;
                }

                if (result != null)
                {
                    var documentId = FillDocument(result);

                    return documentId;
                }
                return (int)WorkOrderBindingError.NullSapResult;
            }
            catch (Exception ex)
            {
                logMan.Error("CrmRenewalService Binding Error", ex);
                return (int)WorkOrderBindingError.BindingError;
            }
        }


        /// <summary>
        /// Document Tablosuna kayıt atar...
        /// </summary>
        /// <param name="result"></param>
        /// <returns></returns>
        private int FillDocument(WorkOrderResult result)
        {
            var doc = new Document();

            var modelCode = result.WorkOrderHeadDetails.Model;

            var machineModel = unitOfWork.GetRepository<Model>().List(x => x.Code == modelCode).FirstOrDefault();

            if (machineModel == null)
            {
                machineModel = new Model() { Code = modelCode, Name = modelCode };
                unitOfWork.GetRepository<Model>().Add(machineModel);
            }

            var customerName = result.WorkOrderHeadDetails.SoldToPartyName;
            var customerCode = result.WorkOrderHeadDetails.SoldToPartyId;

            var customer = unitOfWork.GetRepository<Customer>().List(x => x.Name == customerName).FirstOrDefault();

            if (customer == null)
            {
                customer = new Customer() { Name = customerName, Code = customerCode };
                unitOfWork.GetRepository<Customer>().Add(customer);
            }
            else
            {
                customer.Code = customerCode;
                unitOfWork.GetRepository<Customer>().Update(customer);
            }

            var docCode = result.WorkOrderHeadDetails.SubjectCodeId;
            var docType = unitOfWork.GetRepository<DocumentType>().List(x => x.Code == docCode).FirstOrDefault();
            if (docType == null)
            {
                docType = new DocumentType { Code = docCode, Name = docCode };
                unitOfWork.GetRepository<DocumentType>().Add(docType);
                unitOfWork.SaveChanges();
            }
            doc.DocumentNumber = result.WorkOrderHeadDetails.ObjectId;
            doc.DocumentTypeId = docType.DocumentTypeId;
            doc.CustomerId = customer.CustomerId;
            doc.ModelId = machineModel.ModelId;
            doc.USERSTATUS = result.WorkOrderHeadDetails.UserStatus;
            doc.STATUSREASON = result.WorkOrderHeadDetails.StatusReason;
            doc.MachinesSN = result.WorkOrderHeadDetails.SerialNumber;
            doc.DocumentCreateDate = DateTime.ParseExact(result.WorkOrderHeadDetails.CreateDate, "dd.MM.yyyy HH:mm:ss", CultureInfo.InvariantCulture);
            doc.CreatedBy = result.WorkOrderHeadDetails.CreatedBy;
            doc.IsArrived = true;
            doc.ArrivalMonth = DateTime.Now;
            ////segmentInfo... 

            doc.Segment = result.WorkOrderHeadDetails.WorkOrderSegment;
            doc.SegmentText = result.WorkOrderHeadDetails.WorkOrderSegmentText;
            doc.SubSegment = result.WorkOrderHeadDetails.WorkOrderSubSegment;
            doc.SubSegmentText = result.WorkOrderHeadDetails.WorkOrderSubSegmentText;
            doc.DocStatusCode = result.WorkOrderHeadDetails.DocStatusCode;

            ////Quotation Information... 

            var docTypes = unitOfWork.GetRepository<DocumentType>().List(a => new string[] { "K1", "RO", "CR" }.Contains(a.Code));

            if (!docTypes.Any(a => a.DocumentTypeId == doc.DocumentTypeId))
            {
                doc.QuotationCurrency = result.WorkOrderHeadDetails.Currency;
                doc.QuotationAmount = result.WorkOrderHeadDetails.NetValue;
                doc.QuotationExcRate = result.WorkOrderHeadDetails.ExchangeRate;
                doc.QuotationExcDate = DateTime.ParseExact(result.WorkOrderHeadDetails.ExchangeDate, "yyyy-MM-dd", CultureInfo.InvariantCulture);
                doc.QuotationPriceDate = DateTime.ParseExact(result.WorkOrderHeadDetails.PriceDate, "yyyy-MM-dd", CultureInfo.InvariantCulture);
                doc.QuotationDocStatus = result.WorkOrderHeadDetails.MainQuotaStatus;
                doc.QuotationDocStatusText = result.WorkOrderHeadDetails.MainQuotaStatusDesc;
            }

            try
            {
                /// eski serviste ilk Item'ın ComponentCode bilgisi alındıgı için bu şekilde yapıldı.. foskan 30.12.2019
                doc.SmcsCode = result.WorkOrderItemDetails[0].ComponentCode;
            }
            catch (Exception)
            {
            }


            FillPssrInfo(result);
            if (result.WorkOrderPssrDetails != null && result.WorkOrderPssrDetails.Count != 0)
            {
                var woPssr = result.WorkOrderPssrDetails.FirstOrDefault(x => x.IsWorkOrderPssr == true);
                if (woPssr != null)
                {
                    doc.PssrName = woPssr.PssrFullName;
                    doc.PssrEmail = woPssr.EmailList.FirstOrDefault();
                }
            }

            unitOfWork.GetRepository<Document>().Add(doc);

            unitOfWork.SaveChanges();

            FillDocumentSegment(result);

            FillRelatedDocument(result);

            return doc.DocumentId;
        }


        /// <summary>
        /// Fills the pssr Info
        /// </summary>
        /// <param name="result"></param>
        private void FillPssrInfo(WorkOrderResult result)
        {
            var customerIdSAP = result.WorkOrderHeadDetails.SoldToPartyId;
            if (customerIdSAP != null)
            {
                var customer = unitOfWork.GetRepository<Customer>().List(x => x.Code == customerIdSAP).FirstOrDefault();
                if (customer != null)
                {
                    var customerId = customer.CustomerId;
                    var customerName = result.WorkOrderHeadDetails.SoldToPartyName;

                    var counterPssrCustomer = unitOfWork.GetRepository<CounterPSSRCustomer>().List(x => x.CustomerId == customerId).FirstOrDefault();
                    if (counterPssrCustomer == null)
                    {
                        var customerNewPssr = new CounterPSSRCustomer()
                        {
                            CustomerId = customerId,
                            Division = string.Empty
                        };
                        unitOfWork.GetRepository<CounterPSSRCustomer>().Add(customerNewPssr);
                    }
                    else
                    {
                        unitOfWork.GetRepository<CounterPSSRCustomer>().Delete(counterPssrCustomer);
                        var customerNewPssr = new CounterPSSRCustomer()
                        {
                            CustomerId = customerId,
                            Division = string.Empty
                        };
                        unitOfWork.GetRepository<CounterPSSRCustomer>().Add(customerNewPssr);
                    }

                    var pssrs = result.WorkOrderPssrDetails;
                    if (pssrs != null)
                    {
                        var counterPssrEmails = unitOfWork.GetRepository<CounterPssrEmail>().List(x => x.CustomerId == customerId && x.Type == 3);
                        if (counterPssrEmails != null)
                        {
                            unitOfWork.GetRepository<CounterPssrEmail>().RemoveRange(counterPssrEmails);
                            unitOfWork.SaveChanges();
                        }

                        var counterPssrs = new List<CounterPssrEmail>();
                        foreach (var pssr in pssrs)
                        {
                            ////burda emailin null gelem gibi bir sıkıntısı vardı
                            ///bu konuda  düzenleme yapıldı foskan... 05052020...
                            var email = pssr.EmailList.FirstOrDefault();
                            if (!string.IsNullOrWhiteSpace(email) && !counterPssrs.Any(x => x.Email == email))
                            {
                                var customerPssr = new CounterPssrEmail();
                                customerPssr.CustomerId = customerId;
                                customerPssr.Email = email;
                                customerPssr.Type = 3;

                                // TODO: Name vs.. 
                                counterPssrs.Add(customerPssr);
                            }
                        }

                        unitOfWork.GetRepository<CounterPssrEmail>().AddRange(counterPssrs);
                        unitOfWork.SaveChanges();

                    }//pssrs from sap is null
                    else
                    {
                        logMan.Info("PSSR info from SAP is Null!!");
                    }
                }//customer != null
                unitOfWork.SaveChanges();
            }
            else
            {
                logMan.Info("Customer info from SAP is Null!!");
            }
        }

        /// <summary>
        /// Sap den workorder detaylırını çeker...
        /// </summary>
        /// <param name="workOrderNumber"></param>
        /// <returns></returns>
        public WorkOrderResult GetWorkOrderDetails(string workOrderNumber)
        {
            IRestClient _restClient = GetSapClient();

            var request = new RestRequest("/zwsport", Method.POST);

            var req = new WorkOrderDetailRequest();
            req.IMPORT.WORKORDERID = workOrderNumber;

            // Json to post.
            string jsonToSend = req.ToJson();

            request.AddParameter("application/json; charset=utf-8", jsonToSend, ParameterType.RequestBody);
            request.RequestFormat = DataFormat.Json;

            var response = _restClient.Post(request);

            //response status Completed değilse sorun var demektir null dön... foskan 31-12-2019...
            if (response.ResponseStatus != ResponseStatus.Completed)
            {
                return null;
            }

            var returnedObject = JsonConvert.DeserializeObject<WorkOrderDetailResponse>(response.Content);

            var mess = returnedObject?.EXPORT?.RESULT;

            if (mess != null)
            {
                if (mess.ErrorCode != "00")
                {
                    return null;
                }
            }
            WorkOrderResult res = new WorkOrderResult();

            if (returnedObject.EXPORT?.WO_HEAD_DETAILS != null)
            {
                var headDetails = returnedObject.EXPORT?.WO_HEAD_DETAILS;

                res.WorkOrderHeadDetails = new StandartLibrary.Models.ViewModels.WorkOrder.WorkOrderHeadDetails
                {
                    CreateDate = headDetails.CreateDate,
                    CreatedBy = headDetails.CreatedBy,
                    Model = headDetails.Model,
                    ObjectId = headDetails.ObjectId,
                    SerialNumber = headDetails.SerialNumber,
                    SoldToPartyId = headDetails.SoldToPartyId,
                    SoldToPartyName = headDetails.SoldToPartyName,
                    StatusReason = headDetails.StatusReason,
                    SubjectCodeId = headDetails.SubjectCodeId,
                    SubjectCodeName = headDetails.SubjectCodeName,
                    UserStatus = headDetails.UserStatus,
                    WorkOrderNumber = headDetails.WorkOrderNumber,
                    WorkOrderSegment = headDetails.WorkOrderSegment,
                    WorkOrderSegmentText = headDetails.WorkOrderSegmentText,
                    WorkOrderSubSegment = headDetails.WorkOrderSubSegment,
                    WorkOrderSubSegmentText = headDetails.WorkOrderSubSegmentText,
                    Organization = headDetails.Organization,
                    EquipmentNumber = headDetails.EquipmentNumber,
                    LastWorkingHour = headDetails.LastWorkingHour,
                    Currency = headDetails.Currency,
                    MainQuotaStatus = headDetails.MainQuotaStatus,
                    MainQuotaStatusDesc = headDetails.MainQuotaStatusDesc,
                    NetValue = headDetails.NetValue,
                    ExchangeRate = headDetails.ExchangeRate,
                    ExchangeDate = headDetails.ExchangeDate,
                    PriceDate = headDetails.PriceDate,
                    DocStatusCode = headDetails.DocStatusCode,
                    PartnerSegments = headDetails.PartnerSegments.Select(x => new StandartLibrary.Models.ViewModels.WorkOrder.PartnerSegmentInfo
                    {
                        Partner = x.Partner,
                        PartnerSegment = x.PartnerSegment,
                        PartnerSegmentText = x.PartnerSegmentText,
                        PartnerSubSegment = x.PartnerSubSegment,
                        PartnerSubSegmentText = x.PartnerSubSegmentText
                    }).ToList()
                };
            }

            res.WorkOrderItemDetails = returnedObject?.EXPORT?.WO_ITEM_DETAILS?.Select(x => new StandartLibrary.Models.ViewModels.WorkOrder.WorkOrderItemDetail()
            {
                ComponentCode = x.ComponentCode,
                ItemNumber = x.ItemNumber,
                JobCode = x.JobCode,
                ProductId = x.ProductId,
                ProductText = x.ProductText
            }).ToList();


            res.WorkOrderPssrDetails = returnedObject?.EXPORT?.WO_PSSR_DETAILS?.Select(x => new StandartLibrary.Models.ViewModels.WorkOrder.PssrInfo()
            {
                PssrNumber = x.PssrNumber,
                PssrFullName = x.PssrFullName,
                IsWorkOrderPssr = x.IsWorkOrderPssr,
                EmailList = x.EmailList,
                TelephoneList = x.TelephoneList
            }).ToList();

            res.WorkOrderFlowDetails = returnedObject?.EXPORT?.WO_DOCFLOW_DETAILS?.Select(x => new StandartLibrary.Models.ViewModels.WorkOrder.WorkOrderFlowDetail()
            {
                Guid = x.Guid,
                ObjectId = x.ObjectId,
                ProcessType = x.ProcessType,
                Description = x.Description,
                CreatedBy = x.CreatedBy,
                PostingDate = x.PostingDate,
                Status = x.Status,
                StatusText = x.StatusText
            }).ToList();

            return res;
        }

        public QuotationResult GetQuotation(string workOrderNumber)
        {
            try
            {
                IRestClient _restClient = GetSapClient();

                var request = new RestRequest("/zwsport", Method.POST);

                var req = new ProposalRequest();
                req.IMPORT.IV_WORKORDER = workOrderNumber;

                request.AddParameter("application/json; charset=utf-8", JsonConvert.SerializeObject(req), ParameterType.RequestBody);
                request.RequestFormat = DataFormat.Json;

                var response = _restClient.Post(request);

                if (response.StatusCode != System.Net.HttpStatusCode.OK)
                {
                    return null;
                }

                var returnedObject = JsonConvert.DeserializeObject<ProposalRequestResponse>(response.Content);

                QuotationResult res = new QuotationResult();
                res.Export = new StandartLibrary.Models.ViewModels.Proposal.Export();

                if (returnedObject.EXPORT?.ET_QUOTATIONS != null)
                {
                    var headDetails = returnedObject.EXPORT?.ET_QUOTATIONS;

                    res.Export.EtQuotation = headDetails.Select(x => new EtQuotation
                    {
                        Currency = x.CURRENCY,
                        Customer = x.CUSTOMER,
                        Customer_Name = x.CUSTOMER_NAME,
                        Description = x.DESCRIPTION,
                        Equipment = x.EQUIPMENT,
                        EquipmentSerialNumber = x.EQUI_SERNR,
                        Guid = x.GUID,
                        Items = x.ITEMS.Select(y => new StandartLibrary.Models.ViewModels.Proposal.Item
                        {
                            ItemNo = y.ITEM_NO,
                            ProductDesc = y.PRODUCT_DESC,
                            ProductId = y.PRODUCT_ID,
                            Quantity = y.QUANTITY,
                            Unit = y.UNIT
                        }).ToList(),
                        OutputData = x.OUTPUT_DATA.Select(y => new OutputData { Form = y.FORM, Text = y.TEXT }).ToList(),
                        Object_Id = x.OBJECT_ID,
                        Segment = x.SEGMENT,
                        Segment_Txt = x.SEGMENT_TXT,
                        Source = x.SOURCE,
                        SourceTxt = x.SOURCE_TXT,
                        Status = x.STATUS,
                        StatusTxt = x.STATUS_TXT,
                        Sub_Segment = x.SUB_SEGMENT,
                        Sub_Segment_Txt = x.SUB_SEGMENT_TXT,
                        Type = x.TYPE,
                        ValidTo = x.VALID_TO,
                        ValidFrom = x.VALID_FROM,
                        Net_Value = x.NET_VALUE,
                        Main_Quota = x.MAIN_QUOTA,
                        StatusHistory = x.STATUS_HISTORY.Select(y => new StatusHistory
                        {
                            Status = y.STATUS,
                            StatusText = y.STATUS_TEXT,
                            Date = DateTime.ParseExact(y.DATE, "yyyy-MM-dd", CultureInfo.InvariantCulture),
                            Time = TimeSpan.ParseExact(y.TIME, "hh\\:mm\\:ss", CultureInfo.InvariantCulture)
                        }).ToList()

                    }).ToList();
                }

                return res;
            }
            catch (Exception)
            {
                throw;
            }
        }

        /// <summary>
        /// Sap den teklif dokümanlarını çeker...
        /// </summary>
        /// <param name="workOrderNumber"></param>
        /// <returns></returns>
        public QuotationOutputResult QuotationOutput(string formName, string quotationNo)
        {
            try
            {
                IRestClient _restClient = GetSapClient();

                var request = new RestRequest("/zwsport", Method.POST);

                var req = new ProposalOutputRequest();
                req.IMPORT.IV_FORM = formName;
                req.IMPORT.IV_OBJECT_ID = quotationNo;

                request.AddParameter("application/json; charset=utf-8", JsonConvert.SerializeObject(req), ParameterType.RequestBody);
                request.RequestFormat = DataFormat.Json;

                var response = _restClient.Post(request);

                if (response.StatusCode != System.Net.HttpStatusCode.OK)
                {
                    return null;
                }

                var returnedObject = JsonConvert.DeserializeObject<ProposalOutputResponse>(response.Content);

                if (returnedObject?.EXPORT?.RESULT != null)
                {
                    QuotationOutputResult quotationOutputResult = new QuotationOutputResult();
                    quotationOutputResult.Export = new OutputExport { Ev_Base64 = returnedObject.EXPORT.EV_BASE64 };
                    return quotationOutputResult;
                }

                return null;
            }
            catch (Exception)
            {
                throw;
            }
        }

        /// <summary>
        /// rest client oluşturur...
        /// </summary>
        /// <returns></returns>
        public RestClient GetSapClient()
        {
            if (_sapIntegrationConstants != null)
            {
                return new RestClient(_sapIntegrationConstants.SapRootUrl)
                {
                    Authenticator = new HttpBasicAuthenticator(_sapIntegrationConstants.SapUserName.Trim(), _sapIntegrationConstants.SapPassword.Trim())
                };
            }

            var sapIntegrationConstants = GetSapIntegrationConstants();

            return new RestClient(sapIntegrationConstants.SapRootUrl)
            {
                Authenticator = new HttpBasicAuthenticator(sapIntegrationConstants.SapUserName.Trim(), sapIntegrationConstants.SapPassword.Trim())
            };
        }

        private SapIntegrationConstants GetSapIntegrationConstants()
        {
            return redisCoreManager.GetObject<SapIntegrationConstants>(RedisConstants.SAP_INTEGRATION);
        }

        public void UpdateZsrtQuotation()
        {
            try
            {
                //dispatch olmamış geçerli iş emirlerine ait Zsrt tekliflerinin listesi

                var zsrtQuotations = (from d in unitOfWork.Context.Documents
                                      join t in unitOfWork.Context.DocumentTypes on d.DocumentTypeId equals t.DocumentTypeId
                                      where new string[] { "K1", "RO", "CR" }.Contains(t.Code) &&
                                            d.USERSTATUS != "Closed" && d.USERSTATUS != "Cancel" && d.USERSTATUS != "Completed"
                                      select d).ToList();

                foreach (var zsrtDocument in zsrtQuotations)
                {
                    try
                    {
                        QuotationResult quotationResult = GetQuotation(zsrtDocument.DocumentNumber);

                        if (quotationResult == null)
                        {
                            continue;
                        }

                        EtQuotation etQuotation = quotationResult.Export.EtQuotation
                                .Where(x => !string.IsNullOrEmpty(x.Main_Quota))
                                .Select(x => x).FirstOrDefault();

                        if (etQuotation == null)
                        {
                            etQuotation = quotationResult.Export.EtQuotation.Where(x => x.Status == "E0001").Select(x => x).FirstOrDefault();

                            if (etQuotation == null)
                            {
                                etQuotation = quotationResult.Export.EtQuotation.Where(x => x.Status == "E0003").OrderByDescending(x => Convert.ToInt64(x.Object_Id)).Select(x => x).FirstOrDefault();

                                if (etQuotation == null)
                                {
                                    etQuotation = quotationResult.Export.EtQuotation.Where(x => x.Status == "E0004").OrderByDescending(x => Convert.ToInt64(x.Object_Id)).Select(x => x).FirstOrDefault();
                                }
                            }
                        }

                        if (etQuotation != null)
                        {
                            var docEntity = unitOfWork.Context.Documents.Where(x => x.DocumentId == zsrtDocument.DocumentId).Select(x => x).FirstOrDefault();

                            if (docEntity != null)
                            {
                                docEntity.QuotationCurrency = etQuotation.Currency;
                                docEntity.QuotationAmount = (decimal)etQuotation.Net_Value;
                                docEntity.QuotationDocStatus = etQuotation.Status;
                                docEntity.QuotationDocStatusText = etQuotation.StatusTxt;
                                docEntity.DocStatusCode = etQuotation.Status;
                                var listOfStatuses = unitOfWork.Context.QuotationStatusHistory.Where(x => x.DocumentId == docEntity.DocumentId).Select(x => x).ToList();
                                if (listOfStatuses.Any())
                                    unitOfWork.Context.QuotationStatusHistory.RemoveRange(listOfStatuses);

                                if (etQuotation.StatusHistory != null && etQuotation.StatusHistory.Any())
                                {
                                    var listOfNewStatuses = etQuotation.StatusHistory?.Select(x => new StandartLibrary.Models.DataModels.Counter.QuotationStatusHistory
                                    {
                                        Status = x.Status,
                                        Date = x.Date,
                                        DocumentId = docEntity.DocumentId,
                                        QuotationId = Guid.NewGuid(),
                                        StatusText = x.StatusText,
                                        Time = x.Time
                                    });

                                    unitOfWork.Context.QuotationStatusHistory.AddRange(listOfNewStatuses);

                                    var counterListEntity = unitOfWork.Context.CounterLists.Where(x => x.DocumentId == zsrtDocument.DocumentId).Select(x => x).FirstOrDefault();
                                    if (etQuotation.Status == "")//AwaitingQuotation (eğer henüz teklif belgesi oluşturulmamışsa)	
                                    {
                                        counterListEntity.CounterStatusId = (int)CounterStatus.Start;
                                        counterListEntity.PreparingQuotation_StateId = 0;
                                    }
                                    else if (etQuotation.Status == "E0001")//InQuotationProcess	        E001 - Açık
                                    {
                                        counterListEntity.CounterStatusId = (int)CounterStatus.PriceOpening;
                                        counterListEntity.PreparingQuotation_StateId = 1;
                                    }
                                    else if (etQuotation.Status == "E0002")//InQuotationProcess	        E001 - Belirsiz
                                    {
                                        counterListEntity.CounterStatusId = (int)CounterStatus.Start;
                                        counterListEntity.PreparingQuotation_StateId = 0;
                                    }
                                    else if (etQuotation.Status == "E0006")//AwaitingSignedQuotation	E006 - Pssr/satış lideri takibinde
                                    {
                                        counterListEntity.CounterStatusId = (int)CounterStatus.PreparingQuotation;
                                        counterListEntity.PreparingQuotation_IsCompleted = true;
                                        counterListEntity.PreparingQuotation_CompletedDate = DateTime.Now;
                                        counterListEntity.PreparingQuotation_StateId = 2;
                                    }
                                    else if (etQuotation.Status == "E0005")//HasSignedQuotation	        E005 - Teklif Onaylandı
                                    {
                                        counterListEntity.LastChangeDate = DateTime.Now;
                                        counterListEntity.CustomerApproval_IsAnswerReceived = true;
                                        counterListEntity.CustomerApproval_AnswerReceivedDate = DateTime.Now;
                                        counterListEntity.CustomerApproval_IsApproved = true;
                                        counterListEntity.CounterStatusId = (int)CounterStatus.Approved;
                                        counterListEntity.PreparingQuotation_StateId = 3;
                                    }
                                    else if (etQuotation.Status == "E0003")//AwaitingQuotation	        E003 - Reddedildi
                                    {
                                        counterListEntity.LastChangeDate = DateTime.Now;
                                        counterListEntity.CustomerApproval_IsAnswerReceived = true;
                                        counterListEntity.CustomerApproval_AnswerReceivedDate = DateTime.Now;
                                        counterListEntity.CustomerApproval_IsApproved = false;
                                        counterListEntity.CounterStatusId = (int)CounterStatus.QuotationRejected;
                                        counterListEntity.PreparingQuotation_StateId = 5;
                                    }
                                    else if (etQuotation.Status == "E0004")//AwaitingQuotation	        E004 - İptal (edited)
                                    {
                                        counterListEntity.LastChangeDate = DateTime.Now;
                                        counterListEntity.CustomerApproval_IsAnswerReceived = true;
                                        counterListEntity.CustomerApproval_AnswerReceivedDate = DateTime.Now;
                                        counterListEntity.CounterStatusId = (int)CounterStatus.PriceOpening;
                                        counterListEntity.PreparingQuotation_StateId = 4;
                                    }
                                    else
                                    {
                                        counterListEntity.CounterStatusId = (int)CounterStatus.Start;
                                        counterListEntity.PreparingQuotation_StateId = 0;
                                    }
                                }

                                unitOfWork.Context.SaveChanges();
                            }
                        }
                    }
                    catch (Exception ex)
                    {
                        logMan.Error(ex.Message);
                    }
                }
            }
            catch (Exception ex)
            {
                logMan.Error(ex.Message);
                throw;
            }
        }

        public WorkOrderResult GetWorkOrderByWorkOrderNumber(string workOrderNumber, out int documentId)
        {
            documentId = 0;

            try
            {
                var result = GetWorkOrderDetails(workOrderNumber);

                if (result == null)
                    return null;

                documentId = FillDocument(result);

                return result;

            }
            catch (Exception ex)
            {
                logMan.Error("CrmRenewalService Binding Error", ex);
                return null;
            }
        }

        public bool AddCRCDocumentAttacments()
        {
            var queues = unitOfWork.GetRepository<SAPUploadQueue>().List(x => x.IsDeletedFromCDOMS == false && x.RetryCount < 5 && x.TryStartDate < DateTime.Now && x.Status != SAPUploadQueueStatus.Completed && x.Status != SAPUploadQueueStatus.InProcess).Take(20).ToList();

            if (queues == null || queues.Count == 0)
            {
                return false;
            }

            /*flag item that it's inprocess right now*/
            foreach (var item in queues)
            {
                item.Status = SAPUploadQueueStatus.InProcess;
                unitOfWork.GetRepository<SAPUploadQueue>().Update(item);
                unitOfWork.SaveChanges();
            }

            foreach (var item in queues)
            {
                IRestClient _restClient = GetSapClient();
                var request = new RestRequest("/zwsport", Method.POST);
                byte[] fileData = File.ReadAllBytes(item.FilePath);
                var content = Convert.ToBase64String(fileData);
                List<DocumentDetails> attachmentlist = new List<DocumentDetails>();
                attachmentlist.Add(new DocumentDetails() { CONTENT = content, FILE_NAME = item.FileName, OBJECT_ID = item.DocumentNumber });

                var req = new CRCDocumentAttachmentRequest()
                {
                    IMPORT = new StandartLibrary.Models.SapIntegrationModels.CRCDocumentAttachment.Request.IMPORT()
                    {
                        IT_ATTACHMENT = attachmentlist
                    }
                };
                // Json to post.
                string jsonToSend = req.ToJson();
                request.AddParameter("application/json; charset=utf-8", jsonToSend, ParameterType.RequestBody);
                request.RequestFormat = DataFormat.Json;

                var response = _restClient.Post(request);
                if (response.ResponseStatus != ResponseStatus.Completed)
                {
                    logMan.Error("CrmService.AddCRCDocumentAttacments ResponseStatusCode not Completed");
                    var returnedObject = JsonConvert.DeserializeObject<CRCDocumentAttachmentResponse>(response.Content);
                    if (item.Status == SAPUploadQueueStatus.Error)
                        item.RetryCount += 1;
                    item.ErrorMessage = returnedObject.EXPORT.ES_RETURN.ERRMESSAGE;
                    item.Status = SAPUploadQueueStatus.Error;
                    unitOfWork.GetRepository<SAPUploadQueue>().Update(item);
                    unitOfWork.SaveChanges();
                }
                else
                {
                    item.Status = SAPUploadQueueStatus.Completed;
                    unitOfWork.GetRepository<SAPUploadQueue>().Update(item);
                    unitOfWork.SaveChanges();
                }
            }

            return true;
        }

        public List<WorkOrderInfosResponse> GetWorkOrderDetailsByCutomerNo(string cusCode, List<string> docIds)
        {
            var cus = string.IsNullOrEmpty(cusCode) ? null : unitOfWork.GetRepository<Customer>().List().Find(x => x.Code == cusCode);
            var datas = unitOfWork.GetRepository<Document>().List(x => (cus == null || x.CustomerId == cus.CustomerId) && (docIds == null || docIds.Count == 0 || docIds.Contains(x.DocumentNumber))).ToList();
            var models = unitOfWork.GetRepository<Model>().List(x => datas.Select(x => x.ModelId).Distinct().ToList().Contains(x.ModelId)).ToList();
            var attachments = unitOfWork.GetRepository<Upload>().List(x => datas.Select(t => t.DocumentId).Distinct().Contains(x.DocumentId)).ToList();
            var dispatchedDatas = unitOfWork.GetRepository<DocumentAttributesDispatched>().List().Where(x => datas.Select(y => y.DocumentId).Distinct().Contains(x.DocumentId));
            var testedDatas = unitOfWork.GetRepository<DocumentAttributes>().List().Where(x => datas.Select(y => y.DocumentId).Distinct().Contains(x.DocumentId));
            var allCustumers = unitOfWork.GetRepository<Customer>().List().Where(x => datas.Where(t => t.CustomerId.HasValue).Select(y => y.CustomerId).Contains(x.CustomerId)).ToList();

            List<WorkOrderInfosResponse> m = new List<WorkOrderInfosResponse>();

            if (datas != null && datas.Count > 0)
            {
                foreach (var item in datas)
                {
                    WorkOrderInfosResponse currentModel = null;

                    if (item.CustomerId.HasValue)
                    {
                        if (m.Find(x => x.CustomerNo == item.CustomerId.Value) == null)
                        {
                            var currentCus = allCustumers.Find(x => x.CustomerId == item.CustomerId.Value);
                            m.Add(new WorkOrderInfosResponse
                            {
                                CustomerNo = currentCus.CustomerId,
                                CustomerCode = currentCus.Code,
                                CustomerName = currentCus.Name,
                                WorkOrders = new List<WorkOrderInfoDetails>()
                            });
                        }
                        currentModel = m.Find(x => x.CustomerNo == item.CustomerId.Value);
                    }
                    else
                    {
                        if (m.Find(x => x.CustomerNo == 0 && x.CustomerName == "" && x.CustomerCode == "") == null)
                        {
                            m.Add(new WorkOrderInfosResponse
                            {
                                CustomerNo = 0,
                                CustomerCode = "",
                                CustomerName = "",
                                WorkOrders = new List<WorkOrderInfoDetails>()
                            });
                        }
                        currentModel = m.Find(x => x.CustomerNo == 0 && x.CustomerName == "");
                    }

                    var teststatus = testedDatas.Where(x => x.DocumentId == item.DocumentId).Count() > 0 ? testedDatas.Where(x => x.DocumentId == item.DocumentId).OrderByDescending(c => c.id).FirstOrDefault() : null;
                    var dispatchstatus = dispatchedDatas.Where(x => x.DocumentId == item.DocumentId).Count() > 0 ? dispatchedDatas.Where(x => x.DocumentId == item.DocumentId).OrderByDescending(c => c.id).FirstOrDefault() : null;
                    var realStatusId = teststatus != null ? teststatus.ShortPlanStatusId : dispatchstatus != null ? dispatchstatus.ShortPlanStatusId : null;
                    WorkOrderInfoDetails detail = new WorkOrderInfoDetails
                    {
                        Description = item.Description,
                        DocumentId = item.DocumentId,
                        DocumentNumber = item.DocumentNumber,
                        ModelId = item.ModelId,
                        ModelName = item.ModelId.HasValue ? models.Where(x => x.ModelId == item.ModelId.Value).FirstOrDefault().Name : "",
                        StatusId = realStatusId,
                        StatusName = realStatusId.HasValue ? dbShort.GetRepository<PlanWorkStatusList>().List().Find(x => x.WorkStatusId == realStatusId.Value).NameEn : "",
                        Attachments = new List<WorkOrderInfoAttachemntDetails>()
                    };

                    var docAttachs = attachments.Where(x => x.DocumentId == item.DocumentId).ToList();
                    if (docAttachs != null && docAttachs.Count > 0)
                    {
                        foreach (var item2 in docAttachs)
                        {
                            detail.Attachments.Add(new WorkOrderInfoAttachemntDetails
                            {
                                AttachmentId = item2.UploadId,
                                FileName = item2.Name,
                                UploadType = unitOfWork.GetRepository<StandartLibrary.Models.DataModels.UploadType>().List(x => x.UploadTypeId == item2.TypeId).FirstOrDefault().NameEn
                            });
                        }
                    }

                    currentModel.WorkOrders.Add(detail);
                }
            }

            return m;
        }
        private void FillDocumentSegment(WorkOrderResult result)
        {
            if (result != null)
            {
                if (result.WorkOrderItemDetails != null && result.WorkOrderHeadDetails != null)
                {
                    foreach (var WorkOrderItemDetail in result.WorkOrderItemDetails)
                    {
                        int intItemNumber = Convert.ToInt32(WorkOrderItemDetail.ItemNumber);
                        var documentSegment = unitOfWork.GetRepository<DocumentSegment>().List(x => x.DocumentNumber == result.WorkOrderHeadDetails.ObjectId && x.SegmentCode == intItemNumber).FirstOrDefault();
                        if (documentSegment != null)
                        {
                            documentSegment.DocumentNumber = result.WorkOrderHeadDetails.ObjectId;
                            documentSegment.SegmentCode = Convert.ToInt32(WorkOrderItemDetail.ItemNumber);
                            documentSegment.ComponentCode = Convert.ToInt32(WorkOrderItemDetail.ComponentCode);
                            documentSegment.JobCode = WorkOrderItemDetail.JobCode;
                            documentSegment.ProductId = WorkOrderItemDetail.ProductId;
                            documentSegment.ProductText = WorkOrderItemDetail.ProductText;
                        }
                        unitOfWork.SaveChanges();
                    }
                }
            }
        }
        private void FillRelatedDocument(WorkOrderResult result)
        {
            if (result != null)
            {
                if (result.WorkOrderFlowDetails != null)
                {
                    foreach (var workOrderFlowDetail in result.WorkOrderFlowDetails)
                    {
                        var relatedDocument = unitOfWork.GetRepository<RelatedDocument>().List(x => x.DocumentNumber == workOrderFlowDetail.ObjectId).FirstOrDefault();
                        if (relatedDocument != null)
                        {
                            relatedDocument.DocumentNumber = result.WorkOrderHeadDetails.ObjectId;
                            relatedDocument.DocumentNumberRelated = workOrderFlowDetail.ObjectId;
                            relatedDocument.ProcessType = workOrderFlowDetail.ProcessType;
                            relatedDocument.Description = workOrderFlowDetail.Description;
                            relatedDocument.CreatedBy = workOrderFlowDetail.CreatedBy;
                            relatedDocument.PostingDate = Convert.ToDateTime(workOrderFlowDetail.PostingDate);
                            relatedDocument.Status = workOrderFlowDetail.Status;
                            relatedDocument.StatusText = workOrderFlowDetail.StatusText;
                        }
                        unitOfWork.SaveChanges();
                    }
                }
            }
        }

    }
}
