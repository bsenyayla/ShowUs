using CRCAPI.Services.Attributes;
using CRCAPI.Services.Factories;
using CRCAPI.Services.Interfaces;
using StandartLibrary.Models.DataModels;
using StandartLibrary.Models.ViewModels.Request;
using System;
using System.Net.Http;

namespace CRCAPI.Services.Services
{
    [ScopedDependency(ServiceType = typeof(ICameraService))]
    public class CameraService : ICameraService
    {
        private readonly IUnitOfWork<CrcmsDbContext> unitOfWork;
        private readonly IRedisCoreManager redisCoreManager;
        public CameraService(IUnitOfWork<CrcmsDbContext> unitOfWork, IRedisCoreManager redisCoreManager)
        {
            this.unitOfWork = unitOfWork;
            this.redisCoreManager = redisCoreManager;
        }
        public string GetH264(CameraRequest request)
        {
              ICameraDriver cameraDriver = CameraFactory.Driver(request.CameraId, request.ImageResponseAvailable, unitOfWork.GetRepository<Camera>(), redisCoreManager);
            
            return Convert.ToBase64String(cameraDriver.GetH264().Content.ReadAsByteArrayAsync().Result);
        }

        public string GetMjpeg(CameraRequest request)
        {
            ICameraDriver cameraDriver = CameraFactory.Driver(request.CameraId, request.ImageResponseAvailable, unitOfWork.GetRepository<Camera>(), redisCoreManager);
            return Convert.ToBase64String(cameraDriver.GetMjpeg().Content.ReadAsByteArrayAsync().Result);
        }

        public string GetSnapshot(SnapshotRequest request)
        {
            ICameraDriver cameraDriver = CameraFactory.Driver(request.CameraId, request.ImageResponseAvailable, unitOfWork.GetRepository<Camera>(), redisCoreManager);
            return Convert.ToBase64String(cameraDriver.Snapshot(request.CameraSnapshotSize).Content.ReadAsByteArrayAsync().Result);
        }
    }
}
