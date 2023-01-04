using CRCAPI.Services.Extensions;
using CRCAPI.Services.Services;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using StandartLibrary.Models.DataModels;
using System;
using System.Collections.Concurrent;
using System.Threading;
using System.Threading.Tasks;


namespace CRCAPI.Services.UserActivityManager
{
    public class UserActivityManager
    {
        private IConfiguration Configuration { get; set; }
        private DbContextOptionsBuilder<CrcmsDbContext> ContextOptions { get; set; }
        private CrcmsDbContext Context { get; set; }
        private ConcurrentQueue<UserActivity> Queue { get; set; } = new ConcurrentQueue<UserActivity>();
        private LogCoreMan LogMan { get; set; }

        public UserActivityManager(IConfiguration configuration)
        {
            try
            {
                Configuration = configuration;

                ContextOptions = new DbContextOptionsBuilder<CrcmsDbContext>();
                ContextOptions.UseSqlServer(Configuration.GetConnectionString("CrcmsConnectionString"));

                Context = new CrcmsDbContext(ContextOptions.Options);
                LogMan = new LogCoreMan();

                var background = Task.Factory.StartNew(ConsumeQueue);
            }
            catch (Exception ex)
            {
                LogMan.Error("Exception: " + ex.GetInnerExceptionMessage());
            }
        }

        private void ConsumeQueue()
        {
            try
            {
                while (true)
                {
                    UserActivity item;

                    try
                    {
                        if (Queue.TryDequeue(out item))
                        {
                            Context.UserActivities.Add(item);
                            Context.SaveChanges();
                        }
                    }
                    catch (Exception ex)
                    {
                        LogMan.Error("UserActivity Dequeue Exception: " + ex.GetInnerExceptionMessage());
                    }

                    Thread.Sleep(10);
                }

            }
            catch (Exception ex)
            {
                LogMan.Error("UserActivity Dequeue Exception: " + ex.GetInnerExceptionMessage());
            }
        }

        public void InsertUserActivity(UserActivity userActivity)
        {
            try
            {
                Queue.Enqueue(userActivity);
            }
            catch (Exception ex)
            {
                LogMan.Error("UserActivity Dequeue Exception: " + ex.GetInnerExceptionMessage());
            }
        }
    }
}
