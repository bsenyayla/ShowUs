using CRCAPI.Services.Attributes;
using CRCAPI.Services.Interfaces;
using StandartLibrary.Models.Constants;
using StandartLibrary.Models.DataModels;
using StandartLibrary.Models.Enums;
using StandartLibrary.Models.ViewModels.Common;
using StandartLibrary.Models.ViewModels.Request;
using StandartLibrary.Models.ViewModels.Response;
using System;
using System.Collections.Generic;
using System.Linq;

namespace CRCAPI.Services
{
    [TransientDependency(ServiceType = typeof(IProcessService))]
    public class ProcessService : IProcessService
    {
        private readonly IAttachmentService attacthmentService;
        private readonly IDocumentService documentservice;
        private readonly IUserService userService;
        private readonly IAreaService areaService;
        private readonly IUnitOfWork<CrcmsDbContext> unitOfWork;
        private readonly ILogCoreMan logMan;
        private readonly IRedisCoreManager redisCoreManager;

        public ProcessService(IDocumentService documentservice, IUserService userService, IUnitOfWork<CrcmsDbContext> unitOfWork,
            IAttachmentService attacthmentService,
            IAreaService areaService, ILogCoreMan logMan, IRedisCoreManager redisCoreManager)
        {
            this.documentservice = documentservice;
            this.unitOfWork = unitOfWork;
            this.userService = userService;
            this.areaService = areaService;
            this.logMan = logMan;
            this.redisCoreManager = redisCoreManager;
            this.attacthmentService = attacthmentService;
        }


        public List<WorkOrderStatusResponse> GetWorkOrderStatusList(WorkOrderStatusListRequest request)
        {
            List<WorkOrderStatusResponse> response = new List<WorkOrderStatusResponse>();

            foreach (var woNumber in request.WorkOrderNumberList)
            {
                try
                {
                    var woResponse = GetWorkOrderStatus(new WorkOrderStatusRequest { Language = request.Language, WorkOrderNumber = woNumber });
                    response.Add(woResponse);
                }
                catch
                {
                    ///do nothing
                }
            }

            return response.Any() ? response : null;
        }


        public WorkOrderStatusResponse GetWorkOrderStatus(WorkOrderStatusRequest request)
        {
            request.Language = string.IsNullOrWhiteSpace(request.Language) ? "tr" : request.Language.ToLower();

            WorkOrderStatusResponse response = new WorkOrderStatusResponse();
            response.WorkOrderNumber = request.WorkOrderNumber;
            var documentId = documentservice.FindDocumentNumberWithWorkOrderNumber(request.WorkOrderNumber);

            if (documentId == 0)
            {
                logMan.Error($"PrecessService.GetWorkOrderStatus => WrongWorkOrderNumber: {request.WorkOrderNumber} ");
                throw new BusinessException("WrongWorkOrderNumber", ErrorCode.WrongWorkOrderNumber);
            }
            else
            {
                var docAttribute = unitOfWork.GetRepository<DocumentAttributes>().List(x => x.DocumentId == documentId).FirstOrDefault();
                var docAttributeDispatched = unitOfWork.GetRepository<DocumentAttributesDispatched>().List(x => x.DocumentId == documentId).FirstOrDefault();

                if (docAttribute != null || docAttributeDispatched != null)
                {

                    var receptionItem = unitOfWork.GetRepository<ReceptionItem>().List(x => x.DocumentId == documentId).FirstOrDefault();

                    if (receptionItem != null)
                    {
                        var reception = unitOfWork.GetRepository<Reception>().List(x => x.ReceptionId == receptionItem.ReceptionId).FirstOrDefault();
                        if (reception != null)
                        {
                            response.StartDate = reception.ReceptionDate;
                        }
                    }

                    response.Attachments = attacthmentService.GetBoomAttachments(new GetAttachmentListRequest { OrderNumber = request.WorkOrderNumber });

                    response.CurrentStatus = docAttribute != null ? docAttribute.ShortPlanStatusId ?? 0 : 33;// 33 dispatch edildi..
                    response.CurrentStatusName = unitOfWork.GetRepository<LocalizedProperty>().List(x => x.Entity == "PlanWorkStatusList" && x.Language == request.Language && x.Field == "Name" && x.EntityId == response.CurrentStatus).FirstOrDefault().Value;

                    if (docAttributeDispatched == null)
                    {
                        var docAreaList = unitOfWork.GetRepository<DocumentArea>().List(x => x.DocumentId == documentId && x.Status == (int)JobStatus.Initial);
                        if (docAreaList.Any())
                        {
                            foreach (var docArea in docAreaList)
                            {
                                var area = unitOfWork.GetRepository<Area>().List(x => x.AreaId == docArea.AreaId).FirstOrDefault();

                                if (area != null)
                                {
                                    var timers = unitOfWork.GetRepository<Timer>().List(x => x.DocumentId == documentId && x.AreaId == area.AreaId && x.DateFinish == null).ToList();
                                    if (timers.Any())
                                    {
                                        var areaCameras = unitOfWork.GetRepository<AreaCamera>().List(x => x.AreaId == area.AreaId);

                                        response.AreaInfos.Add(new AreaInfo
                                        {
                                            AreaId = area.AreaId,
                                            AreaName = unitOfWork.GetRepository<LocalizedProperty>().List(x => x.Entity == "Area" && x.Language == request.Language && x.Field == "FullName" && x.EntityId == area.AreaId).FirstOrDefault().Value,
                                            ActiveCameras = areaCameras.Any() ? areaCameras.Select(x => x.CameraId).ToList() : new List<Guid>()
                                        });
                                    }
                                }
                            }
                        }
                    }
                    else
                    {
                        var dispatchItem = unitOfWork.GetRepository<DispatchItem>().List(x => x.DocumentId == documentId).FirstOrDefault();

                        if (dispatchItem != null)
                        {
                            var dispatch = unitOfWork.GetRepository<Dispatch>().List(x => x.DispatchId == dispatchItem.DispatchId && x.Saved).FirstOrDefault();
                            if (dispatch != null)
                            {
                                response.EndDate = dispatch.DispatchDate;
                                response.Plate = dispatch.CarNumber ?? string.Empty;
                            }
                        }
                    }

                    return response;
                }
                else
                {
                    logMan.Error($"PrecessService.GetWorkOrderStatus => DocumentAttribute Has Not a Job For This DocumentId  {documentId}");
                    throw new BusinessException("NoJobsFound");
                }
            }
        }


