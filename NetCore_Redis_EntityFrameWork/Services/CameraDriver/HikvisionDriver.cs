using CRCAPI.Services.Attributes;
using CRCAPI.Services.Exceptions;
using CRCAPI.Services.Interfaces;
using StandartLibrary.Lang;
using StandartLibrary.Models.Constants;
using StandartLibrary.Models.DataModels;
using StandartLibrary.Models.EntityModels.AppSettingService;
using StandartLibrary.Models.Enums;
using System;
using System.Net.Http;
using System.Net.Http.Headers;

namespace CRCAPI.Services.Services.CameraDriver
{
    //[ScopedDependency(ServiceType = typeof(ICameraDriver))]
    public class HikvisionDriver : CameraDriverBase, ICameraDriver
    {
        private AppSettingModel appSetting;
        private HikvisionCameraDriverSettingModel appSettingHikvisionCamera;

        private uint iLastErr = 0;
        private Int32 m_lUserID = -1;
        private bool m_bInitSDK = false;
        string str = "";

        public HikvisionDriver(IRedisCoreManager redisCoreManager, Camera camera, bool imageResponseAvailable)
            : base(camera, imageResponseAvailable)
        {
            appSetting = redisCoreManager.GetObject<AppSettingModel>(RedisConstants.APPSETTING_KEY);
            appSettingHikvisionCamera = appSetting.Camera.DriverSettings.HikvisionCamera;

            //m_bInitSDK = CHCNetSDK.NET_DVR_Init();
            //if (m_bInitSDK == false)
            //{

            //}
            //else
            //{
            //    CHCNetSDK.NET_DVR_SetLogToFile(3, "C:\\HikvisionSdkLog\\", true);
            //}

        }

        public HttpResponseMessage GetMjpeg()
        {
            if (!appSettingHikvisionCamera.MjpegEnabled)
            {
                throw new CameraException(Resources.MjpegIsNotEnabled, CustomError(Resources.Forbidden, Resources.MjpegIsNotEnabled));
            }

            return null;
        }

        public HttpResponseMessage GetH264()
        {

            if (!appSettingHikvisionCamera.H264Enabled)
            {
                throw new CameraException(Resources.H264IsNotEnabled, CustomError(Resources.Forbidden, Resources.H264IsNotEnabled));
            }

            return null;
        }

