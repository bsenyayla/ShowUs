using AForge.Video;
using CRCAPI.Services.Attributes;
using CRCAPI.Services.Exceptions;
using CRCAPI.Services.Interfaces;
using StandartLibrary.Lang;
using StandartLibrary.Models.Constants;
using StandartLibrary.Models.EntityModels.AppSettingService;
using StandartLibrary.Models.Enums;
using System;
using System.Drawing;
using System.Drawing.Imaging;
using System.IO;
using System.Net;
using System.Net.Http;
using System.Net.Http.Headers;
using System.Text;
using System.Threading;

namespace CRCAPI.Services.Services.CameraDriver
{
    public class PixusDriver : CameraDriverBase, ICameraDriver
    {
        private MJPEGStream mjpegStream = new MJPEGStream();
        private bool frameAvailable = false;
        private Bitmap frame = null;
        private string BOUNDARY = "frame";

        private AppSettingModel appSetting;
        private PixusCameraDriverSettingModel appSettingPixusCamera;
        public PixusDriver(IRedisCoreManager redisCoreManager, StandartLibrary.Models.DataModels.Camera camera, bool imageResponseAvailable)
            : base(camera, imageResponseAvailable)
        {
            appSetting = redisCoreManager.GetObject<AppSettingModel>(RedisConstants.APPSETTING_KEY);
            appSettingPixusCamera = appSetting.Camera.DriverSettings.PixusCamera;

        }

        public HttpResponseMessage GetMjpeg()
        {
            if (!appSettingPixusCamera.MjpegEnabled)
            {
                throw new CameraException(Resources.MjpegIsNotEnabled, CustomError(Resources.Forbidden, Resources.MjpegIsNotEnabled));
            }

            if (!string.IsNullOrEmpty(camera.AuthUsername))
            {
                mjpegStream.Login = camera.AuthUsername;
                mjpegStream.Password = camera.AuthPassword;
            }

            //mjpegStream.Source = $"http://{_camera.IP}:{_camera.ParametersModel.Port}";
            //mjpegStream.Source = $"rtsp://{_camera.IP}/h264";
            mjpegStream.Source = GetUrl(camera, CameraSource.MJPEG, appSettingPixusCamera);//ParameterRender(appSettingPixusCamera.MjpegUrl, camera);

            //mjpegStream.Source = "http://localhost:8080/video.mpjpeg";//todo: commit etmeden önce bu satırı sil

            mjpegStream.NewFrame += new NewFrameEventHandler(showFrameEvent);

            mjpegStream.Start();
            // var response = HttpRequestMessageExtensions.CreateResponse(request);
            HttpResponseMessage response = new HttpResponseMessage();
            response.Content = new PushStreamContent((Action<Stream, HttpContent, TransportContext>)StartStream);
            response.Content.Headers.ContentType = System.Net.Http.Headers.MediaTypeHeaderValue.Parse("multipart/x-mixed-replace; boundary=" + BOUNDARY);
            return response;
        }

        public HttpResponseMessage GetH264()
        {
            if (!appSettingPixusCamera.H264Enabled)
            {
                throw new CameraException(Resources.H264IsNotEnabled, CustomError(Resources.Forbidden, Resources.H264IsNotEnabled));
            }

            if (!string.IsNullOrEmpty(camera.AuthUsername))
            {
                mjpegStream.Login = camera.AuthUsername;
                mjpegStream.Password = camera.AuthPassword;
            }

            //mjpegStream.Source = $"http://{_camera.IP}:{_camera.ParametersModel.Port}";
            //mjpegStream.Source = $"rtsp://{_camera.IP}/h264";
            mjpegStream.Source = GetUrl(camera, CameraSource.H264, appSettingPixusCamera);//ParameterRender(appSettingPixusCamera.H264Url, camera);

            //mjpegStream.Source = "http://localhost:8080/video.mpjpeg";//todo: commit etmeden önce bu satırı sil

            mjpegStream.NewFrame += new NewFrameEventHandler(showFrameEvent);

            mjpegStream.Start();
            //var response = HttpRequestMessageExtensions.CreateResponse(request);
            HttpResponseMessage response = new HttpResponseMessage();
            response.Content = new PushStreamContent((Action<Stream, HttpContent, TransportContext>)StartStream);
            response.Content.Headers.ContentType = System.Net.Http.Headers.MediaTypeHeaderValue.Parse("multipart/x-mixed-replace; boundary=" + BOUNDARY);
            return response;
        }

