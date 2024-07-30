using System.Configuration;
using System.Dynamic;
using System.Net;
using System.Net.Http;
using System.Web.Http;
using AutoMapper;
using RestSharp;
using Sniper.Api.Authorization;
using Sniper.Api.BorusanService;
using Sniper.Api.Util.Cache;
using Sniper.Api.Util.Log;
using Sniper.Api.Util.WebService;
using Sniper.Core.Models.Common;
using Sniper.Core.Models.Customer;
using Sniper.Core.Models.Customer.Detail;
using System.Collections.Generic;
using Sniper.Core.SAPRest;
using System.Web.Http.Description;
using Sniper.Api.NotificationExtensions;
using Sniper.Api.Handlers;
using Sniper.Core.Service.CrcOrganizationServices;
using Sniper.Core.Utils.ConfigHelper;
using Sniper.Core.ExceptionHandling;
using System.Linq;
using System.Linq.Expressions;
using Sniper.Core.Models.EntityModels.Customer.Search;
using Sniper.Core.Models.EntityModels.Customer.Service;
using Sniper.Core.Models.EntityModels.Customer.Service.Detail;

namespace Sniper.Api.Controllers
{
#if(!DEBUG)
    [Authorize(Roles = SniperRoles.SniperBaseUser)]
#endif
    [RoutePrefix("sniperapp/customer")]
    public class CustomerController : ApiController
    {
        private WsClient _client;

        private LogUtil _logger;

        //private WsClientSniper _clientsniper;
        private IRestClient _restClient;

        public CustomerController()
        {
            _client = new WsClient();
            _logger = new LogUtil(GetType());
            //_clientsniper = new WsClientSniper();
            _restClient = new RestClient(ConfigurationManager.AppSettings["CmsApiUrlBase"]);
        }

        [Route("search")]
        [HttpPost]
        [CacheInvalidate]
        [SniperOutputCache(type: CacheType.Short)]
        public HttpResponseMessage GetAll([FromBody] Search search)
        {
            CustomerResult customerResult = new CustomerResult();
            customerResult = SAPRestService.GetCustomer(search);

            if (customerResult == null)
            {
                return Request.CreateResponse(HttpStatusCode.OK, customerResult);
            }

            var addresses = customerResult.Export?.EtAdress;
            var equipments = customerResult.Export?.EtIkon;

            List<CustomerItemModel> customerItemModel = customerResult.Export?.EtMu.Select(x => new CustomerItemModel
            {
                CustomerId = x.Mus_Bp,
                CustomerName = x.NameOrg1,
                Id = x.Mus_Bp,
                HasFinancialProblem = equipments.Where(y => y.Mus_Bp == x.Mus_Bp).Select(y => !string.IsNullOrEmpty(y.Borc)).FirstOrDefault(),
                YPOccasionCount = equipments.Where(y => y.Mus_Bp == x.Mus_Bp).Select(y => System.Convert.ToInt32(y.YpFirsat)).FirstOrDefault(),
                MachineOpportunityCount = equipments.Where(y => y.Mus_Bp == x.Mus_Bp).Select(y => System.Convert.ToInt32(y.MakFirsat)).FirstOrDefault(),
                WorkOrderCount = equipments.Where(y => y.Mus_Bp == x.Mus_Bp).Select(y => System.Convert.ToInt32(y.IsEmir)).FirstOrDefault(),
                OrderCount = equipments.Where(y => y.Mus_Bp == x.Mus_Bp).Select(y => System.Convert.ToInt32(y.MusSip)).FirstOrDefault(),
                OfferCount = equipments.Where(y => y.Mus_Bp == x.Mus_Bp).Select(y => System.Convert.ToInt32(y.Teklif)).FirstOrDefault(),
                IssueCount = equipments.Where(y => y.Mus_Bp == x.Mus_Bp).Select(y => System.Convert.ToInt32(y.Sikayet)).FirstOrDefault(),
                CatEquipmentCount = equipments.Where(y => y.Mus_Bp == x.Mus_Bp).Select(y => System.Convert.ToInt32(y.Cat)).FirstOrDefault(),
                NonCatEquipmentCount = equipments.Where(y => y.Mus_Bp == x.Mus_Bp).Select(y => System.Convert.ToInt32(y.NCat)).FirstOrDefault(),
                TelNumber = addresses.Where(y => y.Mus_Bp == x.Mus_Bp).Select(y => y.TelNo).FirstOrDefault(),
                RegionText = addresses.Where(y => y.Mus_Bp == x.Mus_Bp).Select(y => y.RegionText).FirstOrDefault(),
                City = addresses.Where(y => y.Mus_Bp == x.Mus_Bp).Select(y => y.City1).FirstOrDefault(),
                County = addresses.Where(y => y.Mus_Bp == x.Mus_Bp).Select(y => y.City2).FirstOrDefault(),
                Street = addresses.Where(y => y.Mus_Bp == x.Mus_Bp).Select(y => y.Street).FirstOrDefault(),
                Relations = x.Relations
            }).ToList();
            return Request.CreateResponse(HttpStatusCode.OK, customerItemModel);
        }

