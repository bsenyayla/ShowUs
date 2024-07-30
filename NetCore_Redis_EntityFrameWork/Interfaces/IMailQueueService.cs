namespace CRCAPI.Services.Interfaces
{
    public interface IMailQueueService
    {
        public bool SendMail();
        public bool SendMailByMailQueueId(int mailQueueId);
        public string ViewMailByMailQueueId(int mailQueueId);
    }
}