        public UpdateStatusResponse UpdateStatus(UpdateStatusRequest request, string transactioId)
        {
            UpdateSegmentStatus(request, transactioId);
            /// wekingte arealar patladıgı için bu sekilde bir workaround düşünüldü ilerde kaldıralacak...
            var wekingIntegrationInfo = redisCoreManager.GetObject<WekingIntegration>(RedisConstants.WEKING_INTEGRATION);
            int increaseNumber = wekingIntegrationInfo.AreaIncreaseNumber;
            /// wekingte arealar patladıgı için bu sekilde bir workaround düşünüldü ilerde kaldıralacak...
            int areaId = (Convert.ToInt32(request.AreaId) - increaseNumber);


            List<int> allAreaIds = request.AllAreaIds.Select(x => Convert.ToInt32(x) - increaseNumber).ToList();


            bool areaExists = areaService.CheckIfAreaExists(areaId);

            if (!areaExists)
            {
                logMan.Error($"ProcessService.UpdateStatus -> Area not found {areaId}");
                throw new BusinessException("Area not found", ErrorCode.AreaNotFound);
            }

            var documentId = documentservice.FindDocumentNumberWithWorkOrderNumber(request.OrderNumber);

            if (documentId == 0)
            {
                InsertFailedProcesses(request, transactioId);

                logMan.Error($"ProcessService.UpdateStatus -> Wrong work order number {request.OrderNumber}");
                throw new BusinessException("Wrong work order number", ErrorCode.WrongWorkOrderNumber);
            }

            userService.CheckAndCreateTemporaryTechnician(request.Technician);

            var userId = 0;
            var user = userService.GetUserByTechnicianSAPNumber(request.TechnicianSapNumber);
            if (user.UserId != 0)
            {
                userId = user.UserId;
            }

            if (!user.IsActive)
            {
                logMan.Error($"ProcessService.UpdateStatus -> User is not active anymore. {user.UserId}");
                throw new BusinessException("User is not active anymore", ErrorCode.UserIsNotActive);
            }


            /// wekingte arealar patladıgı için bu sekilde bir workaround düşünüldü ilerde kaldıralacak...
            request.AreaId = areaId.ToString();

            switch (request.Status)
            {
                case ProcessStatus.Complete:
                    return CompleteProcess(request, documentId, userId, allAreaIds);
                case ProcessStatus.Finish:
                    return FinishProcess(request, documentId, userId);
                case ProcessStatus.Pause:
                    return PauseProcess(request, documentId, userId);
                case ProcessStatus.Start:
                    return StartProcess(request, documentId, userId);
            }
            logMan.Error($"ProcessService.UpdateStatus -> Wrong or missing request status {request.Status}");
            throw new BusinessException("Wrong or missing request status", ErrorCode.WrongOrMissingRequest);
        }
        public UpdateStatusResponse UpdateSegmentStatus(UpdateStatusRequest request, string transactioId)
        {
            var wekingIntegrationInfo = redisCoreManager.GetObject<WekingIntegration>(RedisConstants.WEKING_INTEGRATION);
            int increaseNumber = wekingIntegrationInfo.AreaIncreaseNumber;
            int areaId = (Convert.ToInt32(request.AreaId) - increaseNumber);

            List<int> allAreaIds = request.AllAreaIds.Select(x => Convert.ToInt32(x) - increaseNumber).ToList();

            bool areaExists = areaService.CheckIfAreaExists(areaId);

            if (!areaExists)
            {
                logMan.Error($"ProcessService.UpdateStatus -> Area not found {areaId}");
                throw new BusinessException("Area not found", ErrorCode.AreaNotFound);
            }

            var documentSegmentId = documentservice.FindDocumentSegmentIdWithWorkOrderNumberSegmentCode(request.OrderNumber, Convert.ToInt32(request.SegmentCode));

            if (documentSegmentId == 0)
            {
                InsertFailedProcesses(request, transactioId);

                logMan.Error($"ProcessService.UpdateStatus -> Wrong work order number {request.OrderNumber}");
                throw new BusinessException("Wrong work order number", ErrorCode.WrongWorkOrderNumber);
            }

            userService.CheckAndCreateTemporaryTechnician(request.Technician);

            var userId = 0;
            var user = userService.GetUserByTechnicianSAPNumber(request.TechnicianSapNumber);
            if (user.UserId != 0)
            {
                userId = user.UserId;
            }

            if (!user.IsActive)
            {
                logMan.Error($"ProcessService.UpdateStatus -> User is not active anymore. {user.UserId}");
                throw new BusinessException("User is not active anymore", ErrorCode.UserIsNotActive);
            }

            request.AreaId = areaId.ToString();

            WorkorderSegmentStatusSave(request, transactioId);

            switch (request.Status)
            {
                case ProcessStatus.Complete:
                    return CompleteSegmentProcess(request, documentSegmentId, userId, allAreaIds);
                case ProcessStatus.Finish:
                    return FinishSegmentProcess(request, documentSegmentId, userId);
                case ProcessStatus.Pause:
                    return PauseSegmentProcess(request, documentSegmentId, userId);
                case ProcessStatus.Start:
                    return StartSegmentProcess(request, documentSegmentId, userId);
            }
            logMan.Error($"ProcessService.UpdateStatus -> Wrong or missing request status {request.Status}");
            throw new BusinessException("Wrong or missing request status", ErrorCode.WrongOrMissingRequest);
        }

        private UpdateStatusResponse StartProcess(UpdateStatusRequest request, int documentId, int userId)
        {
            logMan.Info("ProcessService.StartProcess function started");
            var currentDate = DateTime.Now;
            try
            {
                currentDate = DateTime.ParseExact(request.PostDate, "yyyyMMddHHmmss", System.Globalization.CultureInfo.InvariantCulture);
            }
            catch (Exception ex)
            {
                currentDate = DateTime.Now;
            }


            string orderNumber = request.OrderNumber;
            int areaId = Convert.ToInt32(request.AreaId);
            string tecnicianSapNumber = request.TechnicianSapNumber;

            /// check if document area table is filled.. if so go on else record an item...
            var docArea = unitOfWork.GetRepository<DocumentArea>().List(x => x.DocumentId == documentId && x.AreaId == areaId && x.Status == (int)JobStatus.Initial).FirstOrDefault();
            if (docArea == null)
            {
                AddDocumentArea(areaId, documentId);
            }
            //else if (docArea.Status == (int)JobStatus.JobDone)
            //{
            //    AddDocumentArea(areaId, documentId);
            //}
            //else if (docArea.Status == (int)JobStatus.Initial)
            //{
            //    /////bişey yapılacak mı?
            //}

            //sabit block... her üç işlem içinde geçerli...
            var timers = unitOfWork.GetRepository<Timer>().List(x => x.DocumentId == documentId && x.AreaId == areaId).ToList();


            bool duplicateCheck = DuplicateCheck(timers, userId, currentDate, request.Status);
            if (duplicateCheck)
            {
                return new UpdateStatusResponse();
            }

            bool userHasActiveTimer = CheckIfUserHasActiveTimer(timers, userId, currentDate);
            if (userHasActiveTimer)
            {
                logMan.Error($"ProcessService.StartProcess -> User has already an active timer. {userId}");
                throw new BusinessException("User has already an active timer", ErrorCode.UserHasAlreadyAnActiveTimer);
            }
            else
            {
                bool mainTimerExists = timers.Where(s => s.UserId == 0 && s.DateFinish == null).Count() > 0 ? true : false;
                AddTimer(areaId, documentId, userId, mainTimerExists, currentDate);
                AddBusyUser(areaId, documentId, userId);

                PauseUsersAllOtherProcesses(areaId, documentId, userId, currentDate);
                ///  bu işlem yapılacak mı sorulacak???
                ///  multi functonal arealarda izin veriliyor..bu konusulmalı...

                ///inactivity tabloasunda date finish alanı boş kayıt varsa update edilir...
                var inactiveTimer = unitOfWork.GetRepository<TimerInactivity>().List(x => x.DocumentId == documentId && x.AreaId == areaId
                        && x.DateFinish == null).FirstOrDefault();
                if (inactiveTimer != null)
                {
                    var diffInSeconds = Convert.ToInt32((currentDate - inactiveTimer.DateStart).TotalSeconds);
                    inactiveTimer.DateFinish = currentDate;
                    inactiveTimer.DurationInSeconds = diffInSeconds;
                    unitOfWork.GetRepository<TimerInactivity>().Update(inactiveTimer);
                }
            }

            unitOfWork.SaveChanges();
            return new UpdateStatusResponse();
        }
        private UpdateStatusResponse StartSegmentProcess(UpdateStatusRequest request, int documentSegmentId, int userId)
        {
            logMan.Info("ProcessService.StartProcess Segment function started");
            var currentDate = DateTime.Now;
            try
            {
                currentDate = DateTime.ParseExact(request.PostDate, "yyyyMMddHHmmss", System.Globalization.CultureInfo.InvariantCulture);
            }
            catch (Exception ex)
            {
                currentDate = DateTime.Now;
            }


            string orderNumber = request.OrderNumber;
            int areaId = Convert.ToInt32(request.AreaId);
            string tecnicianSapNumber = request.TechnicianSapNumber;
            var docSegArea = unitOfWork.GetRepository<DocumentSegmentArea>().List(x => x.DocumentSegmentId == documentSegmentId && x.AreaId == areaId && x.Status == (int)JobStatus.Initial).FirstOrDefault();
            if (docSegArea == null)
            {
                AddDocumenSegmentArea(areaId, documentSegmentId);
            }

            var timersSegment = unitOfWork.GetRepository<TimerSegment>().List(x => x.DocumentSegmentId == documentSegmentId && x.AreaId == areaId).ToList();


            bool duplicateCheck = SegmentDuplicateCheck(timersSegment, userId, currentDate, request.Status);
            if (duplicateCheck)
            {
                return new UpdateStatusResponse();
            }

            bool userHasActiveTimerSegment = CheckIfUserHasActiveTimerSegment(timersSegment, userId, currentDate);
            if (userHasActiveTimerSegment)
            {
                logMan.Error($"ProcessService.StartProcess -> User has already an active timer. {userId}");
                throw new BusinessException("User has already an active timer", ErrorCode.UserHasAlreadyAnActiveTimer);
            }
            else
            {
                bool mainTimerSegmentExists = timersSegment.Where(s => s.UserId == 0 && s.DateFinish == null).Count() > 0 ? true : false;

                AddTimerSegment(areaId, documentSegmentId, userId, mainTimerSegmentExists, currentDate);

                AddSegmentBusyUser(areaId, documentSegmentId, userId);

                PauseUsersAllOtherSegmentProcesses(areaId, documentSegmentId, userId, currentDate);

                var inactiveTimerSegment = unitOfWork.GetRepository<TimerSegmentInactivity>().List(x => x.DocumentSegmentId == documentSegmentId && x.AreaId == areaId
                        && x.DateFinish == null).FirstOrDefault();
                if (inactiveTimerSegment != null)
                {
                    var diffInSeconds = Convert.ToInt32((currentDate - inactiveTimerSegment.DateStart).TotalSeconds);
                    inactiveTimerSegment.DateFinish = currentDate;
                    inactiveTimerSegment.DurationInSeconds = diffInSeconds;
                    unitOfWork.GetRepository<TimerSegmentInactivity>().Update(inactiveTimerSegment);
                }
            }

            unitOfWork.SaveChanges();
            return new UpdateStatusResponse();
        }

