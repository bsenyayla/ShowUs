using Microsoft.Extensions.DependencyInjection;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Threading.Tasks;

namespace CRCAPI.Services.Attributes
{
    /// <summary>
	/// Dependency injection type for life cycle of service.
	/// </summary>
	[AttributeUsage(AttributeTargets.Class, AllowMultiple = true)]
    public class DependencyAttribute : Attribute
    {
        /// <summary>
        /// Servce life time.
        /// </summary>
        public ServiceLifetime DependencyType { get; set; }

        /// <summary>
        /// Service type.
        /// </summary>
        public Type ServiceType { get; set; }

        /// <summary>
        /// Service implementation generic types.
        /// </summary>
        public Type[] GenericTypes { get; set; }

        /// <summary>
        /// Initializes a new instance of the <see cref="DependencyAttribute"/> class.
        /// Constroctor with dependency type.
        /// </summary>
        /// <param name="dependencyType">Service life cycle. Transient, single or scoped.</param>
        protected DependencyAttribute(ServiceLifetime dependencyType, params Type[] genericTypes)
        {
            DependencyType = dependencyType;
            GenericTypes = genericTypes;
        }

        /// <summary>
        /// Builder for service descriptor.
        /// </summary>
        /// <param name="type">Service type.</param>
        /// <returns>Service descriptor.</returns>
        public ServiceDescriptor BuildServiceDescriptor(TypeInfo type)
        {
            var serviceType = ServiceType ?? type.AsType();
            return new ServiceDescriptor(serviceType, type.AsType(), DependencyType);
        }
    }
}
