using CRCAPI.Services.Attributes;
using CRCAPI.Services.Interfaces;
using CRCAPI.Services.Settings;
using Microsoft.Extensions.Caching.Memory;
using Microsoft.Extensions.Options;
using StackExchange.Redis.Extensions.Core.Abstractions;
using StandartLibrary.Models.Constants;
using StandartLibrary.Models.EntityModels.AppSettingService;
using System;

namespace CRCAPI.Services
{
    public interface IAppSettingService
    {
        AppSettingModel AppSetting();

        //bool SetObject<T>(string key, T value, int expirySeconds = 0);
        //T GetObject<T>(string key);
    }

    [SingletonDependency(ServiceType = typeof(IAppSettingService))]
    public class AppSettingService : IAppSettingService
    {
        private readonly IRedisCacheClient redisClient;
        private readonly IRedisCoreManager redisCoreManager;
        private readonly string configParamterKey;
        private readonly AppSettings appSettings;
        private readonly ILogCoreMan logCoreMan;
        private readonly IMemoryCache memoryCache;

        public AppSettingService(IRedisCoreManager redisCoreManager, IOptions<AppSettings> options, ILogCoreMan logCoreMan, IMemoryCache memoryCache)
        {
            this.logCoreMan = logCoreMan;
            this.redisCoreManager = redisCoreManager;
            this.appSettings = options.Value;
            this.memoryCache = memoryCache;
            //location key appsettingsten alacak sekilde düzenlendi...
            this.configParamterKey = RedisConstants.CDOMS_KEY + this.appSettings.CdomsLocationKey + RedisConstants.CONFIG_PARAMETERS_KEY;
        }


        public AppSettingModel AppSetting()
        {
            //return null;

            var key = RedisConstants.APPSETTING_KEY;

            var response = memoryCache.Get(key) as AppSettingModel;

            if (response != null)
            {
                return response;
            }

            try
            {
                //response = GlobalConfigurator.GetObject<AppSettingModel>(key);
                response = redisCoreManager.GetObject<AppSettingModel>(key);
            }
            catch { }

            if (response != null)
            {
                memoryCache.Set(key, response, DateTimeOffset.Now.AddSeconds(10));
            }

            return response;
        }
    }
}