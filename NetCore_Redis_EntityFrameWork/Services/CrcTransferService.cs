using System;
using System.Collections.Generic;
using System.Linq;
using CRCAPI.Services.Attributes;
using CRCAPI.Services.Interfaces;
using CRCAPI.Services.Models.CrcTransfer;
using Microsoft.EntityFrameworkCore;
using Newtonsoft.Json;
using RestSharp;
using RestSharp.Authenticators;
using StandartLibrary.Models.Constants;
using StandartLibrary.Models.DataModels;
using StandartLibrary.Models.EntityModels;
using StandartLibrary.Models.EntityModels.MailQueue;
using StandartLibrary.Models.Enums;
using StandartLibrary.Models.SapIntegrationModels.Common;
using StandartLibrary.Models.ViewModels.Common;
using StandartLibrary.Models.ViewModels.CrcComponentTransfer;
using UploadType = StandartLibrary.Models.Enums.UploadType;

namespace CRCAPI.Services.Services
{
    [ScopedDependency(ServiceType = typeof(ICrcTransferService))]
    public class CrcTransferService : ICrcTransferService
    {
        private readonly IUnitOfWork<CrcmsDbContext> _unitOfWork;
        private readonly ISmtpService _smtpService;
        private readonly IRedisCoreManager _redisCoreManager;
        private readonly string ClientUrl;

        public CrcTransferService(IUnitOfWork<CrcmsDbContext> unitOfWork, ISmtpService smtpService, IRedisCoreManager redisCoreManager)
        {
            _unitOfWork = unitOfWork;
            _smtpService = smtpService;
            _redisCoreManager = redisCoreManager;
            ClientUrl = _redisCoreManager.GetObject<CrcTransferConfiguration>(RedisConstants.CRC_TRANSFER).ClientUrl;
        }

        public InternalRequest CreateInternalRequest(CrcComponentTransferCreateOrEditModel model)
        {
            var customer = _unitOfWork.GetRepository<Customer>().List().FirstOrDefault(x => x.Code == model.CustomerNumber);
            var internalRequestToCreate = new InternalRequest
            {
                ComponentArrivalReason = model.ComponentArrivalReason,
                ComponentArrivalType = model.ArrivalType,
                ComponentReceiveDate = model.ComponentReceiveDate,
                ComponentSendDate = model.ComponentSendDate,
                ComponentSerialNo = model.ComponentSerialNo,
                CreateDate = DateTime.Now,
                CreateUser = model.CreateUser,
                CreateUserDisplayName = model.CreateUserDisplayName,
                CurrentWorkOrder = model.CurrentWorkOrder,
                Customer = customer,
                Description = model.FaultDescription,
                DocumentId = model.DocumentId,
                EquipmentWorkingHours = model.EquipmentWorkingHours,
                GroupId = model.GroupId,
                PlannedRevision = model.PlannedRevision,
                SubProductId = model.SubProductId,
                TransferWorkOrder = model.TransferWorkOrder,
                Status = InternalRequestStatus.RequestCreated
            };

            if (CheckArrivalReasonComponents(internalRequestToCreate.ComponentArrivalReason))
            {
                foreach (var component in model.Components)
                {
                    internalRequestToCreate.InternalRequestComponents.Add(new InternalRequestComponent
                    {
                        GroupId = component.GroupId,
                        ComponentCode = component.ComponentCode,
                        Description = component.Description,
                        JobCode = component.JobCode,
                        PartsName = component.PartsName,
                        Quantity = component.Quantity,
                        RequestedWork = component.RequestedWork,
                        RowNumber = component.ItemNumber
                    });
                }
            }

            try
            {
                _unitOfWork.GetRepository<InternalRequest>().Add(internalRequestToCreate);
                _unitOfWork.SaveChanges();

                var savedInternalRequest = _unitOfWork.Context.InternalRequest
                    .Include(x => x.ArrivalReason)
                    .Include(x => x.Group)
                    .Include(x => x.SubProduct)
                    .FirstOrDefault(x => x.Id == internalRequestToCreate.Id);
                var componentModel = _unitOfWork.Context.Documents.FirstOrDefault(x => x.DocumentId == savedInternalRequest.DocumentId)?.Model?.Name;
                var mailQueueParameterModel = new MailQueueParameterModel
                {
                    Subject = "{CrcTransferRequestCreatedEmail}",
                    Title = "{CrcTransferRequestCreatedEmail}",
                    UploadIds = null,
                    CrcTransferRequest = new CrcTransferRequestItemModel
                    {
                        RequestUrl = $"{ClientUrl}/CrcComponentTransfer/Edit?id={savedInternalRequest.Id}",
                        RequestNumber = savedInternalRequest.RequestNumber,
                        CustomerName = savedInternalRequest.Customer?.Name,
                        Model = componentModel,
                        ComponentSerialNo = savedInternalRequest.ComponentSerialNo,
                        CreateUser = savedInternalRequest.CreateUserDisplayName,
                        ComponentName = savedInternalRequest.SubProduct?.Name,
                        GroupName = savedInternalRequest.Group?.Name,
                        ArrivalReasonName = savedInternalRequest.ArrivalReason?.Name,
                        TransferWorkOrder = savedInternalRequest.TransferWorkOrder,
                        ComponentReceiveDate = savedInternalRequest.ComponentReceiveDate,
                        AddedComponents = model.Components.Select(x => x.ItemNumber).ToList()
                    }
                };

                var userAccess = _unitOfWork.GetRepository<UsersAccess>().List();
                var toList = userAccess.Where(x => x.InternalRequest).ToList().Select(f => f.Email).ToList();
                _smtpService.SendMail(mailQueueParameterModel, toList, null);

            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                throw;
            }

            return internalRequestToCreate;
        }

