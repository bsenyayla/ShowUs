using StandartLibrary.Models.Enums;
using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;

namespace CRCAPI.Services.Interfaces
{
    public interface ICameraDriver
    {
        HttpResponseMessage GetMjpeg();

        HttpResponseMessage GetH264();

        HttpResponseMessage Snapshot(CameraSnapshotSize snapshotSize = CameraSnapshotSize.Large);
    }
}
