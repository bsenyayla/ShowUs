using System;

namespace CRCAPI.Services.Models.CrcTransfer
{
    public class DeleteInternalRequestInput
    {
        public Guid Id { get; set; }
        public string LoggedUser { get; set; }
    }
}