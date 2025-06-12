using CRCAPI.Services;
using CRCAPI.Services.Binders;
using CRCAPI.Services.Extensions;
using CRCAPI.Services.Filters;
using CRCAPI.Services.Interfaces;
using CRCAPI.Services.Middlewares;
using CRCAPI.Services.Providers;
using CRCAPI.Services.Settings;
using Microsoft.AspNetCore.Authentication;
using Microsoft.AspNetCore.Builder;
using Microsoft.AspNetCore.Hosting;
using Microsoft.AspNetCore.Http;
using Microsoft.EntityFrameworkCore;
using Microsoft.Extensions.Configuration;
using Microsoft.Extensions.DependencyInjection;
using Microsoft.Extensions.Hosting;
using Microsoft.Extensions.Logging;
using Microsoft.OpenApi.Models;
using StackExchange.Redis.Extensions.Core.Abstractions;
using StackExchange.Redis.Extensions.Core.Configuration;
using StackExchange.Redis.Extensions.Core.Implementations;
using System;
using System.Text.Json;

namespace Crcapi
{
    public class Startup
    {
        public Startup(IConfiguration configuration)
        {
            Configuration = configuration;
        }

        public IConfiguration Configuration { get; }

        // This method gets called by the runtime. Use this method to add services to the container.
        public void ConfigureServices(IServiceCollection services)
        {

            ///appsettings.json fills the AppSettings class....
            var appsettings = (AppSettings)Activator.CreateInstance(typeof(AppSettings));
            Configuration.GetSection("AppSettings").Bind(appsettings);

            /// binds the appSettings.json to AppSettings class...
            services.Configure<AppSettings>(Configuration.GetSection("AppSettings"));

            //configures iis options
            services.Configure<IISServerOptions>(options =>
            {
                options.AllowSynchronousIO = true;
            });

            services.AddMemoryCache();

            /// configures redis contex
            var redisConfiguration = Configuration.GetSection("Redis").Get<RedisConfiguration>();
            services.AddSingleton(redisConfiguration);
            services.AddSingleton<IRedisCacheClient, RedisCacheClient>();
            services.AddSingleton<IRedisCacheConnectionPoolManager, RedisCacheConnectionPoolManager>();
            services.AddSingleton<IRedisDefaultCacheClient, RedisDefaultCacheClient>();
            services.AddSingleton<StackExchange.Redis.Extensions.Core.ISerializer, StackExchange.Redis.Extensions.MsgPack.MsgPackObjectSerializer>();

            ///configures the db context
            services.AddDbContext<CrcmsDbContext>(options => options.UseSqlServer(Configuration.GetConnectionString("CrcmsConnectionString")).UseLazyLoadingProxies());
            services.AddDbContext<ShortPlanContext>(options => options.UseSqlServer(Configuration.GetConnectionString("ShortPlanConnectionString")).UseLazyLoadingProxies());
            //services.AddDbContext<ClcrcDbContext>(options => options.UseSqlServer(Configuration.GetConnectionString("ClcrcConnectionString")));

            services.AddSingleton<IHttpContextAccessor, HttpContextAccessor>();

            services.AddScoped<IUnitOfWork, UnitOfWork<CrcmsDbContext>>();
            services.AddScoped<IUnitOfWork<CrcmsDbContext>, UnitOfWork<CrcmsDbContext>>();


            services.AddScoped<IUnitOfWork, UnitOfWork<ShortPlanContext>>();
            services.AddScoped<IUnitOfWork<ShortPlanContext>, UnitOfWork<ShortPlanContext>>();

            //  services.AddScoped<IUnitOfWork, UnitOfWork<ClcrcDbContext>>();
            //  services.AddScoped<IUnitOfWork<ClcrcDbContext>, UnitOfWork<ClcrcDbContext>>();

            /// injects the services dynamically...
            services.InjectAssembly(appsettings.ServiceAssemblyName);


            // configure basic authentication 
            services.AddAuthentication("BasicAuthentication")
                .AddScheme<AuthenticationSchemeOptions, BasicAuthenticationProvider>("BasicAuthentication", null);

            /// binds the model to the payload...
            services.AddMvc(opt => opt.ModelBinderProviders.Insert(0, new PayloadBinderProvider())).AddJsonOptions(options =>
                options.JsonSerializerOptions.WriteIndented = true
            );

            //configure swagger ...
            services.AddSwaggerGen(c =>
            {
                c.SwaggerDoc("v1", new OpenApiInfo { Title = "CrcApi", Version = "v1" });
            });

            services.AddControllers()
                .AddNewtonsoftJson()
                .AddJsonOptions(options =>
            {
                // Use the default property (CamelCase) casing.
                options.JsonSerializerOptions.PropertyNamingPolicy = JsonNamingPolicy.CamelCase;
            });

            services.AddScoped<UserActivityFilter>();
            services.AddHealthChecks();

        }

        // This method gets called by the runtime. Use this method to configure the HTTP request pipeline.
        public void Configure(IApplicationBuilder app, IWebHostEnvironment env, ILoggerFactory loggerFactory)
        {

            if (env.IsDevelopment())
            {
                app.UseDeveloperExceptionPage();
            }

            // Enable middleware to serve generated Swagger as a JSON endpoint.
            app.UseSwagger();

            // Enable middleware to serve swagger-ui (HTML, JS, CSS, etc.),
            // specifying the Swagger JSON endpoint.
            app.UseSwaggerUI(c =>
            {
                c.SwaggerEndpoint("/swagger/v1/swagger.json", "CrcApi");
            });

            app.UseHealthChecks("/health");

            app.UseRequestResponseLogging();

            app.UseCors(builder => builder.AllowAnyHeader().AllowAnyOrigin().WithMethods("GET", "POST"));

            app.UseHttpsRedirection();

            app.UseRouting();

            app.UseAuthentication();

            app.UseAuthorization();

            app.UseEndpoints(endpoints =>
            {
                endpoints.MapControllers();
            });
        }
    }
}
