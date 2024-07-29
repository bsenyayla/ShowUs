using Microsoft.EntityFrameworkCore;
using StandartLibrary.Models.DataModels.ShortPlan;
using System;
using System.Collections.Generic;
using System.Text;

namespace CRCAPI.Services
{
    public class ShortPlanContext : DbContext
    {
        public ShortPlanContext(DbContextOptions<ShortPlanContext> options)
            : base(options)
        { }

        public DbSet<PlanWorkStatusList> PlanWorkStatusList { get; set; }
    }
}
