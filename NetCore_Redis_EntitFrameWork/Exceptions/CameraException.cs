using System;
using System.Collections.Generic;
using System.Net.Http;
using System.Text;

namespace CRCAPI.Services.Exceptions
{
    public class CameraException : Exception
    {
        public CameraException(string message, HttpResponseMessage response) : base(message)
        {
            this.Response = response;
        }

        public HttpResponseMessage Response { get; set; }
    }
}