        public List<WorkStatusModel> GetWorkStatus(string documentId)
        {
            var wekingIntegrationInfo = _redisCoreManager.GetObject<WekingIntegration>(RedisConstants.WEKING_INTEGRATION);
            IRestClient restClient = GetWekingClient(wekingIntegrationInfo);

            var request = new RestRequest($"customer/assignments/{documentId}", Method.GET)
            {
                RequestFormat = DataFormat.Json
            };

            request.AddHeader("Language", "tr");

            var response = restClient.Get(request);
            if (response.StatusCode == System.Net.HttpStatusCode.OK)
            {
                var workOrdersResponse = JsonConvert.DeserializeObject<WorkOrderApiResponse>(response.Content);
                if (workOrdersResponse.WorkOrders == null)
                {
                    return new List<WorkStatusModel>();
                }

                var list = workOrdersResponse.WorkOrders.ToList();
                foreach (var item in list)
                {
                    if (string.IsNullOrEmpty(item.BayNo))
                    {
                        item.WorkOrderDescription = "-";
                    }
                    else
                    {
                        item.WorkOrderDescription = _unitOfWork.GetRepository<Area>().List().FirstOrDefault(x => x.AreaId == int.Parse(item.BayNo))?.FullName;
                    }
                }

                return list;
            }

            return null;
        }

        public RestClient GetWekingClient(WekingIntegration wekingIntegrationInfo)
        {
            return new RestClient(wekingIntegrationInfo.WeKingUrl)
            {
                Authenticator = new HttpBasicAuthenticator(wekingIntegrationInfo.WekingIntegrationUser, wekingIntegrationInfo.WekingIntegrationPassword)
            };
        }

