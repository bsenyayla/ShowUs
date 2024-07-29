using Microsoft.Extensions.DependencyInjection;

namespace CRCAPI.Services.Attributes
{
    /// <summary>
	/// Dependency injection type for single instance created service attribute.
	/// </summary>
	public class SingletonDependencyAttribute : DependencyAttribute
    {
        /// <summary>
        /// Initializes a new instance of the <see cref="SingletonDependencyAttribute"/> class.
        /// Constructor.
        /// </summary>
        public SingletonDependencyAttribute()
            : base(ServiceLifetime.Singleton)
        {
        }
    }
}
