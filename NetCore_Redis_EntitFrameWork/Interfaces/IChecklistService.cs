using StandartLibrary.Models.ViewModels.Request;
using StandartLibrary.Models.ViewModels.Response;
using System;
using System.Collections.Generic;
using System.Text;

namespace CRCAPI.Services.Interfaces
{
    public interface IChecklistService
    {
        CheckForSubmitedCheckListResponse CheckForSubmitedCheckLists(CheckForSubmitedCheckListRequest request);
    }
}
