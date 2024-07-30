using Newtonsoft.Json;
using Sniper.Api.Authorization;
using Sniper.Api.Util.Log;
using Sniper.Core.Models.Common;
using Sniper.Core.Models.DataModels.Customer;
using Sniper.Core.Models.EntityModels.FieldWork;
using Sniper.Core.Models.Enums.FieldWork;
using System;
using System.Configuration;
using System.IO;
using System.Net;
using System.Net.Http;
using System.Threading.Tasks;
using System.Web;
using System.Web.Http;
using System.Web.Http.Description;
using System.Linq.Expressions;
using System.Linq;
using System.Collections.Generic;
using NReco;
using Sniper.Core.Service.BorusanCat;
using Sniper.Core.Models.Customer.Detail;
using AutoMapper;
using Sniper.Core.Models.Customer;
using Sniper.Api.Util.WebService;
using Sniper.Api.BorusanService;
using Sniper.Core.Context;
using System.Net.Http.Headers;

namespace Sniper.Api.Controllers
{
#if (!DEBUG)
    [Authorize(Roles = SniperRoles.SniperBaseUser)]
#endif
    [RoutePrefix("sniperapp/fieldwork")]
    public class FieldWorkController : ApiController
    {
        ApplicationDbContext db = new ApplicationDbContext();
        LogUtil logger = new LogUtil(typeof(FieldWorkController));
        private WsClient _client;
        string path = ConfigurationManager.AppSettings["CustomerFielWorkDocPath"];
        string formTemplatePath = ConfigurationManager.AppSettings["FormHtmlTemplatePath"];
        NReco.PdfGenerator.HtmlToPdfConverter htmlToPdf;

