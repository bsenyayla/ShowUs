using System;
using System.Collections;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Threading;

using Amazon.S3;
using Amazon.S3.Transfer;

namespace Digiturk.Cloud.AwsS3Sync
{
    public class Synchronizer
    {
        private volatile bool m_IsPaused;
        private DateTime m_LastIterationDate;

        private object m_SyncObj;
        private Thread m_Thread;

        private int m_No;
        private SyncMode m_Mode;
        private int m_SyncInterval;
        private CustomS3Client m_CustomS3Client;

        private IAmazonS3 m_AwsS3Client;
        private TransferUtility m_AwsTransferUtility;
        private SynchronizationConfigurationElement m_SyncConfigElement;

        public bool IsAlive {
            get { return m_Thread != null && m_Thread.IsAlive && !m_IsPaused; }
        }
        public bool IsPaused {
            get { return m_IsPaused; }
        }
        private string ThreadName {
            get { return this.GetType().Name + "-" + m_No; }
        }
        private bool IsUpload {
            get { return m_Mode == SyncMode.OnlyUpload || m_Mode == SyncMode.UploadAndDelete; }
        }
        private bool IsDownload {
            get { return m_Mode == SyncMode.OnlyDownload || m_Mode == SyncMode.DownloadAndDelete; }
        }


        private Synchronizer()
        {
            //default-constructor
        }
        public Synchronizer(IAmazonS3 s3Client, TransferUtility transferUtility, SynchronizationConfigurationElement syncConfigElement)
        {
            m_IsPaused = false;
            m_SyncObj = new object();
            m_LastIterationDate = DateTime.MinValue;
            
            m_AwsS3Client = s3Client;
            m_AwsTransferUtility = transferUtility;
            m_SyncConfigElement = syncConfigElement;

            m_No = syncConfigElement.No;
            m_SyncInterval = syncConfigElement.SyncInterval;
            m_Mode = (SyncMode)Enum.Parse(typeof(SyncMode), syncConfigElement.Mode, true);

            m_CustomS3Client = new CustomS3Client(ThreadName);
        }

        public void ResetCoreParticules(IAmazonS3 s3Client, TransferUtility transferUtility, SynchronizationConfigurationElement syncConfigElement)
        {
            lock (m_SyncObj) {
                m_AwsS3Client = s3Client;
                m_AwsTransferUtility = transferUtility;
                m_SyncConfigElement = syncConfigElement;                
            }
        }

        private void SetCoreParticules()
        {
            lock (m_SyncObj) {
                if (m_AwsS3Client == null || m_AwsTransferUtility == null || m_SyncConfigElement == null) return;
                m_No = m_SyncConfigElement.No;
                m_Mode = (SyncMode)Enum.Parse(typeof(SyncMode), m_SyncConfigElement.Mode, true);
                m_SyncInterval = m_SyncConfigElement.SyncInterval;
                m_CustomS3Client.SetCoreParticules(m_AwsS3Client, m_AwsTransferUtility, m_SyncConfigElement);
                m_AwsS3Client = null; 
                m_AwsTransferUtility = null; 
                m_SyncConfigElement = null;
            }
        }

        private void StartSeparateThread()
        {
            if (m_Thread != null) {
                Logger.WriteLine(ThreadName + " is already running..");
                return;
            }
            ThreadStart ts = new ThreadStart(this.Run);
            m_Thread = new Thread(ts);
            m_Thread.Name = ThreadName;
            m_Thread.Start();
            Logger.WriteLine("A new thread started with name : " + ThreadName);
        }

        private void RunIteration()
        {
            try {
                if (!m_CustomS3Client.IsReadyForOperation) return;

                m_CustomS3Client.IterationInitialize();

                m_CustomS3Client.PopulateS3Objects();
                m_CustomS3Client.PopulateLocalObjects();

                if ( IsUpload ) {
                    m_CustomS3Client.CalculateUploadsToS3();
                    if( m_Mode == SyncMode.UploadAndDelete ) m_CustomS3Client.CalculateDeletionsFromS3();
                }
                else if ( IsDownload ) {
                    m_CustomS3Client.CalculateDownloadsToLocal();
                    if( m_Mode == SyncMode.DownloadAndDelete ) m_CustomS3Client.CalculateDeletionsFromLocal();
                }

                m_CustomS3Client.TraceDifferences();

                if ( IsUpload ) {
                    m_CustomS3Client.PerformUploadsToS3();
                    if (m_Mode == SyncMode.UploadAndDelete) m_CustomS3Client.PerformDeletionsFromS3();
                }
                else if ( IsDownload ) {
                    m_CustomS3Client.PerformDownloadsToLocal();
                    if (m_Mode == SyncMode.DownloadAndDelete) m_CustomS3Client.PerformDeletionsFromLocal();
                }
            }
            catch (Exception exc) {
                Logger.WriteError("Error occured in " + ThreadName + " -->RunIteration() method !", exc);
            }
        }

        private void Run()
        {
            Logger.WriteLine("Run() method of " + ThreadName + " begin..");
            while (!m_IsPaused)
            {
                try {
                    if (m_LastIterationDate.AddSeconds(m_SyncInterval) < DateTime.Now) {
                        SetCoreParticules();
                        RunIteration();
                        m_CustomS3Client.ClearAllVariables();
                        m_LastIterationDate = DateTime.Now;
                    }
                    Thread.Sleep(3 * 1000);
                }
                catch (ThreadInterruptedException intExc) { /* silent */ }
                catch (ThreadAbortException abortExc) { /* silent */ }
                catch (Exception exc) {
                    Logger.WriteError("Error occured in Daemon-->Run() method..", exc);
                }
            }
            Logger.WriteLine("Run() method of " + ThreadName + " finished..");
        }

        public void Start()
        {
            StartSeparateThread();
        }

        public void Stop()
        {
            if (m_Thread == null) {
                Logger.WriteLine(ThreadName + " was already stopped.");
                return;
            }
            try {
                m_IsPaused = true;
                m_CustomS3Client.Pause();
                m_Thread.Interrupt();
                m_Thread.Abort();
                Logger.WriteLine("A thread stopped with name " + ThreadName);
            }
            catch (Exception exc) {
                Logger.WriteError("Error occured in Stop() method of " + ThreadName, exc);
            }
            finally {
                m_Thread = null;
                m_AwsS3Client = null;
                m_AwsTransferUtility = null;
                m_SyncConfigElement = null;
            }
        }


    }
}