        [Route("{userName}/{customerid}")]
        [HttpGet]
        [CacheInvalidate]
        [SniperOutputCache(type: CacheType.Short)]
        public HttpResponseMessage GetCustomerDetail(string userName, string customerid)
        {
            var response = _client.MakeRequest(x => x.ZXX_FM_MUS_GET(new ZXX_FM_MUS_GETRequest
            {
                ZXX_FM_MUS_GET = new ZXX_FM_MUS_GET
                {
                    IV_USER_NAME = userName.ToUpper()
                }
            }));

            var model = Mapper.Map<ResponseModel<CustomerModel>>(response);

            var customerItemModel = model?.Data?.CustomerList.Where(X => X.CustomerId == customerid).Select(x => x).FirstOrDefault();
            return Request.CreateResponse(HttpStatusCode.OK, customerItemModel);
        }

        [Route("{userName}/{language}/{id}")]
        [HttpGet]
        [CacheInvalidate]
        [SniperOutputCache(type: CacheType.Short)]
        public HttpResponseMessage GetCustomerDetail([FromUri] string userName, [FromUri] string language,
            [FromUri] string id, [FromUri] bool isPSSR = false)
        {
            try
            {
                List<string> messages;

                var userAgent = Request.Headers.UserAgent.ToString();

                _logger.Info("Call to " + Request.RequestUri + " , with useragent: " + Request.Headers.UserAgent.ToString());

                var response = _client.MakeRequest(x => x.ZXX_FM_MUS_DETAY(new ZXX_FM_MUS_DETAYRequest
                {
                    ZXX_FM_MUS_DETAY = new ZXX_FM_MUS_DETAY
                    {
                        IV_USER_NAME = userName.ToUpper(),
                        IV_MUS_BP = id,
                        IV_OTHER = isPSSR ? "X" : ""

                    }
                }));

                var model = Mapper.Map<ResponseModel<CustomerDetailModel>>(response);

                if (model != null && model.Data.WorkOrders.Count > 0)
                {
                    model.Data.WorkOrders.ForEach((item) =>
                    {
                        try
                        {
                            item.WorkOrderStatus = CrcFactory.GetInstance(item.ServiceOrganizationCode).GetWorkOrderStatus(item.WorkOrderNumber, out messages).Status;
                        }
                        catch (CrcFactoryException ex)
                        {
                            item.WorkOrderStatus = "";
                        }
                    });
                }
                return Request.CreateResponse(HttpStatusCode.OK, model);
            }
            catch (System.Exception ex)
            {

                throw;
            }
            
        }


