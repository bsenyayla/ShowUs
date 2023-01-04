using CRCAPI.Services.Attributes;
using CRCAPI.Services.Interfaces;
using log4net;
using log4net.Appender;
using log4net.Config;
using log4net.Core;
using log4net.Repository.Hierarchy;
using Log4Net.Async;
using System;
using System.IO;
using System.Linq;
using System.Reflection;
using System.Runtime.CompilerServices;
using Seq.Client.Log4Net;
using log4net.Layout;

namespace CRCAPI.Services.Services
{
    [SingletonDependency(ServiceType = typeof(ILogCoreMan))]
    public class LogCoreMan : ILogCoreMan
    {
        private AsyncForwardingAppender AsyncAppender;
        private static log4net.Repository.Hierarchy.Logger root = ((Hierarchy)log4net.LogManager.GetRepository()).Root;
        public static string Application { get; set; } = "default";

        public LogCoreMan()
        {
            string path = AssemblyDirectory + "\\log4net.config";

            var logRepository = LogManager.GetRepository(Assembly.GetEntryAssembly());

            XmlConfigurator.Configure(logRepository, new FileInfo(path));

            AsyncAppender = logRepository.GetAppenders()
                                            .FirstOrDefault(x => x is AsyncForwardingAppender) as AsyncForwardingAppender;

            root.AddAppender(CreateSeqAppender("SeqAsyncForwarder"));
            log4net.GlobalContext.Properties["Module"] = "CRCAPI.Services";
        }

        public static IAppender CreateSeqAppender(string name)
        {
            string srvUrl = "http://localhost:7999";
            //srvUrl = ConfigurationManager.AppSettings["SeqUrl"];
            var seqAppender = new SeqAppender();
            seqAppender.ServerUrl = srvUrl;
            PatternLayout patternLayout = new PatternLayout();

            var LOG_PATTERN = "%d [%t] %-5p %m%n";
            patternLayout.ConversionPattern = LOG_PATTERN;
            patternLayout.ActivateOptions();
            seqAppender.Name = name;
            seqAppender.BufferSize = 1;
            seqAppender.Layout = patternLayout;
            seqAppender.ActivateOptions();

            return seqAppender;
        }

        public static string AssemblyDirectory
        {
            get
            {
                string codeBase = Assembly.GetExecutingAssembly().CodeBase;
                UriBuilder uri = new UriBuilder(codeBase);
                string path = Uri.UnescapeDataString(uri.Path);
                return Path.GetDirectoryName(path);
            }
        }

        public void Info(string logMessage, Exception exception = null, [CallerFilePath] string sourceFile = null)
        {
            var helper = new LoggingEventHelper(sourceFile, FixFlags.All);
            var loggingEvent = helper.CreateLoggingEvent(INFO, logMessage, exception);
            AsyncAppender.DoAppend(loggingEvent);
            root.Log(Level.Info, logMessage, exception);
        }

        public void Debug(string logMessage, Exception exception = null, [CallerFilePath] string sourceFile = null)
        {
            var helper = new LoggingEventHelper(sourceFile, FixFlags.All);
            var loggingEvent = helper.CreateLoggingEvent(DEBUG, logMessage, exception);
            AsyncAppender.DoAppend(loggingEvent);
            root.Log(Level.Debug, logMessage, exception);
        }

        public void Warn(string logMessage, Exception exception = null, [CallerFilePath] string sourceFile = null)
        {
            var helper = new LoggingEventHelper(sourceFile, FixFlags.All);
            var loggingEvent = helper.CreateLoggingEvent(WARN, logMessage, exception);
            AsyncAppender.DoAppend(loggingEvent);
            root.Log(Level.Warn, logMessage, exception);
        }

        public void Error(string logMessage, Exception exception = null, [CallerFilePath] string sourceFile = null)
        {
            var helper = new LoggingEventHelper(sourceFile, FixFlags.All);
            var loggingEvent = helper.CreateLoggingEvent(ERROR, logMessage, exception);
            AsyncAppender.DoAppend(loggingEvent);
            root.Log(Level.Error, logMessage, exception);
        }

        public void Fatal(string logMessage, Exception exception = null, [CallerFilePath] string sourceFile = null)
        {
            var helper = new LoggingEventHelper(sourceFile, FixFlags.All);
            var loggingEvent = helper.CreateLoggingEvent(FATAL, logMessage, exception);
            AsyncAppender.DoAppend(loggingEvent);
            root.Log(Level.Fatal, logMessage, exception);
        }
        public static void Shutdown()
        {
            LogManager.Shutdown();
        }

        #region constants
        public static readonly string ROOT_LOGGER = "AsyncAppenderForwarder";

        public static readonly Level DEBUG = Level.Debug;
        public static readonly Level INFO = Level.Info;
        public static readonly Level WARN = Level.Warn;
        public static readonly Level ERROR = Level.Error;
        public static readonly Level FATAL = Level.Fatal;
        #endregion
    }
}
