namespace Epam.ItMarathon.ApiService.Api.Dto.Responses.AiResponses;

/// <summary>
/// Successful result returned after generating gift ideas.
/// </summary>
public class GenerateIdeasForGiftResponse
{
    /// <summary>
    /// Suggested gift ideas.
    /// </summary>
    public required string IdeasForGift { get; set; }
}