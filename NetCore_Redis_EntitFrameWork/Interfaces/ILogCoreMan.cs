using System;
using System.Collections.Generic;
using System.Runtime.CompilerServices;
using System.Text;

namespace CRCAPI.Services.Interfaces
{
    public interface ILogCoreMan
    {
        void Info(string logMessage, Exception exception = null, [CallerFilePath] string sourceFile = null);

        void Debug(string logMessage, Exception exception = null, [CallerFilePath] string sourceFile = null);

        public void Warn(string logMessage, Exception exception = null, [CallerFilePath] string sourceFile = null);

        public void Error(string logMessage, Exception exception = null, [CallerFilePath] string sourceFile = null);

        public void Fatal(string logMessage, Exception exception = null, [CallerFilePath] string sourceFile = null);
    }
}
