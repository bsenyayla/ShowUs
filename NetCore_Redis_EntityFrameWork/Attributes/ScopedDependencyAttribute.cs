using Microsoft.Extensions.DependencyInjection;

namespace CRCAPI.Services.Attributes
{
    /// <summary>
	/// Dependency injection type for each request time created service attribute.
	/// </summary>
	public class ScopedDependencyAttribute : DependencyAttribute
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="ScopedDependencyAttribute"/> class.
        /// Constructor.
        /// </summary>
        public ScopedDependencyAttribute()
            : base(ServiceLifetime.Scoped)
        {
        }
    }
}