        private UpdateStatusResponse PauseProcess(UpdateStatusRequest request, int documentId, int userId)
        {
            logMan.Info("ProcessService.PauseProcess function started");
            var currentDate = DateTime.Now;
            try
            {
                currentDate = DateTime.ParseExact(request.PostDate, "yyyyMMddHHmmss", System.Globalization.CultureInfo.InvariantCulture);
            }
            catch (Exception ex)
            {
                currentDate = DateTime.Now;
            }
            string orderNumber = request.OrderNumber;
            int areaId = Convert.ToInt32(request.AreaId);
            string tecnicianSapNumber = request.TechnicianSapNumber;


            /// check if document area table is filled.. if so go on, else record an item...
            var docArea = unitOfWork.GetRepository<DocumentArea>().List(x => x.DocumentId == documentId && x.AreaId == areaId && x.Status == (int)JobStatus.Initial).FirstOrDefault(); ;
            if (docArea == null)
            {
                logMan.Error($"ProcessService.PauseProcess -> Document Area not found {documentId}");
                throw new BusinessException("Document Area not found", ErrorCode.MissingWorkOrderAtThisArea);
            }
            else
            {
                var timers = unitOfWork.GetRepository<Timer>().List(x => x.DocumentId == documentId && x.AreaId == areaId).ToList();

                bool duplicateCheck = DuplicateCheck(timers, userId, currentDate, request.Status);
                if (duplicateCheck)
                {
                    return new UpdateStatusResponse();
                }

                var userTimer = timers.Where(x => x.UserId == userId && x.DateFinish == null).FirstOrDefault();

                var otherUserTimers = timers.Where(x => x.UserId != userId && x.UserId != 0 && x.DateFinish == null).ToList();

                if (userTimer != null)
                {
                    var item = unitOfWork.GetRepository<Timer>().List(x => x.TimerId == userTimer.TimerId).FirstOrDefault();
                    var diffInSeconds = Convert.ToInt32((currentDate - item.DateStart).TotalSeconds);
                    item.DateFinish = currentDate;
                    item.DurationInSeconds = diffInSeconds;
                    unitOfWork.GetRepository<Timer>().Update(item);

                    /* if (item.UserId != 0)
                    {
                        RemoveBusyUser(item.AreaId, item.DocumentId, item.UserId);
                    }*/

                    if (otherUserTimers.Count() == 0)
                    {
                        InactivateProcess(documentId, userId, areaId, currentDate, (HoldReason)request.HoldReasonCode, request.HoldReasonText);
                    }
                }
                else
                {
                    logMan.Error($"ProcessService.PauseProcess -> User is not working on this work order {userId}");
                    throw new BusinessException("User is not working on this work order", ErrorCode.UserIsNotActiveOnThisWorkOrder);
                }
            }
            unitOfWork.SaveChanges();
            return new UpdateStatusResponse();
        }
        private UpdateStatusResponse PauseSegmentProcess(UpdateStatusRequest request, int documentSegmentId, int userId)
        {
            logMan.Info("ProcessService.PauseProcess Segment function started");
            var currentDate = DateTime.Now;
            try
            {
                currentDate = DateTime.ParseExact(request.PostDate, "yyyyMMddHHmmss", System.Globalization.CultureInfo.InvariantCulture);
            }
            catch (Exception ex)
            {
                currentDate = DateTime.Now;
            }
            string orderNumber = request.OrderNumber;
            int areaId = Convert.ToInt32(request.AreaId);
            string tecnicianSapNumber = request.TechnicianSapNumber;

            var docSegArea = unitOfWork.GetRepository<DocumentSegmentArea>().List(x => x.DocumentSegmentId == documentSegmentId && x.AreaId == areaId && x.Status == (int)JobStatus.Initial).FirstOrDefault(); ;
            if (docSegArea == null)
            {
                logMan.Error($"ProcessService.PauseProcess -> Document Area not found {documentSegmentId}");
                throw new BusinessException("Document Area not found", ErrorCode.MissingWorkOrderAtThisArea);
            }
            else
            {
                var timersSegment = unitOfWork.GetRepository<TimerSegment>().List(x => x.DocumentSegmentId == documentSegmentId && x.AreaId == areaId).ToList();

                bool duplicateCheck = SegmentDuplicateCheck(timersSegment, userId, currentDate, request.Status);
                if (duplicateCheck)
                {
                    return new UpdateStatusResponse();
                }

                var userTimerSegment = timersSegment.Where(x => x.UserId == userId && x.DateFinish == null).FirstOrDefault();

                var otherUserTimersSegment = timersSegment.Where(x => x.UserId != userId && x.UserId != 0 && x.DateFinish == null).ToList();

                if (userTimerSegment != null)
                {
                    var item = unitOfWork.GetRepository<TimerSegment>().List(x => x.TimerSegmentId == userTimerSegment.TimerSegmentId).FirstOrDefault();
                    var diffInSeconds = Convert.ToInt32((currentDate - item.DateStart).TotalSeconds);
                    item.DateFinish = currentDate;
                    item.DurationInSeconds = diffInSeconds;
                    unitOfWork.GetRepository<TimerSegment>().Update(item);

                    if (otherUserTimersSegment.Count() == 0)
                    {
                        InactivateSegmentProcess(documentSegmentId, userId, areaId, currentDate, (HoldReason)request.HoldReasonCode, request.HoldReasonText);
                    }
                }
                else
                {
                    logMan.Error($"ProcessService.PauseProcess -> User is not working on this work order {userId}");
                    throw new BusinessException("User is not working on this work order", ErrorCode.UserIsNotActiveOnThisWorkOrder);
                }
            }
            unitOfWork.SaveChanges();
            return new UpdateStatusResponse();
        }
        private UpdateStatusResponse FinishProcess(UpdateStatusRequest request, int documentId, int userId)
        {
            logMan.Info("ProcessService.FinishProcess function started");
            var currentDate = DateTime.Now;
            try
            {
                currentDate = DateTime.ParseExact(request.PostDate, "yyyyMMddHHmmss", System.Globalization.CultureInfo.InvariantCulture);
            }
            catch (Exception ex)
            {
                currentDate = DateTime.Now;
            }

            string orderNumber = request.OrderNumber;
            int areaId = Convert.ToInt32(request.AreaId);
            string tecnicianSapNumber = request.TechnicianSapNumber;


            /// check if document area table is filled.. if so go on, else record an item...
            var docArea = unitOfWork.GetRepository<DocumentArea>().List(x => x.DocumentId == documentId && x.AreaId == areaId && x.Status == (int)JobStatus.Initial).FirstOrDefault();
            if (docArea == null)
            {
                //var da = unitOfWork.GetRepository<DocumentArea>().List(x => x.DocumentId == documentId && x.AreaId == areaId && x.Status == (int)JobStatus.JobDone).FirstOrDefault();
                //if (da != null)
                //{
                //    logMan.Info("ProcessService.FinishProcess -> Document area had already finished. DocumentId:" + documentId + " / AreaId:" + areaId);
                //    return null;
                //}
                //else
                //{
                logMan.Error($"ProcessService.FinishProcess -> Document area not found {documentId}");
                throw new BusinessException("Document area not found", ErrorCode.MissingWorkOrderAtThisArea);
                //}
            }
            else
            {
                var timers = unitOfWork.GetRepository<Timer>().List(x => x.DocumentId == documentId && x.AreaId == areaId).ToList();

                bool duplicateCheck = DuplicateCheck(timers, userId, currentDate, request.Status);
                if (duplicateCheck)
                {
                    return new UpdateStatusResponse();
                }

                var otherUserTimersCount = timers.Count(x => x.UserId != userId && x.UserId != 0 && x.DateFinish == null);
                var userTimer = timers.Where(x => x.UserId == userId && x.DateFinish == null).FirstOrDefault();
                var mainTimer = timers.Where(x => x.UserId == 0 && x.DateFinish == null).FirstOrDefault();
                var inactiveTimersCount = unitOfWork.GetRepository<TimerInactivity>().Count(x => x.DocumentId == documentId && x.AreaId == areaId && x.DateFinish == null);
                if (userTimer != null)
                {
                    var item = unitOfWork.GetRepository<Timer>().List(x => x.TimerId == userTimer.TimerId).FirstOrDefault();
                    var diffInSeconds = Convert.ToInt32((currentDate - item.DateStart).TotalSeconds);
                    item.DateFinish = currentDate;
                    item.DurationInSeconds = diffInSeconds;
                    unitOfWork.GetRepository<Timer>().Update(item);

                    if (item.UserId != 0)
                    {
                        RemoveBusyUser(item.AreaId, item.DocumentId, item.UserId);
                    }


                    ///if there nobody left work this work order and No paused Job then finish the job at that area...
                    if (otherUserTimersCount == 0 && inactiveTimersCount == 0)
                    {
                        /*
                         *  Tekrar jobCompleted aktif hale getirildi.  foskan   07/02/2020...
                         * 
                         * 
                                docArea.Status = (int)JobStatus.JobDone;
                                unitOfWork.GetRepository<DocumentArea>().Update(docArea);


                                var mainitem = unitOfWork.GetRepository<Timer>().List(x => x.TimerId == mainTimer.TimerId).FirstOrDefault();
                                diffInSeconds = Convert.ToInt32((currentDate - mainitem.DateStart).TotalSeconds);
                                mainitem.DateFinish = currentDate;
                                mainitem.DurationInSeconds = diffInSeconds;
                                unitOfWork.GetRepository<Timer>().Update(mainitem);
                        */


                        //// Eski halinde Job Completed seçilmeden jobın bitirilmemesi sadece pause edilmesi yönündeydi fakat gelen taleple bu hale dönüştürüldü..
                        //// üst satırdaki comment 07/02/2020 tarihiyle geçersiz hale geldi ve yeniden complete process işlemi geldi.
                        InactivateProcess(documentId, userId, areaId, currentDate, HoldReason.Completed);
                    }
                }
                unitOfWork.SaveChanges();
                return new UpdateStatusResponse();
            }
        }
        private UpdateStatusResponse FinishSegmentProcess(UpdateStatusRequest request, int documentSegmentId, int userId)
        {
            logMan.Info("ProcessService.FinishProcess Segment function started");
            var currentDate = DateTime.Now;
            try
            {
                currentDate = DateTime.ParseExact(request.PostDate, "yyyyMMddHHmmss", System.Globalization.CultureInfo.InvariantCulture);
            }
            catch (Exception ex)
            {
                currentDate = DateTime.Now;
            }

            string orderNumber = request.OrderNumber;
            int areaId = Convert.ToInt32(request.AreaId);
            string tecnicianSapNumber = request.TechnicianSapNumber;
            var docSegArea = unitOfWork.GetRepository<DocumentSegmentArea>().List(x => x.DocumentSegmentId == documentSegmentId && x.AreaId == areaId && x.Status == (int)JobStatus.Initial).FirstOrDefault();
            if (docSegArea == null)
            {
                logMan.Error($"ProcessService.FinishProcess -> Document area not found {documentSegmentId}");
                throw new BusinessException("Document area not found", ErrorCode.MissingWorkOrderAtThisArea);
            }
            else
            {
                var timersSegment = unitOfWork.GetRepository<TimerSegment>().List(x => x.DocumentSegmentId == documentSegmentId && x.AreaId == areaId).ToList();

                bool duplicateCheckSegment = SegmentDuplicateCheck(timersSegment, userId, currentDate, request.Status);
                if (duplicateCheckSegment)
                {
                    return new UpdateStatusResponse();
                }

                var otherUserTimersSegmentCount = timersSegment.Count(x => x.UserId != userId && x.UserId != 0 && x.DateFinish == null);
                var userTimerSegment = timersSegment.Where(x => x.UserId == userId && x.DateFinish == null).FirstOrDefault();
                var mainTimerSegment = timersSegment.Where(x => x.UserId == 0 && x.DateFinish == null).FirstOrDefault();
                var inactiveTimersSegmentCount = unitOfWork.GetRepository<TimerSegmentInactivity>().Count(x => x.DocumentSegmentId == documentSegmentId && x.AreaId == areaId && x.DateFinish == null);
                if (userTimerSegment != null)
                {
                    var item = unitOfWork.GetRepository<TimerSegment>().List(x => x.TimerSegmentId == userTimerSegment.TimerSegmentId).FirstOrDefault();
                    var diffInSeconds = Convert.ToInt32((currentDate - item.DateStart).TotalSeconds);
                    item.DateFinish = currentDate;
                    item.DurationInSeconds = diffInSeconds;
                    unitOfWork.GetRepository<TimerSegment>().Update(item);

                    if (item.UserId != 0)
                    {
                        RemoveSegmentBusyUser(item.AreaId, item.DocumentSegmentId, item.UserId);
                    }
                    if (otherUserTimersSegmentCount == 0 && inactiveTimersSegmentCount == 0)
                    {
                        InactivateSegmentProcess(documentSegmentId, userId, areaId, currentDate, HoldReason.Completed);
                    }
                }
                unitOfWork.SaveChanges();
                return new UpdateStatusResponse();
            }
        }
        private UpdateStatusResponse CompleteProcess(UpdateStatusRequest request, int documentId, int userId, List<int> allAreaIds)
        {
            logMan.Info("ProcessService.CompleteProcess function started");
            var currentDate = DateTime.Now;
            try
            {
                currentDate = DateTime.ParseExact(request.PostDate, "yyyyMMddHHmmss", System.Globalization.CultureInfo.InvariantCulture);
            }
            catch (Exception ex)
            {
                currentDate = DateTime.Now;
            }

            string orderNumber = request.OrderNumber;
            string tecnicianSapNumber = request.TechnicianSapNumber;

            int areaIdToAdd = Convert.ToInt32(request.AreaId);

            if (!allAreaIds.Any())
            {
                allAreaIds = new List<int>();
                allAreaIds.Add(areaIdToAdd);
            }

            /// bir weking atamasıyla yapılan tüm aalan işleri bitirilir....
            foreach (int areaId in allAreaIds)
            {
                /// check if document area table is filled.. if so go on, else record an item...
                var docArea = unitOfWork.GetRepository<DocumentArea>().List(x => x.DocumentId == documentId && x.AreaId == areaId && x.Status == (int)JobStatus.Initial).FirstOrDefault(); ;
                if (docArea == null)
                {
                    logMan.Error($"Document area not found {areaId}");
                    throw new BusinessException("Document area not found", ErrorCode.MissingWorkOrderAtThisArea);
                }
                else
                {
                    var timers = unitOfWork.GetRepository<Timer>().List(x => x.DocumentId == documentId && x.AreaId == areaId && x.DateFinish == null).ToList();

                    if (timers != null)
                    {
                        foreach (var item in timers)
                        {
                            var diffInSeconds = Convert.ToInt32((currentDate - item.DateStart).TotalSeconds);
                            item.DateFinish = currentDate;
                            item.DurationInSeconds = diffInSeconds;
                            unitOfWork.GetRepository<Timer>().Update(item);

                            if (item.UserId != 0)
                            {
                                RemoveBusyUser(item.AreaId, item.DocumentId, item.UserId);
                            }
                        }
                    }

                    var inactiveTimers = unitOfWork.GetRepository<TimerInactivity>().List(x => x.DocumentId == documentId && x.AreaId == areaId && x.DateFinish == null).ToList();
                    foreach (var item in inactiveTimers)
                    {
                        var diffInSeconds = Convert.ToInt32((currentDate - item.DateStart).TotalSeconds);
                        item.DateFinish = currentDate;
                        item.DurationInSeconds = diffInSeconds;
                        unitOfWork.GetRepository<TimerInactivity>().Update(item);
                    }


                    var docAreaList = unitOfWork.GetRepository<DocumentArea>().List(x => x.DocumentId == documentId && x.AreaId == areaId && x.Status == (int)JobStatus.Initial);
                    foreach (var item in docAreaList)
                    {
                        item.Status = (int)JobStatus.JobDone;
                        unitOfWork.GetRepository<DocumentArea>().Update(item);
                    }
                }
            }

            unitOfWork.SaveChanges();
            return new UpdateStatusResponse();
        }
        private UpdateStatusResponse CompleteSegmentProcess(UpdateStatusRequest request, int documentSegmentId, int userId, List<int> allAreaIds)
        {
            logMan.Info("ProcessService.CompleteProcess Segment function started");
            var currentDate = DateTime.Now;
            try
            {
                currentDate = DateTime.ParseExact(request.PostDate, "yyyyMMddHHmmss", System.Globalization.CultureInfo.InvariantCulture);
            }
            catch (Exception ex)
            {
                currentDate = DateTime.Now;
            }

            string orderNumber = request.OrderNumber;
            string tecnicianSapNumber = request.TechnicianSapNumber;

            int areaIdToAdd = Convert.ToInt32(request.AreaId);

            if (!allAreaIds.Any())
            {
                allAreaIds = new List<int>();
                allAreaIds.Add(areaIdToAdd);
            }

            /// bir weking atamasıyla yapılan tüm aalan işleri bitirilir....
            foreach (int areaId in allAreaIds)
            {
                /// check if document area table is filled.. if so go on, else record an item...
                var docSegArea = unitOfWork.GetRepository<DocumentSegmentArea>().List(x => x.DocumentSegmentId == documentSegmentId && x.AreaId == areaId && x.Status == (int)JobStatus.Initial).FirstOrDefault(); ;
                if (docSegArea == null)
                {
                    logMan.Error($"Document area not found {areaId}");
                    throw new BusinessException("Document area not found", ErrorCode.MissingWorkOrderAtThisArea);
                }
                else
                {
                    var timersSegment = unitOfWork.GetRepository<TimerSegment>().List(x => x.DocumentSegmentId == documentSegmentId && x.AreaId == areaId && x.DateFinish == null).ToList();

                    if (timersSegment != null)
                    {
                        foreach (var item in timersSegment)
                        {
                            var diffInSeconds = Convert.ToInt32((currentDate - item.DateStart).TotalSeconds);
                            item.DateFinish = currentDate;
                            item.DurationInSeconds = diffInSeconds;
                            unitOfWork.GetRepository<TimerSegment>().Update(item);

                            if (item.UserId != 0)
                            {
                                RemoveSegmentBusyUser(item.AreaId, item.DocumentSegmentId, item.UserId);
                            }
                        }
                    }

                    var inactiveTimersSegment = unitOfWork.GetRepository<TimerSegmentInactivity>().List(x => x.DocumentSegmentId == documentSegmentId && x.AreaId == areaId && x.DateFinish == null).ToList();
                    foreach (var item in inactiveTimersSegment)
                    {
                        var diffInSeconds = Convert.ToInt32((currentDate - item.DateStart).TotalSeconds);
                        item.DateFinish = currentDate;
                        item.DurationInSeconds = diffInSeconds;
                        unitOfWork.GetRepository<TimerSegmentInactivity>().Update(item);
                    }


                    var docAreaSegList = unitOfWork.GetRepository<DocumentSegmentArea>().List(x => x.DocumentSegmentId == documentSegmentId && x.AreaId == areaId && x.Status == (int)JobStatus.Initial);
                    foreach (var item in docAreaSegList)
                    {
                        item.Status = (int)JobStatus.JobDone;
                        unitOfWork.GetRepository<DocumentSegmentArea>().Update(item);
                    }
                }
            }

            unitOfWork.SaveChanges();
            return new UpdateStatusResponse();
        }

