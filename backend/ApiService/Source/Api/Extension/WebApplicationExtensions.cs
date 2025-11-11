using System.Diagnostics.CodeAnalysis;
using System.Globalization;
using Epam.ItMarathon.ApiService.Api.Endpoints;
using Epam.ItMarathon.ApiService.Infrastructure.Database;
using Serilog;

namespace Epam.ItMarathon.ApiService.Api.Extension
{
    /// <summary>
    /// WebApplication builder static setup-class.
    /// </summary>
    [ExcludeFromCodeCoverage]
    public static class WebApplicationExtensions
    {
        /// <summary>
        /// Extension method for more fluent setup. This is where all required configuration happens.
        /// </summary>
        /// <param name="application">The WebApplication instance.</param>
        /// <returns>Reference to input <paramref name="application"/>.</returns>
        public static WebApplication ConfigureApplication(this WebApplication application)
        {
            #region Logging

            _ = application.UseSerilogRequestLogging();

            #endregion Logging

            #region Security

            _ = application.UseHsts();
            _ = application.UseHttpsRedirection();
            _ = application.UseCors();

            #endregion Security

            #region Swagger

            var textInfo = CultureInfo.CurrentCulture.TextInfo;

            _ = application.UseSwagger();
            _ = application.UseSwaggerUI(c =>
                c.SwaggerEndpoint(
                    "/swagger/v1/swagger.json",
                    $"Secret Nick API - {textInfo.ToTitleCase(application.Environment.EnvironmentName)} - V1"));

            #endregion Swagger

            #region MinimalApi

            _ = application.MapSystemEndpoints();
            _ = application.MapRoomEndpoints();
            _ = application.MapUserEndpoints();
            _ = application.MapAiEndpoints();

            #endregion MinimalApi

            #region Database

            application.Services.MigrateDatabase();

            #endregion Database

            return application;
        }
    }
}