        public FieldWorkController()
        {
            _client = new WsClient();
            htmlToPdf = new NReco.PdfGenerator.HtmlToPdfConverter();
        }
        [Route("Save")]
        [HttpPost]
        [ResponseType(typeof(ResponseModel))]
        public async Task<HttpResponseMessage> AddFieldWork()
        {
            try
            {
                if (!Request.Content.IsMimeMultipartContent("form-data"))
                    throw new HttpResponseException(HttpStatusCode.UnsupportedMediaType);

                var formData = JsonConvert.DeserializeObject<CustomerFieldWorkRequest>(HttpContext.Current.Request.Form.Get("form"));
                formData.DocumentCount = HttpContext.Current.Request.Files.Count;

                this.Validate(formData);

                if (!ModelState.IsValid)
                    return Request.CreateResponse(HttpStatusCode.BadRequest, ModelState.Values.Aggregate(
                            new List<string>(),
                            (a, c) =>
                            {
                                a.AddRange(c.Errors.Select(r => r.ErrorMessage));
                                return a;
                            },
                            a => a
                        ));

                string windUser = AuthUtil.GetUserDataDefault(Request).WindowsUser;
                string userFullName = AuthUtil.GetUserDataDefault(Request).UserFullName;
                Guid newFieldWork = Guid.NewGuid();

                CustomerFieldWork customerFieldWork = new CustomerFieldWork
                {
                    Application = formData.Application,
                    Brand = formData.Brand,
                    Model = formData.Model,
                    BucketCapacity = formData.BucketCapacity,
                    CompetitorMachine = formData.CompetitorMachine,
                    Configuration = formData.Configuration,
                    CreateDate = DateTime.Now,
                    CustomerComment = formData.CustomerComment,
                    CustomerName = formData.CustomerName,
                    Efficiency = formData.Efficiency ?? 0,
                    Fuel = formData.Fuel,
                    LoadingVehicle = formData.LoadingVehicle,
                    MaterialDensity = formData.MaterialDensity,
                    MaterialName = formData.MaterialName,
                    OperatorComment = formData.OperatorComment,
                    Production = formData.Production,
                    ProductionYear = formData.ProductionYear,
                    ReferenceDocument = formData.ReferenceDocument,
                    SalesRepresantativeComment = formData.SalesRepresantativeComment,
                    TotalWorkingTime = formData.TotalWorkingTime ?? 0,
                    CustomerNumber = formData.CustomerNumber,
                    CreateUser = string.IsNullOrEmpty(windUser) == false ? windUser.ToLower() : null,
                    CreatorFullName = AuthUtil.GetUserDataDefault(Request).UserFullName,
                    FieldWorkId = newFieldWork
                };

                db.CustomerFieldWorks.Add(customerFieldWork);
                db.SaveChanges();

                formData.FieldWorkId = customerFieldWork.FieldWorkId;
                formData.CreateUser = customerFieldWork.CreateUser;
                formData.CreateDate = customerFieldWork.CreateDate;

                var postedFiles = HttpContext.Current.Request.Files;

                string fullPath = path + "\\" + customerFieldWork.FieldWorkId.ToString();

                DirectoryInfo directoryInfo = new DirectoryInfo(fullPath);

                if (!Directory.Exists(fullPath))
                {
                    directoryInfo = Directory.CreateDirectory(fullPath);
                }

                if (postedFiles.Count > 0)
                {
                    int counter = 0;

                    foreach (string file in postedFiles)
                    {
                        var postedFile = HttpContext.Current.Request.Files[counter];

                        if (postedFile != null && !string.IsNullOrEmpty(postedFile.FileName))
                        {
                            postedFile.SaveAs(Path.Combine(fullPath, postedFile.FileName));

                            Upload upload = new Upload
                            {
                                FileId = Guid.NewGuid(),
                                FieldWorkId = customerFieldWork.FieldWorkId,
                                CreateDate = DateTime.Now,
                                FileName = postedFile.FileName,
                                Path = directoryInfo.FullName,
                                Type = (int)UploadType.CustomerFieldWorkForm,
                                Size = postedFile.ContentLength
                            };

                            db.Uploads.Add(upload);
                            db.SaveChanges();

                            counter++;
                        }
                    }
                }

                FormToPdf(formData, AuthUtil.GetUserDataDefault(Request).MobileLanguage);

                return Request.CreateResponse(HttpStatusCode.OK, formData);
            }
            catch (Exception ex)
            {
                logger.Error(ex);
                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }

        [Route("models/{brand}")]
        [HttpGet]
        [ResponseType(typeof(ResponseModel))]
        public HttpResponseMessage Categories([FromUri] string brand)
        {
            try
            {
                if (brand.ToLower() == "cat")
                {
                    BorusanCatService borusanCatService = new BorusanCatService();
                    var brands = borusanCatService.GetBrands(AuthUtil.GetUserDataDefault(Request).MobileLanguage);

                    return Request.CreateResponse(HttpStatusCode.OK, brands);
                }
                else
                {
                    var username = AuthUtil.GetUserDataDefault(Request).SapUser;

                    var response = _client.MakeRequest(c => c.ZXX_FM_REKP_RAKIP_URUN(new ZXX_FM_REKP_RAKIP_URUNRequest
                    {
                        ZXX_FM_REKP_RAKIP_URUN = new ZXX_FM_REKP_RAKIP_URUN
                        {
                            IV_USER_NAME = username.ToUpper()
                        }
                    }));

                    var model = Mapper.Map<ResponseModel<List<OtherEquipmentModel>>>(response);

                    return Request.CreateResponse(HttpStatusCode.OK, model.Data.Select(x => x.Name).ToArray());
                }
            }
            catch (Exception ex)
            {
                logger.Error(ex);

                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }

        [Route("customers/{username}")]
        [HttpGet]
        [ResponseType(typeof(ResponseModel))]
        public HttpResponseMessage AllCustomer([FromUri] string username)
        {
            try
            {
                var response = _client.MakeRequest(x => x.ZXX_FM_MUS_GET(new ZXX_FM_MUS_GETRequest
                {
                    ZXX_FM_MUS_GET = new ZXX_FM_MUS_GET
                    {
                        IV_USER_NAME = username.ToUpper()
                    }
                }));

                var model = Mapper.Map<ResponseModel<CustomerModel>>(response);

                return Request.CreateResponse(HttpStatusCode.OK, model);
            }
            catch (Exception ex)
            {
                logger.Error(ex);

                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }

        [Route("users")]
        [HttpGet]
        [ResponseType(typeof(ResponseModel))]
        public HttpResponseMessage FieldWorkUsers()
        {
            try
            {
                var users = db.CustomerFieldWorks.Select(x => new { UserFullName = x.CreatorFullName ?? "", UserId = x.CreateUser }).ToList();

                return Request.CreateResponse(HttpStatusCode.OK, users.Distinct());
            }
            catch (Exception ex)
            {
                logger.Error(ex);

                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }

        [Route("fieldrecords")]
        [HttpPost]
        [ResponseType(typeof(ResponseModel))]
        public HttpResponseMessage QueryRecords([FromBody] FieldWorkRequest fieldWorkRequest)
        {
            try
            {
                var userRecords = from h in (
                                    from x in db.CustomerFieldWorks
                                    orderby x.CreateDate descending
                                    where (string.IsNullOrEmpty(fieldWorkRequest.UserName) == true || x.CreateUser == fieldWorkRequest.UserName)
                                            &&
                                           (string.IsNullOrEmpty(fieldWorkRequest.Brand) == true || fieldWorkRequest.Brand == x.Brand)
                                           &&
                                           (string.IsNullOrEmpty(fieldWorkRequest.Model) == true || fieldWorkRequest.Model == x.Model)
                                           &&
                                           ((string.IsNullOrEmpty(fieldWorkRequest.CustomerNo) == true) || (fieldWorkRequest.CustomerNo == x.CustomerNumber))
                                    select x
                                           ).ToList()
                                  select new FieldWorkResponse
                                  {
                                      FieldId = h.FieldWorkId,
                                      Brand = h.Brand,
                                      CreateDate = h.CreateDate.ToString("yyyy-MM-dd HH:mm"),
                                      Creator = h.CreateUser,
                                      CustomerName = h.CustomerName,
                                      Model = h.Model,
                                      FileList = (from a in (from b in db.Uploads
                                                             where b.FieldWorkId == h.FieldWorkId
                                                             select b).AsEnumerable()
                                                  select new UploadFiles
                                                  {
                                                      FileId = a.FileId,
                                                      FileName = Path.GetFileNameWithoutExtension(Path.Combine(a.Path, a.FileName)),
                                                      UploadDate = a.CreateDate.ToString("yyyy-MM-dd HH:mm"),
                                                      Size = a.Size,
                                                      FileType = a.Type,
                                                      MimeType = MimeMapping.GetMimeMapping(a.FileName)
                                                  })
                                  };

                if (fieldWorkRequest.NumberOfRecords != null && fieldWorkRequest.NumberOfRecords > 0)
                {
                    userRecords = userRecords.Take(fieldWorkRequest.NumberOfRecords ?? 1);
                }
                return Request.CreateResponse(HttpStatusCode.OK, userRecords.ToList());
            }
            catch (Exception ex)
            {
                logger.Error(ex);

                return Request.CreateResponse(HttpStatusCode.InternalServerError);
            }
        }

        [Route("GetFile")]
        [HttpGet]
        [ResponseType(typeof(ResponseModel))]
        public HttpResponseMessage GetFile(Guid fileId)
        {
            var files = db.Uploads.Where(x => x.FileId == fileId).Select(x => x).FirstOrDefault();

            if (files == null)
            {
                return new HttpResponseMessage(HttpStatusCode.NotFound);
            }

            HttpResponseMessage response = Request.CreateResponse(HttpStatusCode.OK);

            string filePath = Path.Combine(files.Path, files.FileName);


            //Check whether File exists.
            if (!File.Exists(filePath))
            {
                response.StatusCode = HttpStatusCode.NotFound;
                response.ReasonPhrase = string.Format("File not found: {0} .", files.FileName);
                throw new HttpResponseException(response);
            }

            byte[] bytes = File.ReadAllBytes(filePath);

            response.Content = new ByteArrayContent(bytes);

            response.Content.Headers.ContentLength = bytes.LongLength;
            response.Content.Headers.ContentDisposition = new ContentDispositionHeaderValue("attachment");
            response.Content.Headers.ContentDisposition.FileName = files.FileName;

            //Set the File Content Type.
            response.Content.Headers.ContentType = new MediaTypeHeaderValue(MimeMapping.GetMimeMapping(files.FileName));
            return response;
        }

        private bool FormToPdf(CustomerFieldWorkRequest request, string language)
        {
            try
            {
                string fileName = string.Format("{0}_{1}", request.Model, request.CreateUser);

                string html = File.ReadAllText(Path.Combine(formTemplatePath, string.Format("CustomerFieldWorkForm_{0}.html", language)));

                html = string.Format(
                    html,
                    DateTime.Now.ToString("yyyy-MM-dd HH:mm"),
                    request.FieldWorkId,
                    request.CustomerName,
                    request.Application,
                    request.Brand,
                    request.Model,
                    request.MaterialName,
                    request.MaterialDensity,
                    request.ProductionYear,
                    request.BucketCapacity,
                    request.Configuration,
                    request.LoadingVehicle,
                    request.CompetitorMachine,
                    Math.Round((request.TotalWorkingTime ?? 0), 0),
                    request.Fuel,
                    request.Production,
                    request.Efficiency,
                    request.OperatorComment,
                    request.CustomerComment,
                    request.SalesRepresantativeComment,
                    request.ReferenceDocument);

                byte[] pdfBytes = htmlToPdf.GeneratePdf(html);


                using (var fs = new FileStream(Path.Combine(path, request.FieldWorkId.ToString(), (fileName + ".pdf")), FileMode.Create, FileAccess.Write))
                {
                    fs.Write(pdfBytes, 0, pdfBytes.Length);
                }
                DirectoryInfo directoryInfo = new DirectoryInfo(path + "\\" + request.FieldWorkId.ToString());

                Upload upload = new Upload
                {
                    FileId = Guid.NewGuid(),
                    FieldWorkId = request.FieldWorkId,
                    CreateDate = DateTime.Now,
                    FileName = (fileName + ".pdf"),
                    Path = (directoryInfo != null ? directoryInfo.FullName : ""),
                    Type = (int)UploadType.CustomerFieldWorkAttachements,
                    Size = new FileInfo(Path.Combine(path, request.FieldWorkId.ToString(), (fileName + ".pdf"))).Length
                };

                db.Uploads.Add(upload);
                db.SaveChanges();

                return true;
            }
            catch (Exception ex)
            {
                logger.Error(ex);
                return false;
            }
        }
    }
}

