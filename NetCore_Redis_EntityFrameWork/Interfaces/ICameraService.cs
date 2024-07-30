using StandartLibrary.Models.ViewModels.Request;
using System.Net.Http;

namespace CRCAPI.Services.Interfaces
{
    public interface ICameraService
    {
        string GetSnapshot(SnapshotRequest request);

        string GetMjpeg(CameraRequest request);

        string GetH264(CameraRequest request);
    }
}
