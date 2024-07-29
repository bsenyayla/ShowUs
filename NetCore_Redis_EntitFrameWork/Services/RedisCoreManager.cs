using CRCAPI.Services.Attributes;
using CRCAPI.Services.Interfaces;
using CRCAPI.Services.Settings;
using Microsoft.Extensions.Options;
using Newtonsoft.Json;
using StackExchange.Redis.Extensions.Core.Abstractions;
using StandartLibrary.Models.Constants;
using System;

namespace CRCAPI.Services.Services
{
    [SingletonDependency(ServiceType = typeof(IRedisCoreManager))]
    public class RedisCoreManager : IRedisCoreManager
    {
        private readonly IRedisCacheClient redisClient;
        private readonly IRedisDatabase redis;
        private readonly string configParamterKey;
        private readonly AppSettings appSettings;
        private readonly ILogCoreMan logCoreMan;

        public RedisCoreManager(IRedisCacheClient redisClient, IOptions<AppSettings> options, ILogCoreMan logCoreMan)
        {
            this.logCoreMan = logCoreMan;
            this.redisClient = redisClient;
            this.redis = redisClient.Db0;
            this.appSettings = options.Value;
            ///  location key appsettingsten alacak sekilde düzenlendi...
            this.configParamterKey = RedisConstants.CDOMS_KEY + this.appSettings.CdomsLocationKey + RedisConstants.CONFIG_PARAMETERS_KEY;
        }

        #region Object 
        // Get object
        // Deserialize 
        public T GetObject<T>(string key)
        {

            T redisResult = default(T);
            try
            {
                string redisObject = redis.Get<string>(this.configParamterKey + key);
                redisResult = JsonConvert.DeserializeObject<T>(redisObject);

            }
            catch (Exception ex)
            {
                logCoreMan.Error("Redis GetObject Exception", ex);
            }

            return redisResult;
        }


        // Set object
        // Serialize object
        public bool SetObject<T>(string key, T value, int expirySeconds = 0)
        {
            try
            {
                if (expirySeconds > 0)
                {
                    return redis.Add(this.configParamterKey + key, value, DateTimeOffset.Now.AddMinutes(expirySeconds));
                }
                else
                {
                    return redis.Add(this.configParamterKey + key, value);
                }
            }
            catch (Exception ex)
            {
                logCoreMan.Error("Redis SetObject Exception", ex);
                return false;
            }
        }

        #endregion

        #region List Commands 


        public long ListAddToLeft<T>(string key, T value) where T : class
        {
            var redisValue = default(long);
            try
            {
                redisValue = redis.ListAddToLeftAsync(this.configParamterKey + key, JsonConvert.SerializeObject(value)).Result;
            }
            catch (Exception ex)
            {
                logCoreMan.Error("Redis ListAddToLeft Exception", ex);
            }

            return redisValue;
        }

        public T ListGetFromRight<T>(string key) where T : class
        {
            var redisValue = default(T);
            try
            {
                redisValue = redis.ListGetFromRight<T>(this.configParamterKey + key);

            }
            catch (Exception ex)
            {
                logCoreMan.Error("Redis ListGetFromRight Exception", ex);

            }

            return redisValue;
        }

        #endregion
    }
}
