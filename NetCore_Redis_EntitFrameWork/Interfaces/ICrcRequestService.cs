using StandartLibrary.Models.ViewModels;
using System;
using System.Collections.Generic;
using System.Text;

namespace CRCAPI.Services.Interfaces
{
    public interface ICrcRequestService
    {
        ServiceResponse CrcRequestSendMailForComponentReceiveDate();
    }
}
