using System;
using System.Collections.Generic;
using Microsoft.AspNetCore.Http;

namespace CRCAPI.Services.Models.CrcTransfer
{
    public class CrcComponentTransferCreateOrEditModel
    {
        public Guid Id { get; set; }

        public List<IFormFile> Attachments { get; set; } = new List<IFormFile>();

        public string CurrentWorkOrder { get; set; }

        public string TransferWorkOrder { get; set; }

        public string ComponentSerialNo { get; set; }

        public string CustomerNumber { get; set; }

        public decimal? EquipmentWorkingHours { get; set; }

        public bool? PlannedRevision { get; set; }

        public string FaultDescription { get; set; }

        public Guid ComponentArrivalReason { get; set; }

        public Guid? SubProductId { get; set; }

        public int? GroupId { get; set; }

        public DateTime? ComponentSendDate { get; set; }

        public DateTime? ComponentReceiveDate { get; set; }

        public int? ArrivalType { get; set; }

        public string CreateUser { get; set; }

        public string CreateUserDisplayName { get; set; }

        public string UpdateUser { get; set; }

        public string UpdateUserDisplayName { get; set; }

        public int DocumentId { get; set; }
        public bool? necessaryWO { get; set; }
        public string SendTo { get; set; }
        public int? SendToGroup { get; set; }

        public List<CrcComponentsCreateOrEditModel> Components { get; set; } = new List<CrcComponentsCreateOrEditModel>();
    }
}
