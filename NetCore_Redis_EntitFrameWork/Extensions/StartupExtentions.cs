using CRCAPI.Services.Attributes;
using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Reflection;
using System.Text;

namespace CRCAPI.Services.Extensions
{
    public static class StartupExtentions
    {
        /// <summary>
        /// Inject instance of services.
        /// </summary>
        /// <param name="services">IServiceCollection</param>
        /// <param name="assemblyName">Assembly Name</param>
        /// <returns>IServiceCollection</returns>
        public static IServiceCollection InjectAssembly(this IServiceCollection services, string assemblyName)
        {
            var assembly = Assembly.Load(new AssemblyName(assemblyName));
            foreach (var type in assembly.ExportedTypes)
            {
                var dependencyAttributes = type.GetCustomAttributes<DependencyAttribute>();
                foreach (var dependencyAttribute in dependencyAttributes)
                {
                    var serviceDescriptor = dependencyAttribute.BuildServiceDescriptor(type.GetTypeInfo());
                    services.Add(serviceDescriptor);
                }
            }
            return services;
        }
    }
}
