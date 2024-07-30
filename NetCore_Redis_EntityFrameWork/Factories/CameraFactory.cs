using CRCAPI.Services.Exceptions;
using CRCAPI.Services.Interfaces;
using CRCAPI.Services.Services.CameraDriver;
using StandartLibrary.Lang;
using StandartLibrary.Models.Enums;
using System;
using System.Linq;
using Model = StandartLibrary.Models.DataModels;

namespace CRCAPI.Services.Factories
{
    public static class CameraFactory
    {
        public static ICameraDriver Driver(Guid cameraId, bool imageResponseAvailable, IRepository<Model.Camera> cameraRepository, IRedisCoreManager redisCoreManager)
        {
            if (cameraId == Guid.Empty)
            {
                throw new CameraException(Resources.CameraNotFound, CameraDriverBase.ResponseLoading());
            }

            Model.Camera camera = cameraRepository.List(x => x.CameraId == cameraId).First();
            if (camera == null)
            {
                throw new CameraException(Resources.CameraNotFound, CameraDriverBase.ResponseLoading());
            }

            switch (camera.Driver)
            {
                case CameraDriver.PixusCamera:
                    return new PixusDriver(redisCoreManager, camera, imageResponseAvailable);
                case CameraDriver.HikvisionCamera:
                    return new HikvisionDriver(redisCoreManager, camera, imageResponseAvailable);
                //case CameraDriver.AxisCamera:
                //    return new AxisDriver(camera, imageResponseAvailable);
                default:
                    throw new CameraException(Resources.CameraDriverNotFound, CameraDriverBase.ResponseLoading());
            }
        }
    }
}