        public InternalRequest EditInternalRequest(CrcComponentTransferCreateOrEditModel model)
        {
            var internalRequest = _unitOfWork.Context.InternalRequest.FirstOrDefault(x => x.Id == model.Id);
            if (internalRequest == null)
            {
                return null;
            }

            var internalRequestOld = _unitOfWork.Context.InternalRequest.AsNoTracking().FirstOrDefault(x => x.Id == model.Id);
            var internalRequestComponentsOld = _unitOfWork.Context.InternalRequestComponent.AsNoTracking().Where(x => x.InternalRequestId == model.Id).ToList();

            internalRequest.ComponentArrivalReason = model.ComponentArrivalReason;
            internalRequest.ComponentArrivalType = model.ArrivalType;
            internalRequest.ComponentReceiveDate = model.ComponentReceiveDate;
            internalRequest.ComponentSendDate = model.ComponentSendDate;
            internalRequest.UpdateDate = DateTime.Now;
            internalRequest.UpdateUser = model.UpdateUser;
            internalRequest.UpdateUserDisplayName = model.UpdateUserDisplayName;
            internalRequest.CurrentWorkOrder = model.CurrentWorkOrder;
            internalRequest.Description = model.FaultDescription;
            internalRequest.DocumentId = model.DocumentId;
            internalRequest.EquipmentWorkingHours = model.EquipmentWorkingHours;
            internalRequest.GroupId = model.GroupId;
            internalRequest.PlannedRevision = model.PlannedRevision;
            internalRequest.SubProductId = model.SubProductId;
            internalRequest.TransferWorkOrder = model.TransferWorkOrder;
            internalRequest.InternalRequestComponents.Clear();
            internalRequest.Status = InternalRequestStatus.RequestUpdated;
            internalRequest.InternalRequestComponents.Clear();

            foreach (var component in model.Components)
            {
                internalRequest.InternalRequestComponents.Add(new InternalRequestComponent
                {
                    GroupId = component.GroupId,
                    ComponentCode = component.ComponentCode,
                    Description = component.Description,
                    JobCode = component.JobCode,
                    PartsName = component.PartsName,
                    Quantity = component.Quantity,
                    RequestedWork = component.RequestedWork,
                    RowNumber = component.ItemNumber
                });
            }

            try
            {
                _unitOfWork.SaveChanges();

                var changedProps = new Dictionary<string, Tuple<string, string>>();
                foreach (var propertyInfo in internalRequestOld.GetType().GetProperties())
                {
                    if (propertyInfo.PropertyType == typeof(string) ||
                        propertyInfo.PropertyType == typeof(int) ||
                        propertyInfo.PropertyType == typeof(DateTime) ||
                        propertyInfo.PropertyType == typeof(bool) ||
                        propertyInfo.PropertyType == typeof(Guid) ||
                        propertyInfo.PropertyType.IsEnum ||
                        propertyInfo.PropertyType.IsPrimitive)
                    {
                        var propName = propertyInfo.Name;
                        if (propName != "Id" && propName != "DocumentId" && propName != "CreateUser" && propName != "UpdateUser" && propName != "Status" && propName != "RequestNumber")
                        {
                            var oldValue = internalRequestOld.GetType().GetProperty(propertyInfo.Name)?.GetValue(internalRequestOld, null)?.ToString();
                            var newValue = internalRequest.GetType().GetProperty(propertyInfo.Name)?.GetValue(internalRequest, null)?.ToString();

                            changedProps.Add("{" + propName + "}", new Tuple<string, string>(oldValue, newValue));
                        }
                    }
                }

                var extractedComponents = internalRequestComponentsOld.Where(x => !model.Components.Any(y => y.ItemNumber == x.RowNumber)).Select(x => x.RowNumber).ToList();
                var addedComponents = model.Components.Where(x => !internalRequestComponentsOld.Any(y => y.RowNumber == x.ItemNumber)).Select(x => x.ItemNumber).ToList();
                var componentModel = _unitOfWork.Context.Documents.FirstOrDefault(x => x.DocumentId == internalRequest.DocumentId)?.Model?.Name;
                var mailQueueParameterModel = new MailQueueParameterModel
                {
                    Subject = "{CrcTransferRequestUpdatedEmail}",
                    Title = "{CrcTransferRequestUpdatedEmail}",
                    UploadIds = null,
                    CrcTransferRequest = new CrcTransferRequestItemModel
                    {
                        RequestUrl = $"{ClientUrl}/CrcComponentTransfer/Edit?id={internalRequest.Id}",
                        RequestNumber = internalRequest.RequestNumber,
                        CustomerName = internalRequest.Customer.Name,
                        Model = componentModel,
                        ComponentSerialNo = internalRequest.ComponentSerialNo,
                        CreateUser = internalRequest.CreateUserDisplayName,
                        ComponentName = internalRequest.SubProduct.Name,
                        GroupName = internalRequest.Group.Name,
                        ArrivalReasonName = internalRequest.ArrivalReason.Name,
                        TransferWorkOrder = internalRequest.TransferWorkOrder,
                        ComponentReceiveDate = internalRequest.ComponentReceiveDate,
                        ChangedProps = changedProps,
                        ExtractedComponents = extractedComponents,
                        AddedComponents = addedComponents
                    }
                };

                var userAccess = _unitOfWork.GetRepository<UsersAccess>().List();
                var toList = userAccess.Where(x => x.InternalRequest).ToList().Select(f => f.Email).ToList();
                _smtpService.SendMail(mailQueueParameterModel, toList, null);

            }
            catch (Exception e)
            {
                Console.WriteLine(e);
                throw;
            }

            return internalRequest;
        }

