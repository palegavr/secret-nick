using CSharpFunctionalExtensions;
using Epam.ItMarathon.ApiService.Application.UseCases.Ai.Commands;
using FluentValidation.Results;
using Google.GenAI;
using MediatR;

namespace Epam.ItMarathon.ApiService.Application.UseCases.Ai.Handlers;

/// <summary>
/// Handler for <see cref="GenerateIdeasForGiftRequest"/>.
/// </summary>
public class GenerateIdeasForGiftHandler :
    IRequestHandler<GenerateIdeasForGiftRequest, IResult<string, ValidationResult>>
{
    private const string AiModel = "gemini-2.5-flash";

    private const string PromptTemplate = @"
        Ти креативний помічник з вибору подарунків.
        
        Спочатку визнач мову, якою написані наступні інтереси: ""{0}"" (Determine the language of the interests first).
        
        Потім згенеруй 5 унікальних ідей подарунків для людини, чиї інтереси включають: **{0}**.
        
        -- СУВОРІ ПРАВИЛА ВІДПОВІДІ --
        
        1.  **Мова**: Відповідь має бути **повністю тією самою мовою**, яку ти визначив (The entire response must be in that determined language). Якщо мову визначити не вдалося (або інтереси змішані), відповідай **українською**.
        2.  **Зміст**: Для кожного подарунка вкажи тільки назву, максимально стисло, без зайвих прикметників (наприклад, замість 'професійний набір', пиши 'набір').
        3.  **Формат**: Відповідь має бути одним рядком: усі 5 згенерованих ідей, розділені комою та пробілом, в кінці крапка.
        4.  **Регістр**: Перша ідея починається з великої літери, решта чотири — з маленької.
        5.  **Без додаткового тексту**: Не додавай жодного вступного чи заключного тексту, включно зі згадками про мову.
    ";

    ///<inheritdoc/>
    public async Task<IResult<string, ValidationResult>> Handle(
        GenerateIdeasForGiftRequest request,
        CancellationToken cancellationToken)
    {
        var client = new Client();

        string prompt = CreatePrompt(request.Interests);

        var generateContentResponse =
            await client.Models.GenerateContentAsync(model: AiModel, contents: prompt);

        string result = generateContentResponse.Candidates[0].Content.Parts[0].Text;

        return Result.Success<string, ValidationResult>(result);
    }

    private static string CreatePrompt(string interests)
    {
        return String.Format(PromptTemplate, interests);
    }
}