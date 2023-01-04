using System;
using System.Configuration;
using System.IO;
using System.Linq;
using System.Net;
using System.Net.Http;
using System.Net.Http.Formatting;
using System.Net.Http.Headers;
using System.Text;
using System.Text.RegularExpressions;
using System.Web;
using System.Web.Http;
using AutoMapper;
using Base62;
using Newtonsoft.Json;
using RestSharp;
using Sniper.Api.Util.ExceptionFilters;
using Sniper.Core.Models;
using Sniper.Core.Models.Common;
using Sniper.Core.Models.Image;

namespace Sniper.Api.Controllers
{
    //[Authorize(Roles = SniperRoles.SniperBaseUser)]  TODO: client duzelttikten sonra ac
    [FileNotFoundExceptionFilter]
    [RoutePrefix("sniperapp/media")]
    public class MediaController : ApiController
    {
        private readonly IRestClient _restClient;

        public MediaController()
        {
            _restClient = new RestClient(ConfigurationManager.AppSettings["CmsApiUrlBase"]);
        }

        [Route("file/{isPublic}/{id}")]
        public HttpResponseMessage Get([FromUri] string id, [FromUri] bool isPublic = false)
        {
            var message = new HttpResponseMessage(HttpStatusCode.OK);

            if (id.Contains(".mp4"))
            {
                return StreamVideo(id, isPublic);
            }

            if (id.Contains("@")) // If id contains @ that means its a file system report
            {
                return GetFileSystemReport(id.TrimStart('@'));
            }

            var model = SendMediaRequest(id, isPublic);

            if (model.Messages.Count > 0) //if an error has occured (media not found)
            {
                message.Content = new ObjectContent<ResponseModel<MediaModel>>(model, new JsonMediaTypeFormatter());
            }
            else //no errors
            {
                message.Content = new ByteArrayContent(File.ReadAllBytes(model.Data.Path));

                message.Content.Headers.ContentDisposition = new ContentDispositionHeaderValue("attachment")
                {
                    FileName = model.Data.FileName,
                };

                message.Content.Headers.ContentType = new MediaTypeHeaderValue(model.Data.MimeType);
            }

            return message;
        }

        [Route("image")]
        public HttpResponseMessage GetImage([FromUri] ImageRequest image)
        {
            var message = new HttpResponseMessage(HttpStatusCode.OK);
            var client = new RestClient(ConfigurationManager.AppSettings["CmsUrlBase"]); //init new client
            client.ClearHandlers(); //restclient always adds accept:application/json, remove that behavor.
            var fileName = string.Empty;
            image.Path = HttpUtility.UrlDecode(image.Path);

            if (!string.IsNullOrEmpty(image.Path))
            {
                image.Path = Encoding.UTF8.GetString(Convert.FromBase64String(image.Path));
            }

            if (!string.IsNullOrEmpty(image.Path))
            {
                fileName =
                     image.Path.Split(new[] { "?" }, StringSplitOptions.None)[0].Split(new[] { "/" }, StringSplitOptions.None)[3];

                if (!image.IsThumbnail)
                {
                    image.Path = image.Path.Split(new[] { "?" }, StringSplitOptions.None)[0];
                    fileName = image.Path.Split(new[] { "/" }, StringSplitOptions.None)[3];
                }
            }

            var request = new RestRequest(image.Path);
            var response = client.Get(request);

            if (response.StatusCode == HttpStatusCode.OK)
            {
                message.Content = new ByteArrayContent(response.RawBytes);
                message.Content.Headers.ContentDisposition = new ContentDispositionHeaderValue("attachment")
                {
                    FileName = fileName
                };
                message.Content.Headers.ContentType = new MediaTypeHeaderValue(response.ContentType);
            }
            else
            {
                message = Request.CreateErrorResponse(HttpStatusCode.NotFound, "image-not-found");
            }

            return message;

        }

