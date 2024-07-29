using System;
using System.Collections.Generic;
using System.Text;

namespace CRCAPI.Services.Interfaces
{
    public interface IRedisCoreManager
    {
        bool SetObject<T>(string key, T value, int expirySeconds = 0);

        T GetObject<T>(string key);

        long ListAddToLeft<T>(string key, T value) where T : class;

        T ListGetFromRight<T>(string key) where T : class;
    }
}
