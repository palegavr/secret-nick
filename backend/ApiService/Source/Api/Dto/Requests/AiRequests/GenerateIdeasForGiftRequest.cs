namespace Epam.ItMarathon.ApiService.Api.Dto.Requests.AiRequests;

/// <summary>
/// Request to generate gift ideas based on a person's interests.
/// </summary>
public class GenerateIdeasForGiftRequest
{
    /// <summary>
    /// Interests of the gift recipient.
    /// </summary>
    public required string Interests { get; set; }
}