        public string DeleteInternalRequest(Guid id, string loggedUser)
        {
            var internalRequest = _unitOfWork.Context.InternalRequest.FirstOrDefault(x => x.Id == id && x.CreateUser == loggedUser);
            if (internalRequest == null)
            {
                return "unauthorized";
            }

            if (internalRequest.InternalRequestComponents.Any(x => x.Status == InternalRequestComponentStatus.Accepted))
            {
                return "acceptedcomponents";
            }

            internalRequest.Status = InternalRequestStatus.RequestCancelled;
            _unitOfWork.Context.SaveChanges();

            var componentModel = _unitOfWork.Context.Documents.FirstOrDefault(x => x.DocumentId == internalRequest.DocumentId)?.Model?.Name;
            var mailQueueParameterModel = new MailQueueParameterModel
            {
                Subject = "{CrcTransferRequestDeletedEmail}",
                Title = "{CrcTransferRequestDeletedEmail}",
                UploadIds = null,
                CrcTransferRequest = new CrcTransferRequestItemModel
                {
                    RequestUrl = $"{ClientUrl}/CrcComponentTransfer/Edit?id={internalRequest.Id}",
                    RequestNumber = internalRequest.RequestNumber,
                    CustomerName = internalRequest.Customer.Name,
                    Model = componentModel,
                    ComponentSerialNo = internalRequest.ComponentSerialNo,
                    CreateUser = internalRequest.CreateUserDisplayName,
                    ComponentName = internalRequest.SubProduct.Name,
                    GroupName = internalRequest.Group.Name,
                    ArrivalReasonName = internalRequest.ArrivalReason.Name,
                    TransferWorkOrder = internalRequest.TransferWorkOrder,
                    ComponentReceiveDate = internalRequest.ComponentReceiveDate
                }
            };

            var userAccess = _unitOfWork.GetRepository<UsersAccess>().List();
            var toList = userAccess.Where(x => x.InternalRequest).ToList().Select(f => f.Email).ToList();
            _smtpService.SendMail(mailQueueParameterModel, toList, null);

            return "ok";
        }

        public CrcTransferRequestsResponse GetInternalRequestList(JqueryDatatableParam parameters, int sortColumnIndex, string sortDirection)
        {
            var crcTransferRequests = _unitOfWork.Context.InternalRequest.Where(x => x.Status != InternalRequestStatus.RequestCancelled);

            if (sortColumnIndex == 0)
            {
                crcTransferRequests = sortDirection == "asc" ? crcTransferRequests.OrderBy(x => x.Id) : crcTransferRequests.OrderByDescending(x => x.Id);
            }
            else if (sortColumnIndex == 1)
            {
                crcTransferRequests = sortDirection == "asc" ? crcTransferRequests.OrderBy(x => x.Customer.Name) : crcTransferRequests.OrderByDescending(x => x.Customer.Name);
            }
            else if (sortColumnIndex == 2)
            {
                crcTransferRequests = sortDirection == "asc" ? crcTransferRequests.OrderBy(x => x.CurrentWorkOrder) : crcTransferRequests.OrderByDescending(x => x.CurrentWorkOrder);
            }
            else if (sortColumnIndex == 3)
            {
                crcTransferRequests = sortDirection == "asc" ? crcTransferRequests.OrderBy(x => x.TransferWorkOrder) : crcTransferRequests.OrderByDescending(x => x.TransferWorkOrder);
            }
            else if (sortColumnIndex == 4)
            {
                crcTransferRequests = sortDirection == "asc" ? crcTransferRequests.OrderBy(x => x.Group.Name) : crcTransferRequests.OrderByDescending(x => x.Group.Name);
            }
            else if (sortColumnIndex == 5)
            {
                crcTransferRequests = sortDirection == "asc" ? crcTransferRequests.OrderBy(x => x.CreateUserDisplayName) : crcTransferRequests.OrderByDescending(x => x.CreateUserDisplayName);
            }
            else if (sortColumnIndex == 6)
            {
                crcTransferRequests = sortDirection == "asc" ? crcTransferRequests.OrderBy(x => x.CreateDate) : crcTransferRequests.OrderByDescending(x => x.CreateDate);
            }
            else if (sortColumnIndex == 7)
            {
                crcTransferRequests = sortDirection == "asc" ? crcTransferRequests.OrderBy(x => x.ComponentReceiveDate) : crcTransferRequests.OrderByDescending(x => x.ComponentReceiveDate);
            }

            var totalRecords = crcTransferRequests.Count();
            var displayResult = crcTransferRequests.Skip(parameters.iDisplayStart).Take(parameters.iDisplayLength)
                .Select(x => new InternalRequestListView
                {
                    TransferWorkOrder = x.TransferWorkOrder,
                    DocumentId = x.DocumentId,
                    CurrentWorkOrder = x.CurrentWorkOrder,
                    CreateDate = x.CreateDate.Value,
                    ComponentReceiveDate = x.ComponentReceiveDate.Value,
                    CreateUserName = x.CreateUser,
                    CreateUserDisplayName = x.CreateUserDisplayName,
                    CustomerName = x.Customer.Name,
                    GroupName = x.Group.Name,
                    Id = x.Id,
                    RequestNumber = x.RequestNumber,
                    Status = (int)x.Status,
                    SubProductName = x.SubProduct.Name,
                    ComponentSerialNo = x.ComponentSerialNo,
                    Components = x.InternalRequestComponents.Select(y => new InternalRequestComponentListView
                    {
                        GroupName = y.Group.Name,
                        PartsName = y.PartsName,
                        ReceptionId = 0,
                        Status = (int)y.Status
                    }).ToList()
                })
                .ToList();

            return new CrcTransferRequestsResponse
            {
                TotalRecordsCount = totalRecords,
                Items = displayResult
            };
        }