        [Route("image/public/{documentId}")]
        public HttpResponseMessage GetPublicImage(int documentId)
        {
            var message = new HttpResponseMessage(HttpStatusCode.OK);
            var request = new RestRequest("/media/getpublicimage?documentId=" + documentId);
            var firstResponse = _restClient.Get(request);

            if (firstResponse.StatusCode != HttpStatusCode.NotFound)
            {
                var imagePath = JsonConvert.DeserializeObject<string>(firstResponse.Content);
                var client = new RestClient(ConfigurationManager.AppSettings["CmsUrlBase"]); //init new client
                client.ClearHandlers(); //restclient always adds accept:application/json, remove that behavor.
                var fileName =
                    imagePath.Split(new[] { "?" }, StringSplitOptions.None)[0].Split(new[] { "/" }, StringSplitOptions.None)
                        [3];

                request = new RestRequest(imagePath);

                var response = client.Get(request);

                if (response.StatusCode == HttpStatusCode.OK)
                {
                    message.Content = new ByteArrayContent(response.RawBytes);
                    message.Content.Headers.ContentDisposition = new ContentDispositionHeaderValue("attachment")
                    {
                        FileName = fileName
                    };
                    message.Content.Headers.ContentType = new MediaTypeHeaderValue(response.ContentType);
                }
                else
                {
                    message = Request.CreateErrorResponse(HttpStatusCode.NotFound, "image-not-found");
                }

                return message;
            }

            return Request.CreateErrorResponse(HttpStatusCode.NotFound, "image not found");

        }

        /// <summary>
        /// Not an Api
        /// Acts like a helper func
        /// </summary>
        /// <param name="fileId">File System Report id (contains @)</param>
        /// <returns></returns>
        private HttpResponseMessage GetFileSystemReport(string fileId)
        {
            var message = new HttpResponseMessage(HttpStatusCode.OK);
            try //try to readall bytes
            {
                fileId = new Base62Converter().Decode(fileId);

                message.Content = new ByteArrayContent(File.ReadAllBytes(fileId.Replace("@", "\\")));
                string filename = fileId.Split(new[] { "@" }, StringSplitOptions.None).ToList().Last();

                filename = Regex.Replace(filename, @"[^\u0000-\u007F]+", string.Empty);

                message.Content.Headers.ContentDisposition = new ContentDispositionHeaderValue("attachment")
                {
                    FileName = filename
                };

                message.Content.Headers.ContentType = new MediaTypeHeaderValue("application/octet-stream");

            }
            catch (Exception ex)
            {
                message = Request.CreateErrorResponse(HttpStatusCode.InternalServerError, ex.Message);
            }

            return message;
        }

        /// <summary>
        /// Not an Api
        /// Acts like a helper func
        /// </summary>
        /// <param name="id">mp4 id (contains .mp4)</param>
        /// <param name="isPublic"></param>
        /// <returns></returns>
        private HttpResponseMessage StreamVideo(string id, bool isPublic)
        {
            var message = new HttpResponseMessage(HttpStatusCode.OK);
            id = id.Replace(".mp4", string.Empty);

            var model = SendMediaRequest(id, isPublic);

            try
            {
                var bytes = File.ReadAllBytes(model.Data.Path);
                var stream = new MemoryStream(bytes);

                if (Request.Headers.Range != null)
                {
                    try
                    {
                        message = Request.CreateResponse(HttpStatusCode.PartialContent);
                        message.Content = new ByteRangeStreamContent(stream, Request.Headers.Range, "video/mp4");
                    }
                    catch (InvalidByteRangeException invalidByteRangeException)
                    {
                        return Request.CreateErrorResponse(invalidByteRangeException);
                    }
                }

                else
                {
                    message.Content = new ByteArrayContent(bytes);

                    message.Content.Headers.ContentType = new MediaTypeHeaderValue(model.Data.MimeType);
                }

                message.Headers.AcceptRanges.Add("bytes");
            }
            catch (Exception ex)
            {

                message = Request.CreateErrorResponse(HttpStatusCode.InternalServerError, ex.Message);
            }

            return message;
        }

        private ResponseModel<MediaModel> SendMediaRequest(string id, bool isPublic)
        {
            var request = new RestRequest("/media/getmedia?id=" + id + "&isPublic=" + isPublic);

            var response = _restClient.Get(request);

            return Mapper.Map<ResponseModel<MediaModel>>(response);
        }

    }

}