        public HttpResponseMessage Snapshot(CameraSnapshotSize snapshotSize = CameraSnapshotSize.Large)
        {

            if (!appSettingPixusCamera.SnapshotEnabled)
            {
                throw new CameraException(Resources.SnapshotIsNotEnabled, CustomError(Resources.Forbidden, Resources.SnapshotIsNotEnabled));
            }

            using (System.Net.WebClient wc = new WebClient())
            {
                if (!string.IsNullOrEmpty(camera.AuthUsername))
                {
                    wc.Credentials = new System.Net.NetworkCredential(camera.AuthUsername, camera.AuthPassword);
                }

                try
                {
                    string rootPath = appSetting.Uploads.Uploads_CameraTemp;
                    if (!System.IO.Directory.Exists(rootPath))
                    {
                        System.IO.Directory.CreateDirectory(rootPath);
                    }

                    string filePath = $"{rootPath}\\{camera.CameraId.ToString()}-{Guid.NewGuid().ToString()}.jpg";

                    var snapshotUrl = GetUrl(camera, CameraSource.SNAPSHOT, appSettingPixusCamera);//ParameterRender(appSettingPixusCamera.SnapshotUrl, camera);

                    wc.DownloadFile(snapshotUrl, filePath);

                    HttpResponseMessage response = new HttpResponseMessage();
                    response.Content = new StreamContent(System.IO.File.OpenRead(filePath));
                    response.Content.Headers.ContentType = new MediaTypeHeaderValue("image/jpeg");
                    return response;
                }
                catch (Exception ex)
                {
                    throw new CameraException("Snapshot not loading", ResponseLoading());
                }
            }
            throw new CameraException("Snapshot not loading", ResponseLoading());
        }

        public bool SetCompression(int compression)
        {
            if (compression >= 1 && compression <= 70)
            {
                using (System.Net.WebClient wc = new WebClient())
                {
                    if (!string.IsNullOrEmpty(camera.AuthUsername))
                    {
                        wc.Credentials = new System.Net.NetworkCredential(camera.AuthUsername, camera.AuthPassword);
                    }

                    try
                    {
                        string ds = wc.DownloadString($"http://{camera.IP}/cgi-bin/h264bitrate.cgi?jpegqfactor={compression}&Submit=Save");
                        return true;
                    }
                    catch (Exception ex)
                    {
                        return false;
                    }
                }
            }
            return false;
        }

        public string GetParameters()
        {
            using (System.Net.WebClient wc = new WebClient())
            {
                if (!string.IsNullOrEmpty(camera.AuthUsername))
                {
                    wc.Credentials = new System.Net.NetworkCredential(camera.AuthUsername, camera.AuthPassword);
                }

                try
                {
                    string ds = wc.DownloadString($"http://{camera.IP}/cgi-bin/admin/param.cgi?action=list");
                    return ds;
                }
                catch (Exception ex)
                {
                }
            }
            return "";
        }

        /// <summary>
        /// Craete an appropriate header.
        /// </summary>
        /// <param name="length"></param>
        /// <returns></returns>
        private byte[] CreateHeader(int length)
        {
            string header =
                "--" + BOUNDARY + "\r\n" +
                "Content-Type:image/jpeg\r\n" +
                "Content-Length:" + length + "\r\n\r\n";

            return Encoding.ASCII.GetBytes(header);
        }

        public byte[] CreateFooter()
        {
            return Encoding.ASCII.GetBytes("\r\n");
        }

        /// <summary>
        /// Write the given frame to the stream
        /// </summary>
        /// <param name="stream">Stream</param>
        /// <param name="frame">Bitmap format frame</param>
        private void WriteFrame(Stream stream, Bitmap frame)
        {
            // prepare image data
            byte[] imageData = null;

            // this is to make sure memory stream is disposed after using
            using (MemoryStream ms = new MemoryStream())
            {
                frame.Save(ms, ImageFormat.Jpeg);
                imageData = ms.ToArray();
            }

            // prepare header
            byte[] header = CreateHeader(imageData.Length);
            // prepare footer
            byte[] footer = CreateFooter();

            // Start writing data
            stream.Write(header, 0, header.Length);
            stream.Write(imageData, 0, imageData.Length);
            stream.Write(footer, 0, footer.Length);
        }

        /// <summary>
        /// While the MJPEGStream is running and clients are connected,
        /// continue sending frames.
        /// </summary>
        /// <param name="stream">Stream to write to.</param>
        /// <param name="httpContent">The content information</param>
        /// <param name="transportContext"></param>
        private void StartStream(Stream stream, HttpContent httpContent, TransportContext transportContext)
        {
            while (mjpegStream.IsRunning
                //&& HttpContext.Current.Response.IsClientConnected
                )
            {
                if (frameAvailable)
                {
                    try
                    {
                        WriteFrame(stream, frame);
                        frameAvailable = false;
                    }
                    catch (Exception e)
                    {
                        System.Diagnostics.Debug.WriteLine(e);
                    }
                }
                else
                {
                    Thread.Sleep(30);
                }
            }
            stopStream();
        }

        /// <summary>
        /// This event is thrown when a new frame is detected by the MJPEGStream
        /// </summary>
        /// <param name="sender">Object that is sending the event</param>
        /// <param name="eventArgs">Data from the event, including the frame</param>
        private void showFrameEvent(object sender, NewFrameEventArgs eventArgs)
        {
            frame = new Bitmap(eventArgs.Frame);
            frameAvailable = true;
        }

        /// <summary>
        /// Stop the stream.
        /// </summary>
        private void stopStream()
        {
            System.Diagnostics.Debug.WriteLine("Stop stream");
            mjpegStream.Stop();
        }

        public override void Login()
        {
            throw new NotImplementedException();
        }

        public override void Logout()
        {
            throw new NotImplementedException();
        }
    }
}