        private void InactivateProcess(int documentId, int userId, int areaId, DateTime currentDate, HoldReason reason, string holdReasonText = null)
        {
            var mainTimer = unitOfWork.GetRepository<Timer>().List(x => x.DocumentId == documentId && x.AreaId == areaId && x.UserId == 0 && x.DateFinish == null).FirstOrDefault();
            var mainTimerDiffInSeconds = Convert.ToInt32((currentDate - mainTimer.DateStart).TotalSeconds);
            mainTimer.DateFinish = currentDate;
            mainTimer.DurationInSeconds = mainTimerDiffInSeconds;
            unitOfWork.GetRepository<Timer>().Update(mainTimer);

            /// if nobody works on the job then add row to timerInactivity...
            /// timerinactivity is just for the job not for the user...sergey said if everybodu paused then add one row..
            var inactiveTimers = unitOfWork.GetRepository<TimerInactivity>().List(x => x.DocumentId == documentId && x.AreaId == areaId
                 && x.UserId == userId && x.DateFinish == null).FirstOrDefault();

            if (inactiveTimers == null)
            {
                var inactivity = new TimerInactivity
                {
                    DocumentId = documentId,
                    AreaId = areaId,
                    DateStart = currentDate,
                    StatusId = (int)reason,
                    Comment = (string.IsNullOrEmpty(holdReasonText) ? "" : holdReasonText)
                };

                unitOfWork.GetRepository<TimerInactivity>().Add(inactivity);
            }

            unitOfWork.SaveChanges();
        }
        private void InactivateSegmentProcess(int documentSegmentId, int userId, int areaId, DateTime currentDate, HoldReason reason, string holdReasonText = null)
        {
            var mainTimerSegment = unitOfWork.GetRepository<TimerSegment>().List(x => x.DocumentSegmentId == documentSegmentId && x.AreaId == areaId && x.UserId == 0 && x.DateFinish == null).FirstOrDefault();
            var mainTimerSegmentDiffInSeconds = Convert.ToInt32((currentDate - mainTimerSegment.DateStart).TotalSeconds);
            mainTimerSegment.DateFinish = currentDate;
            mainTimerSegment.DurationInSeconds = mainTimerSegmentDiffInSeconds;
            unitOfWork.GetRepository<TimerSegment>().Update(mainTimerSegment);

            var inactiveTimersSegment = unitOfWork.GetRepository<TimerSegmentInactivity>().List(x => x.DocumentSegmentId == documentSegmentId && x.AreaId == areaId
                 && x.UserId == userId && x.DateFinish == null).FirstOrDefault();

            if (inactiveTimersSegment == null)
            {
                var inactivitySegment = new TimerSegmentInactivity
                {
                    DocumentSegmentId = documentSegmentId,
                    AreaId = areaId,
                    DateStart = currentDate,
                    StatusId = (int)reason,
                    Comment = (string.IsNullOrEmpty(holdReasonText) ? "" : holdReasonText)
                };

                unitOfWork.GetRepository<TimerSegmentInactivity>().Add(inactivitySegment);
            }

            unitOfWork.SaveChanges();
        }
        private void AddDocumentArea(int areaId, int documentId)
        {
            DocumentArea newDoc = new DocumentArea
            {
                AreaId = areaId,
                DocumentId = documentId,
                Status = (int)JobStatus.Initial,
                MaxHours = 0.0M
            };

            unitOfWork.GetRepository<DocumentArea>().Add(newDoc);
        }
        private void AddDocumenSegmentArea(int areaId, int documentSegmentId)
        {
            DocumentSegmentArea newDocSeg = new DocumentSegmentArea
            {
                DocumentSegmentId = documentSegmentId,
                AreaId = areaId,
                Status = (int)JobStatus.Initial,
                MaxHours = 0.0M
            };

            unitOfWork.GetRepository<DocumentSegmentArea>().Add(newDocSeg);
        }
        private void PauseUsersAllOtherProcesses(int areaId, int documentId, int userId, DateTime currentDate)
        {
            var timers = unitOfWork.GetRepository<Timer>().List(x => x.UserId == userId && x.DocumentId != documentId && x.AreaId != areaId && x.DateFinish == null).ToList();
            if (timers != null)
            {
                foreach (var item in timers)
                {
                    var diffInSeconds = Convert.ToInt32((currentDate - item.DateStart).TotalSeconds);
                    item.DateFinish = currentDate;
                    item.DurationInSeconds = diffInSeconds;
                    unitOfWork.GetRepository<Timer>().Update(item);


                    /// is there any other working technician on the job?if not pause the job and add row to timerInactivity...
                    var otherTimers = unitOfWork.GetRepository<Timer>().List(x => x.UserId != item.UserId && x.UserId != 0 && x.DocumentId == item.DocumentId && x.AreaId == item.AreaId && x.DateFinish == null).ToList();
                    var mainTimer = unitOfWork.GetRepository<Timer>().List(x => x.UserId == 0 && x.DocumentId == item.DocumentId && x.AreaId == item.AreaId && x.DateFinish == null).FirstOrDefault();
                    if (otherTimers == null || otherTimers.Count() == 0)
                    {
                        if (mainTimer != null)
                        {
                            var mainDiffInSeconds = Convert.ToInt32((currentDate - mainTimer.DateStart).TotalSeconds);
                            mainTimer.DurationInSeconds = mainDiffInSeconds;
                            mainTimer.DateFinish = currentDate;
                            unitOfWork.GetRepository<Timer>().Update(mainTimer);


                            var area = unitOfWork.GetRepository<Area>().List(x => x.AreaId == areaId).FirstOrDefault();
                            var areaName = string.Empty;
                            if (area != null)
                            {
                                areaName = area.FullName.ToLower();
                            }

                            var documentNumber = unitOfWork.GetRepository<Document>().List(x => x.DocumentId == item.DocumentId).Select(x => x.DocumentNumber.TrimStart('0')).FirstOrDefault();


                            var inactivity = new TimerInactivity
                            {
                                UserId = 0,
                                DurationInSeconds = 0,
                                DocumentId = item.DocumentId,
                                AreaId = item.AreaId,
                                DateStart = currentDate,
                                StatusId = (int)HoldReason.StartedNewProcess,
                                Comment = String.Format("{1} alanında {0} numaralı iş emri üzerinde çalışmaya başladı.", documentNumber, areaName)
                            };

                            unitOfWork.GetRepository<TimerInactivity>().Add(inactivity);
                        }
                    }
                }
            }
        }
        private void PauseUsersAllOtherSegmentProcesses(int areaId, int documentSegmentId, int userId, DateTime currentDate)
        {
            var timersSegment = unitOfWork.GetRepository<TimerSegment>().List(x => x.UserId == userId && x.DocumentSegmentId != documentSegmentId && x.AreaId != areaId && x.DateFinish == null).ToList();
            if (timersSegment != null)
            {
                foreach (var item in timersSegment)
                {
                    var diffInSeconds = Convert.ToInt32((currentDate - item.DateStart).TotalSeconds);
                    item.DateFinish = currentDate;
                    item.DurationInSeconds = diffInSeconds;
                    unitOfWork.GetRepository<TimerSegment>().Update(item);
                    var otherTimersSegment = unitOfWork.GetRepository<TimerSegment>().List(x => x.UserId != item.UserId && x.UserId != 0 && x.DocumentSegmentId == item.DocumentSegmentId && x.AreaId == item.AreaId && x.DateFinish == null).ToList();
                    var mainTimerSegment = unitOfWork.GetRepository<TimerSegment>().List(x => x.UserId == 0 && x.DocumentSegmentId == item.DocumentSegmentId && x.AreaId == item.AreaId && x.DateFinish == null).FirstOrDefault();
                    if (otherTimersSegment == null || otherTimersSegment.Count() == 0)
                    {
                        if (mainTimerSegment != null)
                        {
                            var mainDiffInSeconds = Convert.ToInt32((currentDate - mainTimerSegment.DateStart).TotalSeconds);
                            mainTimerSegment.DurationInSeconds = mainDiffInSeconds;
                            mainTimerSegment.DateFinish = currentDate;
                            unitOfWork.GetRepository<TimerSegment>().Update(mainTimerSegment);


                            var area = unitOfWork.GetRepository<Area>().List(x => x.AreaId == areaId).FirstOrDefault();
                            var areaName = string.Empty;
                            if (area != null)
                            {
                                areaName = area.FullName.ToLower();
                            }

                            var documentNumber = unitOfWork.GetRepository<DocumentSegment>().List(x => x.DocumentSegmentId == item.DocumentSegmentId).Select(x => x.DocumentNumber.TrimStart('0')).FirstOrDefault();


                            var inactivitySegment = new TimerSegmentInactivity
                            {
                                UserId = 0,
                                DurationInSeconds = 0,
                                DocumentSegmentId = item.DocumentSegmentId,
                                AreaId = item.AreaId,
                                DateStart = currentDate,
                                StatusId = (int)HoldReason.StartedNewProcess,
                                Comment = String.Format("{1} alanında {0} numaralı iş emri üzerinde çalışmaya başladı.", documentNumber, areaName)
                            };

                            unitOfWork.GetRepository<TimerSegmentInactivity>().Add(inactivitySegment);
                        }
                    }
                }
            }
        }
        public bool CheckIfUserHasActiveTimer(List<Timer> timerList, int userId, DateTime postDate)
        {
            var userTimers = timerList.Where(s => s.UserId == userId);

            if (userTimers.Count() > 0)
            {
                if (userTimers.Where(x => x.DateFinish == null || x.DateFinish == DateTime.MinValue).Count() > 0)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
            else
            {
                return false;
            }
        }
        public bool CheckIfUserHasActiveTimerSegment(List<TimerSegment> timerList, int userId, DateTime postDate)
        {
            var userTimers = timerList.Where(s => s.UserId == userId);

            if (userTimers.Count() > 0)
            {
                if (userTimers.Where(x => x.DateFinish == null || x.DateFinish == DateTime.MinValue).Count() > 0)
                {
                    return true;
                }
                else
                {
                    return false;
                }
            }
            else
            {
                return false;
            }
        }

        public bool DuplicateCheck(List<Timer> timerList, int userId, DateTime postDate, ProcessStatus processStatus)
        {
            if (processStatus == ProcessStatus.Start)
            {
                if (timerList.Where(x => x.UserId == userId && x.DateStart == postDate).Count() > 0)
                {
                    logMan.Warn($" Duplicate status check userId : {userId} , document Id: { timerList.First().DocumentId } , areaId : { timerList.First().AreaId} , postDate : { postDate } , processStatus : { processStatus }");
                    return true;
                }
            }
            else if (processStatus == ProcessStatus.Pause || processStatus == ProcessStatus.Finish)
            {
                if (timerList.Where(x => x.UserId == userId && x.DateFinish == postDate).Count() > 0)
                {
                    logMan.Warn($" Duplicate status check userId : {userId} , document Id: { timerList.First().DocumentId } , areaId : { timerList.First().AreaId} , postDate : { postDate } , processStatus : { processStatus }");
                    return true;
                }
            }
            else if (processStatus == ProcessStatus.Complete)
            {
                logMan.Warn($" Duplicate status check userId : {userId} , document Id: { timerList.First().DocumentId } , areaId : { timerList.First().AreaId} , postDate : { postDate } , processStatus : { processStatus }");
            }
            return false;
        }
        public bool SegmentDuplicateCheck(List<TimerSegment> timerList, int userId, DateTime postDate, ProcessStatus processStatus)
        {
            if (processStatus == ProcessStatus.Start)
            {
                if (timerList.Where(x => x.UserId == userId && x.DateStart == postDate).Count() > 0)
                {
                    logMan.Warn($" Duplicate status check userId : {userId} , document segment Id: { timerList.First().DocumentSegmentId } , areaId : { timerList.First().AreaId} , postDate : { postDate } , processStatus : { processStatus }");
                    return true;
                }
            }
            else if (processStatus == ProcessStatus.Pause || processStatus == ProcessStatus.Finish)
            {
                if (timerList.Where(x => x.UserId == userId && x.DateFinish == postDate).Count() > 0)
                {
                    logMan.Warn($" Duplicate status check userId : {userId} , document segment Id: { timerList.First().DocumentSegmentId } , areaId : { timerList.First().AreaId} , postDate : { postDate } , processStatus : { processStatus }");
                    return true;
                }
            }
            else if (processStatus == ProcessStatus.Complete)
            {
                logMan.Warn($" Duplicate status check userId : {userId} , document segment Id: { timerList.First().DocumentSegmentId } , areaId : { timerList.First().AreaId} , postDate : { postDate } , processStatus : { processStatus }");
            }
            return false;
        }

        private void AddTimer(int areaId, int documentId, int userId, bool mainTimerExists, DateTime currentDate)
        {
            if (!mainTimerExists)
            {
                Timer mainItem = new Timer
                {
                    AreaId = areaId,
                    DocumentId = documentId,
                    UserId = 0,
                    DateStart = currentDate
                };
                unitOfWork.GetRepository<Timer>().Add(mainItem);
            }

            Timer item = new Timer
            {
                AreaId = areaId,
                DocumentId = documentId,
                UserId = userId,
                DateStart = currentDate
            };

            unitOfWork.GetRepository<Timer>().Add(item);
        }
        private void AddTimerSegment(int areaId, int documentSegmentId, int userId, bool mainTimerSegmentExists, DateTime currentDate)
        {
            if (!mainTimerSegmentExists)
            {
                TimerSegment mainItem = new TimerSegment
                {
                    UserId = 0,
                    AreaId = areaId,
                    DocumentSegmentId = documentSegmentId,
                    DateStart = currentDate
                };
                unitOfWork.GetRepository<TimerSegment>().Add(mainItem);
            }

            TimerSegment item = new TimerSegment
            {
                UserId = userId,
                AreaId = areaId,
                DocumentSegmentId = documentSegmentId,
                DateStart = currentDate
            };

            unitOfWork.GetRepository<TimerSegment>().Add(item);
        }

        private void AddBusyUser(int areaId, int documentId, int userId)
        {

            var userExists = unitOfWork.GetRepository<BusyUser>().Count(x => x.AreaId == areaId && x.DocumentId == documentId && x.UserId == userId) > 0 ? true : false;

            if (!userExists)
            {
                BusyUser busyUser = new BusyUser
                {
                    AreaId = areaId,
                    DocumentId = documentId,
                    UserId = userId
                };
                unitOfWork.GetRepository<BusyUser>().Add(busyUser);
            }
        }
        private void AddSegmentBusyUser(int areaId, int documentSegmentId, int userId)
        {

            var userExists = unitOfWork.GetRepository<SegmentBusyUser>().Count(x => x.AreaId == areaId && x.DocumentSegmentId == documentSegmentId && x.UserId == userId) > 0 ? true : false;

            if (!userExists)
            {
                SegmentBusyUser segmentBusyUser = new SegmentBusyUser
                {
                    AreaId = areaId,
                    DocumentSegmentId = documentSegmentId,
                    UserId = userId
                };
                unitOfWork.GetRepository<SegmentBusyUser>().Add(segmentBusyUser);
            }
        }
        private void RemoveBusyUser(int areaId, int documentId, int userId)
        {
            var busyUser = unitOfWork.GetRepository<BusyUser>().List(x => x.AreaId == areaId && x.DocumentId == documentId && x.UserId == userId).FirstOrDefault();
            if (busyUser != null)
            {

                unitOfWork.GetRepository<BusyUser>().Delete(busyUser);
            }
        }
        private void RemoveSegmentBusyUser(int areaId, int documentSegmentId, int userId)
        {
            var segmentBusyUser = unitOfWork.GetRepository<SegmentBusyUser>().List(x => x.AreaId == areaId && x.DocumentSegmentId == documentSegmentId && x.UserId == userId).FirstOrDefault();
            if (segmentBusyUser != null)
            {

                unitOfWork.GetRepository<SegmentBusyUser>().Delete(segmentBusyUser);
            }
        }
        private void InsertFailedProcesses(UpdateStatusRequest request, string transactioId)
        {
            try
            {
                var failedProcess = unitOfWork.GetRepository<FailedProcess>().List(x => x.TransactionId == transactioId).Select(x => x).FirstOrDefault();

                if (failedProcess == null)
                {
                    failedProcess = new FailedProcess();
                    failedProcess.TransactionId = transactioId;
                    failedProcess.PostDate = DateTime.ParseExact(request.PostDate, "yyyyMMddHHmmss", System.Globalization.CultureInfo.InvariantCulture);
                    failedProcess.CreateDate = DateTime.Now;
                    failedProcess.RawRequest = Newtonsoft.Json.JsonConvert.SerializeObject(request);
                    failedProcess.Status = (int)FailedProcessStatus.NotSend;
                    failedProcess.DocumentNumber = request.OrderNumber;
                    unitOfWork.GetRepository<FailedProcess>().Add(failedProcess);
                    unitOfWork.SaveChanges();
                }
            }
            catch (Exception ex)
            {
                System.Text.StringBuilder sb = new System.Text.StringBuilder();
                string excMessage = ex.Message != null ? ex.Message : "";
                sb.Append(excMessage);

                string excStack = ex.StackTrace != null ? ex.StackTrace : "";
                sb.Append(excStack);

                logMan.Error(sb.ToString());
            }
        }

        public void RetryFailedProcesses()
        {
            var failedProcessesList = from m in unitOfWork.GetRepository<Document>().List(x => x.USERSTATUS != "Closed" && x.USERSTATUS != "Cancel" && x.USERSTATUS != "Completed")
                                      join t in unitOfWork.GetRepository<FailedProcess>().List(x => x.Status == (int)FailedProcessStatus.NotSend) on m.DocumentNumber equals t.DocumentNumber.PadLeft(10, '0')
                                      orderby t.PostDate ascending
                                      select t;

            foreach (var failedItem in failedProcessesList)
            {
                try
                {
                    logMan.Info(string.Format("Trying to Send Transaction: {0} , WorkOrder : {1}", failedItem.TransactionId, failedItem.DocumentNumber));

                    UpdateStatusRequest failedRequestBody = Newtonsoft.Json.JsonConvert.DeserializeObject<UpdateStatusRequest>(failedItem.RawRequest);
                    string transactionId = failedItem.TransactionId;

                    UpdateStatus(failedRequestBody, transactionId);

                    FailedProcess failedProcess = unitOfWork.GetRepository<FailedProcess>().List(x => x.FailedProcessId == failedItem.FailedProcessId).Select(x => x).Single();
                    failedProcess.Status = (int)FailedProcessStatus.Send;

                    unitOfWork.GetRepository<FailedProcess>().Update(failedProcess);
                    unitOfWork.SaveChanges();
                }
                catch (Exception ex)
                {
                    System.Text.StringBuilder sb = new System.Text.StringBuilder();
                    string excMessage = ex.Message != null ? ex.Message : "";
                    sb.Append(excMessage);

                    string excStack = ex.StackTrace != null ? ex.StackTrace : "";
                    sb.Append(excStack);

                    logMan.Error(sb.ToString());
                }
            }
        }
        public void WorkorderSegmentStatusSave(UpdateStatusRequest request, string transactioId)
        {
            var OrderNumberFeedWithZero = FeedWithZero(request.OrderNumber);

            var workorderSegmentStatus = unitOfWork.GetRepository<WorkorderSegmentStatus>().List().Where(x => x.DocumentNumber == OrderNumberFeedWithZero && x.SegmentCode == Convert.ToInt32(request.SegmentCode)).FirstOrDefault();

            var sAllAreaIds = "";

            if (request != null)
            {
                if (request.AllAreaIds != null)
                {
                    int n = 1;
                    int areaCount = request.AllAreaIds.Count();
                    foreach (var AreaId in request.AllAreaIds)
                    {
                        sAllAreaIds += AreaId;
                        if (n < areaCount)
                        {
                            sAllAreaIds += ";";
                        }
                        n += 1;
                    }
                }


                if (workorderSegmentStatus != null)
                {

                    workorderSegmentStatus.TransactionId = Convert.ToInt64(transactioId);
                    workorderSegmentStatus.DocumentNumber = OrderNumberFeedWithZero;
                    workorderSegmentStatus.SegmentCode = Convert.ToInt32(request.SegmentCode);
                    workorderSegmentStatus.AreaId = Convert.ToInt32(request.AreaId);
                    workorderSegmentStatus.TechnicianSapNumber = Convert.ToInt64(request.TechnicianSapNumber);
                    workorderSegmentStatus.TechnicianBpNo = Convert.ToInt64(request.Technician.BpNo);
                    workorderSegmentStatus.Status = request.Status.ToString();
                    workorderSegmentStatus.PostDate = DateTime.ParseExact(request.PostDate, "yyyyMMddHHmmss", System.Globalization.CultureInfo.InvariantCulture);
                    workorderSegmentStatus.HoldReasonCode = request.HoldReasonCode;
                    workorderSegmentStatus.HoldReasonText = request.HoldReasonText;
                    workorderSegmentStatus.AllAreaIds = sAllAreaIds;
                    workorderSegmentStatus.SchedulerJobType = request.SchedulerJobType;
                    workorderSegmentStatus.ComponentCode = Convert.ToInt32(request.ComponentCode);
                    workorderSegmentStatus.JobCode = request.JobCode;
                    workorderSegmentStatus.ElementNumber = Convert.ToInt32(request.ElementNumber);
                    workorderSegmentStatus.Language = request.Language;
                    workorderSegmentStatus.SalesOffice = request.SalesOffice;
                    unitOfWork.GetRepository<WorkorderSegmentStatus>().Update(workorderSegmentStatus);
                }
                else
                {
                    unitOfWork.GetRepository<WorkorderSegmentStatus>().Add(new WorkorderSegmentStatus
                    {
                        TransactionId = Convert.ToInt64(transactioId),
                        DocumentNumber = OrderNumberFeedWithZero,
                        SegmentCode = Convert.ToInt32(request.SegmentCode),
                        AreaId = Convert.ToInt32(request.AreaId),
                        TechnicianSapNumber = Convert.ToInt64(request.TechnicianSapNumber),
                        TechnicianBpNo = Convert.ToInt64(request.Technician.BpNo),
                        Status = request.Status.ToString(),
                        PostDate = DateTime.ParseExact(request.PostDate, "yyyyMMddHHmmss", System.Globalization.CultureInfo.InvariantCulture),
                        HoldReasonCode = request.HoldReasonCode,
                        HoldReasonText = request.HoldReasonText,
                        AllAreaIds = sAllAreaIds,
                        SchedulerJobType = request.SchedulerJobType,
                        ComponentCode = Convert.ToInt32(request.ComponentCode),
                        JobCode = request.JobCode,
                        ElementNumber = Convert.ToInt32(request.ElementNumber),
                        Language = request.Language,
                        SalesOffice = request.SalesOffice
                    });
                }
                unitOfWork.SaveChanges();
            }

            WorkorderSegmentStatusLogSave(request, transactioId);
        }
        public void WorkorderSegmentStatusLogSave(UpdateStatusRequest request, string transactioId)
        {
            var OrderNumberFeedWithZero = FeedWithZero(request.OrderNumber);

            var sAllAreaIds = "";

            if (request != null)
            {
                if (request.AllAreaIds != null)
                {
                    int n = 1;
                    int areaCount = request.AllAreaIds.Count();
                    foreach (var AreaId in request.AllAreaIds)
                    {
                        sAllAreaIds += AreaId ;
                        if(n< areaCount)
                        {
                            sAllAreaIds += ";";
                        }
                        n += 1;
                    }
                }
                unitOfWork.GetRepository<WorkorderSegmentStatusLog>().Add(new WorkorderSegmentStatusLog
                {

                    TransactionId = Convert.ToInt64(transactioId),
                    DocumentNumber = OrderNumberFeedWithZero,
                    SegmentCode = Convert.ToInt32(request.SegmentCode),
                    AreaId = Convert.ToInt32(request.AreaId),
                    TechnicianSapNumber = Convert.ToInt64(request.TechnicianSapNumber),
                    TechnicianBpNo = Convert.ToInt64(request.Technician.BpNo),
                    Status = request.Status.ToString(),
                    PostDate = DateTime.ParseExact(request.PostDate, "yyyyMMddHHmmss", System.Globalization.CultureInfo.InvariantCulture),
                    HoldReasonCode = request.HoldReasonCode,
                    HoldReasonText = request.HoldReasonText,
                    AllAreaIds = sAllAreaIds,
                    SchedulerJobType = request.SchedulerJobType,
                    ComponentCode = Convert.ToInt32(request.ComponentCode),
                    JobCode = request.JobCode,
                    ElementNumber = Convert.ToInt32(request.ElementNumber),
                    Language = request.Language,
                    SalesOffice = request.SalesOffice
                });
                unitOfWork.SaveChanges();
            }
        }
        private string FeedWithZero(string documentNumber)
        {
            string feedLines = string.Empty;
            for (int i = 0; i < 10 - documentNumber.Length; i++)
            {
                feedLines += "0";
            }
            return string.Format("{0}{1}", feedLines, documentNumber);
        }
    }
}
