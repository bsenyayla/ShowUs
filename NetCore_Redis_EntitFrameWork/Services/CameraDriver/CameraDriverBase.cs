using StandartLibrary.Models.EntityModels.AppSettingService;
using StandartLibrary.Models.Enums;
using System.Drawing;
using System.IO;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;

namespace CRCAPI.Services.Services.CameraDriver
{
    public abstract class CameraDriverBase
    {
        public readonly StandartLibrary.Models.DataModels.Camera camera;
        private readonly bool imageResponseAvailable;

        public CameraDriverBase(StandartLibrary.Models.DataModels.Camera camera, bool imageResponseAvailable)
        {
            this.camera = camera;
            this.imageResponseAvailable = imageResponseAvailable;
        }

        public abstract void Login();

        public abstract void Logout();


        public static HttpResponseMessage ResponseLoading()
        {
            HttpResponseMessage responseLoading = new HttpResponseMessage();
            responseLoading.Content = new StreamContent(System.IO.File.OpenRead(Path.Combine(Directory.GetCurrentDirectory(), "/Content/CameraLoading.jpg")));
            responseLoading.Content.Headers.ContentType = new MediaTypeHeaderValue("image/jpeg");

            return responseLoading;
        }


        private Bitmap CreateErrorImage(string title, string message)
        {
            string imageFilePath = Path.Combine(Directory.GetCurrentDirectory(), $"/Content/CameraNotFound.png");
            Bitmap bitmap = (Bitmap)Image.FromFile(imageFilePath);//load the image file

            using (Graphics graphics = Graphics.FromImage(bitmap))
            {
                using (Font fontTitle = new Font("arial", 40))
                using (Font fontMessage = new Font("arial", 20))
                {
                    var measureTitle = graphics.MeasureString(title, fontTitle, bitmap.Width);
                    var measureMessage = graphics.MeasureString(message, fontMessage, bitmap.Width);

                    PointF locationTitle = new PointF((bitmap.Width - measureTitle.Width) / 2, 50f);
                    PointF locationMessage = new PointF((bitmap.Width - measureMessage.Width) / 2, locationTitle.Y + measureTitle.Height + 50);

                    graphics.DrawString(title, fontTitle, Brushes.Black, locationTitle);
                    graphics.DrawString(message, fontMessage, Brushes.Black, locationMessage);
                }
            }

            return bitmap;
        }

        public HttpResponseMessage CustomError(string title, string message, HttpStatusCode httpStatusCode = HttpStatusCode.InternalServerError)
        {
            HttpResponseMessage response = new HttpResponseMessage();

            if (!imageResponseAvailable || httpStatusCode == HttpStatusCode.Unauthorized)
            {
                response.StatusCode = httpStatusCode;
                return response;
            }


            Bitmap bitmap = CreateErrorImage(title, message);

            MemoryStream ms = new MemoryStream();
            bitmap.Save(ms, System.Drawing.Imaging.ImageFormat.Jpeg);
            bitmap.Dispose();

            ms.Position = 0;

            response.Content = new StreamContent(ms);
            response.Content.Headers.ContentLength = ms.Length;
            response.Content.Headers.ContentType = new MediaTypeHeaderValue("image/jpeg");

            return response;
        }
        
        /*
        public string ParameterRender(string parameter, StandartLibrary.Models.DataModels.Camera camera)
        {
            string ipKey = "{IP}";
            if (parameter.Contains(ipKey))
            {
                parameter = parameter.Replace(ipKey, camera.IP);
            }
            return parameter;
        }
        */

        public string GetUrl(StandartLibrary.Models.DataModels.Camera camera, CameraSource source, CameraDriverSettingBaseModel cameraSettings)
        {
            var url = string.Empty;

            switch (source)
            {
                case CameraSource.SNAPSHOT:
                    url = string.IsNullOrWhiteSpace(camera.ParametersModel.SnapshotUrl) ? cameraSettings.SnapshotUrl : camera.ParametersModel.SnapshotUrl;
                    break;
                case CameraSource.MJPEG:
                    url = string.IsNullOrWhiteSpace(camera.ParametersModel.MjpegUrl) ? cameraSettings.MjpegUrl : camera.ParametersModel.MjpegUrl;
                    break;
                case CameraSource.H264:
                    url = string.IsNullOrWhiteSpace(camera.ParametersModel.H264Url) ? cameraSettings.H264Url : camera.ParametersModel.H264Url;
                    break;
                default:
                    url = string.IsNullOrWhiteSpace(camera.ParametersModel.SnapshotUrl) ? cameraSettings.SnapshotUrl : camera.ParametersModel.SnapshotUrl;
                    break;
            }

            string ipKey = "{IP}";
            if (url.Contains(ipKey))
            {
                url = url.Replace(ipKey, camera.IP);
            }


            string channelIdKey = "{ChannelId}";
            if (url.Contains(channelIdKey))
            {
                url = url.Replace(channelIdKey, camera.ParametersModel.ChannelId.ToString());
            }


            return url;
        }

    }
}