        public InternalRequestDetailView GetInternalRequest(Guid id)
        {
            var crcTransferRequest = _unitOfWork.Context.InternalRequest.FirstOrDefault(x => x.Id == id);
            if (crcTransferRequest == null)
            {
                return null;
            }

            var crcFiles = _unitOfWork.Context.Uploads.Where(x => x.DocumentId == crcTransferRequest.DocumentId);
            var arrivalType = _unitOfWork.Context.CrcRequestConstants.Where(x => x.ParameterType.Trim() == CrcConstants.ArrivalType).FirstOrDefault(x => x.ParameterOrder == crcTransferRequest.ComponentArrivalType);
            var crcTransferDetailModel = new InternalRequestDetailView
            {
                ArrivalType = arrivalType?.ParameterOrder ?? 0,
                ArrivalTypeName = arrivalType?.ParameterValue,
                ComponentArrivalReason = crcTransferRequest.ComponentArrivalReason.Value,
                ComponentReceiveDate = crcTransferRequest.ComponentReceiveDate,
                ComponentSendDate = crcTransferRequest.ComponentSendDate,
                ComponentSerialNo = crcTransferRequest.ComponentSerialNo,
                CreateUser = crcTransferRequest.CreateUser,
                CreateUserDisplayName = crcTransferRequest.CreateUserDisplayName,
                CurrentWorkOrder = crcTransferRequest.CurrentWorkOrder,
                CustomerName = crcTransferRequest.Customer.Name,
                DocumentId = crcTransferRequest.DocumentId,
                EquipmentWorkingHours = (int?)crcTransferRequest.EquipmentWorkingHours,
                FaultDescription = crcTransferRequest.Description,
                GroupName = crcTransferRequest.Group.Name,
                Id = crcTransferRequest.Id,
                PlannedRevision = crcTransferRequest.PlannedRevision,
                SubProductName = crcTransferRequest.SubProduct.Name,
                TransferWorkOrder = crcTransferRequest.TransferWorkOrder,
                UpdateUser = crcTransferRequest.UpdateUser,
                UpdateUserDisplayName = crcTransferRequest.UpdateUserDisplayName,
                Files = crcFiles.Where(f => f.TypeId == (int)UploadType.InternalRequest).ToList(),
                GroupId = crcTransferRequest.GroupId,
                CustomerId = crcTransferRequest.CustomerId,
                CustomerNumber = crcTransferRequest.Customer.Code,
                SubProductId = crcTransferRequest.SubProductId,
                Components = crcTransferRequest.InternalRequestComponents.Select(y =>
                    new InternalRequestComponentDetailView
                    {
                        Id = y.Id,
                        GroupName = y.Group.Name,
                        GroupId = y.GroupId,
                        ComponentCode = y.ComponentCode,
                        Description = y.Description,
                        ItemNumber = y.RowNumber,
                        JobCode = y.JobCode,
                        PartsName = y.PartsName,
                        Quantity = (int?)y.Quantity,
                        RequestedWork = y.RequestedWork,
                        Files = crcFiles.Where(f => f.TypeId == (int)UploadType.InternalRequestComponent && f.ReferenceId == y.RowNumber).ToList(),
                        ComponentId = y.ComponentId
                    }).OrderBy(x => x.ItemNumber).ToList()
            };

            return crcTransferDetailModel;
        }

        private bool CheckArrivalReasonComponents(Guid? componentArrivalReason)
        {
            return componentArrivalReason == Guid.Parse("8E68BAAF-BC71-4E87-8DAF-B6C4CFF1C605")
                || componentArrivalReason == Guid.Parse("52025E1D-2464-49EE-8A37-ABDFBC5A1E8C")
                || componentArrivalReason == Guid.Parse("BB94188D-E645-411E-9FE0-9A6BC54DCCDE")
                || componentArrivalReason == Guid.Parse("C7D20468-C16A-4D50-A7F0-0FDCF2CB5D69")
                || componentArrivalReason == Guid.Parse("E8F680AB-814A-4C06-94BF-D71368DC7E62");
        }
    }
}