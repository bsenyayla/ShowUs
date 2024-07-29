using System;
using System.Collections.Generic;
using System.Linq;
using CRCAPI.Services.Filters;
using CRCAPI.Services.Interfaces;
using CRCAPI.Services.Models.CrcTransfer;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using StandartLibrary.Models.EntityModels;
using StandartLibrary.Models.Enums;
using StandartLibrary.Models.ViewModels.CrcComponentTransfer;

namespace Crcapi.Controllers
{
    [Authorize(AuthenticationSchemes = "BasicAuthentication")]
    [Route("api/[controller]")]
    [ApiController]
    public class CdomsCrcComponentTransferController : Controller
    {
        private readonly ICrcTransferService crcTransferService;
        private readonly ICrmService crmService;
        private readonly IAttachmentService attachmentService;

        public CdomsCrcComponentTransferController(ICrcTransferService crcTransferService, ICrmService crmService, IAttachmentService attachmentService)
        {
            this.crcTransferService = crcTransferService;
            this.crmService = crmService;
            this.attachmentService = attachmentService;
        }

        [HttpGet("outgoingrequestitems")]
        [ServiceFilter(typeof(UserActivityFilter))]
        public ActionResult<CrcTransferRequestsResponse> OutgoingRequestItems([FromQuery] JqueryDatatableParam parameters, [FromQuery] int sortColumnIndex, [FromQuery] string sortDirection)
        {
            try
            {
                return crcTransferService.GetInternalRequestList(parameters, sortColumnIndex, sortDirection);
            }
            catch (Exception e)
            {
                throw;
            }
        }

        [HttpGet("edit/{id}")]
        [ServiceFilter(typeof(UserActivityFilter))]
        public ActionResult<InternalRequestDetailView> Edit(Guid id)
        {
            try
            {
                var detailModel = crcTransferService.GetInternalRequest(id);
                if (detailModel == null)
                {
                    NotFound(id);
                }

                return detailModel;
            }
            catch (Exception e)
            {
                throw;
            }
        }

        [HttpGet("GetWorkStatus")]
        [ServiceFilter(typeof(UserActivityFilter))]
        public ActionResult<List<WorkStatusModel>> GetWorkStatus(string documentId)
        {
            try
            {
                var workStatusList = crcTransferService.GetWorkStatus(documentId);
                if (workStatusList == null)
                {
                    NotFound();
                }

                return workStatusList;
            }
            catch (Exception e)
            {
                throw;
            }
        }

        [HttpPost("create")]
        [ServiceFilter(typeof(UserActivityFilter))]
        public ActionResult<Guid> Create([FromForm] CrcComponentTransferCreateOrEditModel model)
        {
            try
            {
                #region Set DocumentId

                var documentId = crmService.BindWorkOrder(model.TransferWorkOrder);
                if (documentId < 0)
                {
                    throw new Exception($"Binding WorkOrder exception => [{(WorkOrderBindingError)documentId}]");
                }
                model.DocumentId = documentId;

                #endregion

                #region Create Transfer Request

                var crcTransfer = crcTransferService.CreateInternalRequest(model);

                #endregion

                #region Upload Files

                try
                {
                    attachmentService.SaveFile(model.Attachments, documentId, UploadType.InternalRequest, model.CreateUser, model.CreateUser);
                    attachmentService.SaveFile(model.Components, model.DocumentId, UploadType.InternalRequestComponent, model.CreateUser, model.CreateUser);
                }
                catch (Exception ex)
                {
                    // ignore
                }

                #endregion

                return crcTransfer.Id;
            }
            catch (Exception e)
            {
                throw;
            }
        }

        [HttpPost("edit")]
        [ServiceFilter(typeof(UserActivityFilter))]
        public ActionResult<Guid> Edit([FromForm] CrcComponentTransferCreateOrEditModel model)
        {
            try
            {
                #region Edit Transfer Request

                var crcTransfer = crcTransferService.EditInternalRequest(model);

                #endregion

                #region Upload Files

                try
                {
                    attachmentService.SaveFile(model.Attachments, model.DocumentId, StandartLibrary.Models.Enums.UploadType.InternalRequest, model.CreateUser, model.CreateUser);
                    attachmentService.SaveFile(model.Components, model.DocumentId, StandartLibrary.Models.Enums.UploadType.InternalRequestComponent, model.CreateUser, model.CreateUser);
                }
                catch (Exception ex)
                {
                    // ignore
                }

                #endregion

                return crcTransfer.Id;
            }
            catch (Exception e)
            {
                throw;
            }
        }

        [HttpPost("delete")]
        [ServiceFilter(typeof(UserActivityFilter))]
        public IActionResult Delete([FromBody] DeleteInternalRequestInput input)
        {
            try
            {
                var result = crcTransferService.DeleteInternalRequest(input.Id, input.LoggedUser);

                return Json(result);
            }
            catch (Exception e)
            {
                throw;
            }
        }
    }
}