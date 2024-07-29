using CRCAPI.Services.Attributes;
using CRCAPI.Services.Exceptions;
using CRCAPI.Services.Interfaces;
using StandartLibrary.Lang;
using StandartLibrary.Models.Enums;
using System;
using System.Net;
using System.Net.Http;

namespace CRCAPI.Services.Services.CameraDriver
{
    //[ScopedDependency(ServiceType = typeof(ICameraDriver))]
    public class AxisDriver : CameraDriverBase, ICameraDriver
    {
        public AxisDriver(StandartLibrary.Models.DataModels.Camera camera, bool imageResponseAvailable)
            : base(camera, imageResponseAvailable)
        {
        }

        public HttpResponseMessage GetH264()
        {
            throw new CameraException(Resources.CameraDriverNotFound, CustomError(Resources.CameraDriverNotFound, Resources.CameraDriverNotFound, HttpStatusCode.NotFound));
        }

        public HttpResponseMessage GetMjpeg()
        {
            throw new CameraException(Resources.CameraDriverNotFound, CustomError(Resources.CameraDriverNotFound, Resources.CameraDriverNotFound, HttpStatusCode.NotFound));
        }
        public HttpResponseMessage Snapshot(CameraSnapshotSize snapshotSize = CameraSnapshotSize.Large)
        {
            throw new CameraException(Resources.CameraDriverNotFound, CustomError(Resources.CameraDriverNotFound, Resources.CameraDriverNotFound, HttpStatusCode.NotFound));
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
