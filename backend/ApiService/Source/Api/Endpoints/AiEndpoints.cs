using Epam.ItMarathon.ApiService.Api.Dto.Requests.AiRequests;
using Epam.ItMarathon.ApiService.Api.Dto.Responses.AiResponses;
using Epam.ItMarathon.ApiService.Api.Endpoints.Extension;
using Epam.ItMarathon.ApiService.Api.Endpoints.Extension.SwaggerTagExtension;
using Epam.ItMarathon.ApiService.Api.Filters.Validation;
using MediatR;
using Microsoft.AspNetCore.Mvc;

namespace Epam.ItMarathon.ApiService.Api.Endpoints;

/// <summary>
/// Endpoints for the AI.
/// </summary>
public static class AiEndpoints
{
    /// <summary>
    /// Static method to map AI's endpoints to DI container.
    /// </summary>
    /// <param name="application">The WebApplication instance.</param>
    /// <returns>Reference to input <paramref name="application"/>.</returns>
    public static WebApplication MapAiEndpoints(this WebApplication application)
    {
        var root = application.MapGroup("/api/ai")
            .WithTags("AI")
            .WithTagDescription("AI", "AI endpoints")
            .WithOpenApi();

        _ = root.MapPost("generate-ideas-for-gift", GenerateIdeasForGift)
            .AddEndpointFilterFactory(ValidationFactoryFilter.GetValidationFactory)
            .Produces<GenerateIdeasForGiftResponse>(StatusCodes.Status200OK)
            .ProducesProblem(StatusCodes.Status400BadRequest)
            .ProducesProblem(StatusCodes.Status500InternalServerError)
            .WithSummary("Generate ideas for a gift.")
            .WithDescription("Return ideas.");

        return application;
    }

    private static async Task<IResult> GenerateIdeasForGift(
        [FromBody] GenerateIdeasForGiftRequest body,
        CancellationToken cancellationToken,
        IMediator mediator)
    {
        var result =
            await mediator.Send(new Application.UseCases.Ai.Commands.GenerateIdeasForGiftRequest(body.Interests),
                cancellationToken);
        if (result.IsFailure)
        {
            return result.Error.ValidationProblem();
        }

        return Results.Ok(new GenerateIdeasForGiftResponse
        {
            IdeasForGift = result.Value,
        });
    }
}