        [Route("edit/address/{userName}/{customerId}")]
        [HttpPost]
        public HttpResponseMessage EditCustomerAddress([FromUri] string userName, [FromUri] string customerId,
            [FromBody] AddressModel address)
        {
            _logger.Info("Call EditCustomerAddress with parameters latitude " + address.Latitude + " and longtitude  " + address.Longitude);


            var response = _client.MakeRequest(c => c.ZXX_FM_MUS_ADR_SET(new ZXX_FM_MUS_ADR_SETRequest
            {
                ZXX_FM_MUS_ADR_SET = new ZXX_FM_MUS_ADR_SET
                {
                    IV_MUS_BP = customerId,
                    IV_USER_NAME = userName.ToUpper(),
                    IS_ADRES = Mapper.Map<ZXX_S_MUS_ADRS>(address)
                }
            }));

            var model = Mapper.Map<ResponseModel<ExpandoObject>>(response);

            if (model != null && model.StatusCode == 0)
            {
                ///işlem başarılı olmuşsa mail atılsın...
                NotificationRequestModel<AddressModel> notificationRequestModel = new NotificationRequestModel<AddressModel>
                {
                    ActionType = "U",
                    CountryCode = AuthUtil.GetUserDataDefault(Request).CountryCode,
                    CustomerId = customerId,
                    NewModel = address,
                    NotifiedAction = NotificationSchemaConstants.addUpdateCustomerAddress,
                    UserName = userName
                };

                NotificationHandler<AddressModel>.InsertNotification(notificationRequestModel);
            }
            return Request.CreateResponse(HttpStatusCode.OK, model);
        }

        [Route("add/address/{userName}/{customerId}")]
        [HttpPost]
        public HttpResponseMessage AddCustomerAddress([FromUri] string userName, [FromUri] string customerId,
            [FromBody] AddressModel address)
        {

            _logger.Info("Call AddCustomerAddress with parameters latitude " + address.Latitude + " and longtitude  " + address.Longitude);

            var response = _client.MakeRequest(c => c.ZXX_FM_MUS_ADR_ADD(new ZXX_FM_MUS_ADR_ADDRequest
            {
                ZXX_FM_MUS_ADR_ADD = new ZXX_FM_MUS_ADR_ADD
                {
                    IV_MUS_BP = customerId,
                    IV_USER_NAME = userName.ToUpper(),
                    IS_ADRES = Mapper.Map<ZXX_S_MUS_ADRS_A>(address)
                }
            }));

            var model = Mapper.Map<ResponseModel<string>>(response);

            if (model != null && model.StatusCode == 0)
            {

                address.Id = model.Data;
                ///işlem başarılı olmuşsa mail atılsın...
                NotificationRequestModel<AddressModel> notificationRequestModel = new NotificationRequestModel<AddressModel>
                {
                    ActionType = "A",
                    CountryCode = AuthUtil.GetUserDataDefault(Request).CountryCode,
                    CustomerId = customerId,
                    NewModel = address,
                    NotifiedAction = NotificationSchemaConstants.addUpdateCustomerAddress,
                    UserName = userName
                };

                NotificationHandler<AddressModel>.InsertNotification(notificationRequestModel);
            }

            return Request.CreateResponse(HttpStatusCode.OK, model);
        }

        [Route("address/{userName}/{customerId}")]
        [HttpGet]
        [CacheInvalidate]
        [SniperOutputCache(type: CacheType.Short)]
        public HttpResponseMessage GetCustomerAddresses([FromUri] string userName, [FromUri] string customerId)
        {
            var response = _client.MakeRequest(x => x.ZXX_FM_MUS_DETAY(new ZXX_FM_MUS_DETAYRequest
            {
                ZXX_FM_MUS_DETAY = new ZXX_FM_MUS_DETAY
                {
                    IV_USER_NAME = userName.ToUpper(),
                    IV_MUS_BP = customerId,
                    IV_ADRES = "X"
                }
            }));

            var model = Mapper.Map<ResponseModel<FieldNameModel>>(response);

            return Request.CreateResponse(HttpStatusCode.OK, model);
        }

