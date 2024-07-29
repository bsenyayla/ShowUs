using System.Collections.Generic;
using StandartLibrary.Models.EntityModels.MailQueue;

namespace CRCAPI.Services.Interfaces
{
    public interface ISmtpService
    {
        bool SendMail(MailQueueParameterModel mailQueueParameterModel, List<string> toList, List<string> ccList);
    }
}
