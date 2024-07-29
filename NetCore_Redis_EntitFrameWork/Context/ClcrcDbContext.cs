using Microsoft.EntityFrameworkCore;
using StandartLibrary.Models.DataModels;


namespace CRCAPI.Services
{
    public class ClcrcDbContext : DbContext
    {
        public ClcrcDbContext(DbContextOptions<ClcrcDbContext> options)
            : base(options)
        { }

        public DbSet<TemplateArea> TemplateAreas { get; set; }
        public DbSet<Template> Templates { get; set; }
        public DbSet<Series> Series { get; set; }
        public DbSet<CheckList> CheckLists { get; set; }
        public DbSet<CheckListRequest> CheckListRequests { get; set; }
    }
}