        [Route("refDocuments/{userName}/{customerid?}")]
        [HttpGet]
        [ResponseType(typeof(ResponseModel))]
        public HttpResponseMessage GetCustomerReferenceDocuments([FromUri] string userName, [FromUri] string customerid = "")
        {
            List<string> messages;
            var model = SAPRestService.GetCustomerReferenceDocuments(userName.ToUpper(), AuthUtil.GetUserDataDefault(Request).MobileLanguageShort, customerid, out messages);

            ResponseModel<GetCustomerReferenceDocumentsResult> res = new ResponseModel<GetCustomerReferenceDocumentsResult>();

            if (model != null)
            {
                res.Status = Core.Models.Common.ResponseStatus.Success.ToString("f");
                res.StatusCode = (int)Core.Models.Common.ResponseStatus.Success;
                res.Data = model;
            }
            else
            {
                res.Status = Core.Models.Common.ResponseStatus.SapError.ToString("f");
                res.StatusCode = (int)Core.Models.Common.ResponseStatus.SapError;
                res.Messages = messages;
            }

            return Request.CreateResponse(HttpStatusCode.OK, res);
        }

        [Route("woStatus/{organizationUnit}/{woNumber}")]
        [HttpGet]
        [ResponseType(typeof(ResponseModel))]
        public HttpResponseMessage GetWoStatus([FromUri] string organizationUnit, [FromUri] string woNumber = "")
        {

            List<string> messages;
            var model = CrcFactory.GetInstance(organizationUnit).GetWorkOrderStatus(woNumber, out messages); ;

            ResponseModel<WorkorderStatusResponse> res = new ResponseModel<WorkorderStatusResponse>();

            if (model != null)
            {
                res.Status = Core.Models.Common.ResponseStatus.Success.ToString("f");
                res.StatusCode = (int)Core.Models.Common.ResponseStatus.Success;
                res.Data = model;
            }
            else
            {
                res.Status = Core.Models.Common.ResponseStatus.CrcError.ToString("f");
                res.StatusCode = (int)Core.Models.Common.ResponseStatus.CrcError;
                res.Messages = messages;
            }


            return Request.CreateResponse(HttpStatusCode.OK, res);
        }

        [Route("industrycode/{equipmentno}")]
        [HttpGet]
        [ResponseType(typeof(ResponseModel))]
        public HttpResponseMessage GetIndustryCode([FromUri] string equipmentno)
        {
            var model = SAPRestService.GetIndustryCode(equipmentno);

            ResponseModel<IndustryCodeResult> res = new ResponseModel<IndustryCodeResult>();

            if (model != null)
            {
                res.Status = Core.Models.Common.ResponseStatus.Success.ToString("f");
                res.StatusCode = (int)Core.Models.Common.ResponseStatus.Success;
                res.Data = model;
            }
            else
            {
                res.Status = Core.Models.Common.ResponseStatus.CrcError.ToString("f");
                res.StatusCode = (int)Core.Models.Common.ResponseStatus.CrcError;
                res.Messages = null;
            }

            return Request.CreateResponse(HttpStatusCode.OK, res);
        }

        [Route("servicequotation/{username}/{customerno?}")]
        [HttpPost]        
        [ResponseType(typeof(ResponseModel))]
        public HttpResponseMessage GetServiceQuotList([FromUri] string username, [FromBody] List<string> status, [FromUri] string customerno = "")
        {            
            var model = SAPRestService.CustomerServiceQuotList(username.ToUpper(), customerno, status);

            ResponseModel<CustomerServiceResult> res = new ResponseModel<CustomerServiceResult>();
            string statu = Core.Models.Common.ResponseStatus.Success.ToString("f");
            res.Status = statu;
            res.StatusCode = (int)Core.Models.Common.ResponseStatus.Success;
            res.Data = model;

            return Request.CreateResponse(HttpStatusCode.OK, res);
        }

        [Route("servicequotationdetail/{objectid}")]
        [HttpGet]
        [ResponseType(typeof(ResponseModel))]
        public HttpResponseMessage GetServiceQuotList([FromUri] string objectid)
        {
            var model = SAPRestService.CustomerServiceQuotDetail(objectid);

            ResponseModel<CustomerServiceDetailResult> res = new ResponseModel<CustomerServiceDetailResult>();
            string statu = Core.Models.Common.ResponseStatus.Success.ToString("f");
            res.Status = statu;
            res.StatusCode = (int)Core.Models.Common.ResponseStatus.Success;
            res.Data = model;

            return Request.CreateResponse(HttpStatusCode.OK, res);
        }
    }
}
