using CRCAPI.Services.Attributes;
using CRCAPI.Services.Interfaces;
using StandartLibrary.Models.Constants;
using StandartLibrary.Models.DataModels;
using StandartLibrary.Models.EntityModels.MailQueue;
using StandartLibrary.Models.Enums;
using StandartLibrary.Models.ViewModels;
using StandartLibrary.Models.ViewModels.Common;
using System;
using System.Collections.Generic;
using System.Linq;

namespace CRCAPI.Services.Services
{
    [ScopedDependency(ServiceType = typeof(ICrcRequestService))]
    public class CrcRequestService : ICrcRequestService
    {
        private readonly IUnitOfWork<CrcmsDbContext> _unitOfWork;
        private readonly ISmtpService _smtpService;

        public CrcRequestService(IUnitOfWork<CrcmsDbContext> unitOfWork, ISmtpService smtpService)
        {
            _unitOfWork = unitOfWork;
            _smtpService = smtpService;
        }

        public ServiceResponse CrcRequestSendMailForComponentReceiveDate()
        {
            DateTime lastMonth = DateTime.Now.AddMonths(-1);
            DateTime minCreatedDate = new DateTime(2021, 8, 1);
            var lstCrcRequests = _unitOfWork.Context.CrcRequest.Where(k => k.Status == (int)CrcRequestStatus.SendToCrc && k.ComponentReceiveDate.Value < lastMonth && k.CreateDate > minCreatedDate).ToList();
            if (lstCrcRequests.Any())
            {
                foreach (var item in lstCrcRequests)
                {
                    List<string> toList = new List<string>();
                    if (!string.IsNullOrEmpty(item.PssrEmail))
                    {
                        toList.Add(item.PssrEmail);
                    }

                    if (!string.IsNullOrEmpty(item.EngineerEmail))
                    {
                        toList.Add(item.EngineerEmail);
                    }

                    if (toList.Any())
                    {
                        var mailQueueParameterModel = new MailQueueParameterModel
                        {
                            Title = "CRC Talebi Hatırlatması",
                            Subject = "CRC Talebi Hatırlatması",
                            UploadIds = null,
                            SimpleText = new SimpleTextModel
                            {
                                RequestId = item.RequestId,
                                ComponentReceiveDate = item.ComponentReceiveDate.Value.ToString("dd.MM.yyyy")
                            }
                        };

                        _smtpService.SendMail(mailQueueParameterModel, toList, null);
                    }
                }

            }

            return new ServiceResponse()
            {
                ErrorCode = ErrorCode.Success,
                Message = "OK"
            };
        }
    }
}