        public HttpResponseMessage Snapshot(CameraSnapshotSize snapshotSize = CameraSnapshotSize.Large)
        {
            //if (!appSettingHikvisionCamera.SnapshotEnabled)
            //{
            //    throw new CameraException(Resources.SnapshotIsNotEnabled, CustomError(Resources.Forbidden, Resources.SnapshotIsNotEnabled));
            //}

            //Login();

            //ushort wPicSize = 0xff;
            //switch (snapshotSize)
            //{
            //    case CameraSnapshotSize.Small:
            //        wPicSize = appSettingHikvisionCamera.SizeSmallValue;
            //        break;

            //    case CameraSnapshotSize.Medium:
            //        wPicSize = appSettingHikvisionCamera.SizeMediumValue;
            //        break;

            //    case CameraSnapshotSize.Large:
            //        wPicSize = appSettingHikvisionCamera.SizeLargeValue;
            //        break;
            //}

            ////Í¼Æ¬±£´æÂ·¾¶ºÍÎÄ¼þÃû the path and file name to save
            //string rootPath = appSetting.Uploads.Uploads_CameraTemp;
            //if (!System.IO.Directory.Exists(rootPath))
            //{
            //    System.IO.Directory.CreateDirectory(rootPath);
            //}

            //string sJpegPicFileName = $"{rootPath}\\{camera.CameraId.ToString()}-{Guid.NewGuid().ToString()}.jpg";
            ////string sJpegPicFileName = $"{_camera.CameraId.ToString()}-{Guid.NewGuid().ToString()}.jpg";
            ////string sJpegPicFileName = $"xxx.jpg";

            //int lChannel = camera.ParametersModel.ChannelId; //Í¨µÀºÅ Channel number

            //CHCNetSDK.NET_DVR_JPEGPARA lpJpegPara = new CHCNetSDK.NET_DVR_JPEGPARA();
            //lpJpegPara.wPicQuality = 0; //Í¼ÏñÖÊÁ¿ Image quality
            //lpJpegPara.wPicSize = wPicSize; //×¥Í¼·Ö±æÂÊ Picture size: 2- 4CIF£¬0xff- Auto(Ê¹ÓÃµ±Ç°ÂëÁ÷·Ö±æÂÊ)£¬×¥Í¼·Ö±æÂÊÐèÒªÉè±¸Ö§³Ö£¬¸ü¶àÈ¡ÖµÇë²Î¿¼SDKÎÄµµ

            ////JPEG×¥Í¼ Capture a JPEG picture
            //if (!CHCNetSDK.NET_DVR_CaptureJPEGPicture(m_lUserID, lChannel, ref lpJpegPara, sJpegPicFileName))
            //{
            //    //iLastErr = CHCNetSDK.NET_DVR_GetLastError();
            //    //str = "NET_DVR_CaptureJPEGPicture failed, error code= " + iLastErr;
            //    //MessageBox.Show(str);
            //    //return;
            //}
            //else
            //{

            //    HttpResponseMessage response = new HttpResponseMessage();
            //    response.Content = new StreamContent(System.IO.File.OpenRead(sJpegPicFileName));
            //    response.Content.Headers.ContentType = new MediaTypeHeaderValue("image/jpeg");
            //    return response;
            //}

            //Logout();

            throw new CameraException("Snapshot not loading", ResponseLoading());
        }

        public override void Login()
        {

            //string username = !string.IsNullOrEmpty(camera.AuthUsername)
            //                    ? camera.AuthUsername
            //                    : appSettingHikvisionCamera.DefaultAuthUsername;

            //string password = !string.IsNullOrEmpty(camera.AuthPassword)
            //                    ? camera.AuthPassword
            //                    : appSettingHikvisionCamera.DefaultAuthPassword;

            //Int16 port = camera.ParametersModel.Port.HasValue
            //                    ? camera.ParametersModel.Port.Value
            //                    : appSettingHikvisionCamera.DefaultPort;
            ////login
            //if (m_lUserID < 0)
            //{
            //    string DVRIPAddress = camera.IP; //Éè±¸IPµØÖ·»òÕßÓòÃû
            //    Int16 DVRPortNumber = port;//Éè±¸·þÎñ¶Ë¿ÚºÅ
            //    string DVRUserName = username;//Éè±¸µÇÂ¼ÓÃ»§Ãû
            //    string DVRPassword = password;//Éè±¸µÇÂ¼ÃÜÂë

            //    CHCNetSDK.NET_DVR_DEVICEINFO_V30 DeviceInfo = new CHCNetSDK.NET_DVR_DEVICEINFO_V30();

            //    //µÇÂ¼Éè±¸ Login the device
            //    m_lUserID = CHCNetSDK.NET_DVR_Login_V30(DVRIPAddress, DVRPortNumber, DVRUserName, DVRPassword, ref DeviceInfo);
            //    if (m_lUserID < 0)
            //    {
            //        iLastErr = CHCNetSDK.NET_DVR_GetLastError();
            //        str = "NET_DVR_Login_V30 failed, error code= " + iLastErr; //µÇÂ¼Ê§°Ü£¬Êä³ö´íÎóºÅ

            //        throw new CameraException("Login failed ", ResponseLoading());

            //        //MessageBox.Show(str);
            //        //return;
            //    }
            //    else
            //    {
            //        ////µÇÂ¼³É¹¦
            //        //MessageBox.Show("Login Success!");
            //        //btnLogin.Text = "Logout";
            //    }
            //}
        }

        public override void Logout()
        {
           // CHCNetSDK.NET_DVR_Logout_V30(m_lUserID);
        }

    }
}
