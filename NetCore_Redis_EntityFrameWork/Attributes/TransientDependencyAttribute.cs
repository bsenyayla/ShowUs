using Microsoft.Extensions.DependencyInjection;
using System;

namespace CRCAPI.Services.Attributes
{
    /// <summary>
    /// Dependency injection type for once time created service attribute.
    /// </summary>
    public class TransientDependencyAttribute : DependencyAttribute
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="TransientDependencyAttribute"/> class.
        /// Constructor.
        /// </summary>
        public TransientDependencyAttribute(params Type[] genericTypes)
            : base(ServiceLifetime.Transient, genericTypes)
        {
        }
    }
}
