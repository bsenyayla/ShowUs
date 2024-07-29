using StandartLibrary.Models.Enums;
using System;
using System.Collections.Generic;
using System.Text;

namespace CRCAPI.Services
{
    public class BusinessException : Exception
    {
        public BusinessException(string message, ErrorCode errorCode) : base(message)
        {
            this.ErrorCode = errorCode;
        }

        public BusinessException(string message) : base(message)
        {
            this.ErrorCode = ErrorCode.SystemException;
        }

        public ErrorCode ErrorCode { get; set; }
    }
}
