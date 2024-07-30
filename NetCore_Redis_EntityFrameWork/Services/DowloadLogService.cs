using CRCAPI.Services.Attributes;
using CRCAPI.Services.Interfaces;
using StandartLibrary.Models.DataModels;
using StandartLibrary.Models.ViewModels.Request;
using System;
using System.Collections.Generic;
using System.Runtime.CompilerServices;

namespace CRCAPI.Services.Services
{
    [TransientDependency(ServiceType = typeof(IDowloadLogService))]
    public class DowloadLogService : IDowloadLogService
    {
        private readonly IUnitOfWork<CrcmsDbContext> unitOfWork;
        private readonly IUserService userService;
        public DowloadLogService(IUnitOfWork<CrcmsDbContext> unitOfWork, IUserService userService)
        {
            this.unitOfWork = unitOfWork;
            this.userService = userService;
        }

        public void Log(DowloadLogRequest request, [CallerMemberName] string memberName = "")
        {
            try
            {
                var userCode = string.Empty;
                var user = userService.GetUserByTechnicianSAPNumber(request.TechnicianSapNumber);
                if (user.UserId != 0)
                {
                    userCode = user.Code;
                }

                var log = new DownloadLog
                {
                    AttachmentId = request.AttachmentId,
                    DownloadingDate = DateTime.Now,
                    DownloadingUserCode = userCode,
                    Guid = new Guid().ToString(),
                    Module = request.Module,
                    AttachmentPath = request.AttachmentPath,
                    SourceMethod = memberName
                };


                unitOfWork.GetRepository<DownloadLog>().Add(log);
                unitOfWork.SaveChanges();
            }
            catch (Exception ex)
            {
                ////Do nothing.. hatayı yut yoluna bak... foskan
            }

        }

        public List<DownloadLog> GetDownloadLogsByUser(string TechnicianSapNumber)
        {
            var userCode = string.Empty;
            var user = userService.GetUserByTechnicianSAPNumber(TechnicianSapNumber);
            if (user.UserId != 0)
            {
                userCode = user.Code;
            }

            return unitOfWork.GetRepository<DownloadLog>().List(x => x.DownloadingUserCode == userCode);
        }

        public List<DownloadLog> GetDownloadLogsByAttachmentId(int attachmentId)
        {
            return unitOfWork.GetRepository<DownloadLog>().List(x => x.AttachmentId == attachmentId);
        }
    }
}
