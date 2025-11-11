using CSharpFunctionalExtensions;
using FluentValidation.Results;
using MediatR;

namespace Epam.ItMarathon.ApiService.Application.UseCases.Ai.Commands;

/// <summary>
/// Command to generate gift ideas based on a person's interests.
/// </summary>
/// <param name="Interests">Interests of the gift recipient.</param>
public record GenerateIdeasForGiftRequest(string Interests)
    : IRequest<IResult<string, ValidationResult>>;