using System;
using System.Collections.Generic;
using Microsoft.AspNetCore.Http;

namespace CRCAPI.Services.Models.CrcTransfer
{
    public class CrcComponentsCreateOrEditModel
    {
        public string PartsName { get; set; }
        public int? Quantity { get; set; }
        public string RequestedWork { get; set; }
        public int? GroupId { get; set; }
        public string Description { get; set; }
        public List<IFormFile> Attachments { get; set; } = new List<IFormFile>();
        public string ComponentCode { get; set; }
        public string JobCode { get; set; }
        public int ItemNumber { get; set; }
        public Guid Id { get; set; }
        public int ComponentId { get; set; }
    }
}