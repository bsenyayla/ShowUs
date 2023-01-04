using Microsoft.EntityFrameworkCore;
using StandartLibrary.Models.DataModels;
using StandartLibrary.Models.DataModels.Counter;

namespace CRCAPI.Services
{
    public class CrcmsDbContext : DbContext
    {
        public CrcmsDbContext(DbContextOptions<CrcmsDbContext> options)
            : base(options)
        { }

        public DbSet<Area> Areas { get; set; }
        public DbSet<Upload> Uploads { get; set; }
        public DbSet<UploadType> UploadTypes { get; set; }
        public DbSet<SAPUploadQueue> SAPUploadQueues { get; set; }
        public DbSet<Document> Documents { get; set; }
       
        public DbSet<Timer> Timers { get; set; }
        public DbSet<TimerInactivity> TimerInactivities { get; set; }
        public DbSet<DocumentArea> DocumentAreas { get; set; }
        public DbSet<User> Users { get; set; }
        public DbSet<BusyUser> BusyUsers { get; set; }
        public DbSet<Group> Groups { get; set; }
        public DbSet<Segment> Segments { get; set; }
        public DbSet<DownloadLog> DownloadLogs { get; set; }
        public DbSet<MailQueue> MailQueues { get; set; }
        public DbSet<MailQueueLog> MailQueueLogs { get; set; }
        public DbSet<CounterOrderedParts> CounterOrderedParts { get; set; }
        public DbSet<CounterList> CounterLists { get; set; }
        public DbSet<CounterPartsStatus> CounterPartsStatuses { get; set; }
        public DbSet<CounterPSSRCustomer> CounterPSSRCustomers { get; set; }
        public DbSet<PartsCollectRequest> OrderedPartsRequests { get; set; }
        public DbSet<Model> Models { get; set; }
        public DbSet<Customer> Customers { get; set; }
        public DbSet<DocumentType> DocumentTypes { get; set; }
        public DbSet<DocumentStatus> DocumentStatus { get; set; }
        public DbSet<CounterPssrEmail> CounterPssrEmails { get; set; }
        public DbSet<FailedProcess> FailedProcess { get; set; }
        public DbSet<Camera> Cameras { get; set; }
        public DbSet<DocumentAttributes> DocumentAttributes { get; set; }
        public DbSet<LocalizedProperty> LocalizedProperty { get; set; }
        public DbSet<QuotationStatusHistory> QuotationStatusHistory { get; set; }
        public DbSet<CrcRequest> CrcRequest { get; set; }
        public DbSet<CrcRequestComponent> CrcRequestComponent { get; set; }
        public DbSet<Reception> Reception { get; set; }
        public DbSet<ReceptionItem> ReceptionItem { get; set; }
        public DbSet<Dispatch> Dispatch { get; set; }
        public DbSet<DispatchItem> DispatchItem { get; set; }
        public DbSet<DocumentType> DocumentType { get; set; }
        public DbSet<LocalUser> LocalUser { get; set; }
        public DbSet<UserActivityLog> UserActivityLog { get; set; }
        public DbSet<UserActivity> UserActivities { get; set; }

        public DbSet<SMCSComponentGroup> SMCSComponentGroups { get; set; }
        public DbSet<PlanBoardStatus> PlanBoardStates { get; set; }
        public DbSet<DocumentAttributesDispatched > DocumentAttributesDispatches { get; set; }
        public DbSet<CrcArrivalReason> CrcArrivalReasons { get; set; }
        public DbSet<SMCSComponent> SMCSComponents { get; set; }
        public DbSet<CapacityCalcConst> CapacityCalcConsts { get; set; }

        public DbSet<InternalRequest> InternalRequest { get; set; }
        public DbSet<InternalRequestComponent> InternalRequestComponent { get; set; }
        public DbSet<CrcRequestConstants> CrcRequestConstants { get; set; }
        public DbSet<MailQueue> MailQueue { get; set; }
        public DbSet<UsersAccess> UsersAccesses { get; set; }
        public DbSet<WorkorderSegmentStatus> WorkorderSegmentStatus { get; set; }
        public DbSet<WorkorderSegmentStatusLog> WorkorderSegmentStatusLog { get; set; }
        public DbSet<RelatedDocument> RelatedDocument { get; set; }
        public DbSet<DocumentSegment> DocumentSegment { get; set; }
        public DbSet<DocumentSegmentArea> DocumentSegmentArea { get; set; }
        public DbSet<TimerSegment> TimerSegment { get; set; }
        public DbSet<TimerSegmentInactivity> TimerSegmentInactivity { get; set; }
        public DbSet<SegmentBusyUser > SegmentBusyUsers { get; set; }

        protected override void OnModelCreating(ModelBuilder modelBuilder)
        {
            base.OnModelCreating(modelBuilder);

            modelBuilder.Entity<InternalRequest>().Property(x => x.Id).HasDefaultValueSql("NEWID()");
            modelBuilder.Entity<InternalRequest>().Property(x => x.RequestNumber).HasDefaultValueSql("NEWID()");
            modelBuilder.Entity<InternalRequestComponent>().Property(x => x.Id).HasDefaultValueSql("NEWID()");
            modelBuilder.Entity<InternalRequestComponent>().Property(x => x.ComponentId).HasDefaultValueSql("NEWID()");
        }
    }
}
