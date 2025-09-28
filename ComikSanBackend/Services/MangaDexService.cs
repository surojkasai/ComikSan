using ComikSanBackend.Models;
using System.Text.Json;

namespace ComikSanBackend.Services
{
    public class MangaDexService
    {
        private readonly HttpClient _httpClient;

        public MangaDexService(HttpClient httpClient)
        {
            _httpClient = httpClient;
            // Set a User-Agent header (good practice for APIs)
            _httpClient.DefaultRequestHeaders.Add("User-Agent", "ComikSan/1.0");
        }

     public async Task<List<Comic>> SearchMangaAsync(string title)
{
    try
    {
        var response = await _httpClient.GetAsync(
            $"https://api.mangadex.org/manga?title={Uri.EscapeDataString(title)}&limit=10");
        
        if (response.IsSuccessStatusCode)
        {
            var json = await response.Content.ReadAsStringAsync();
            return ParseMangaDexResponse(json);
        }
        
        return new List<Comic>();
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Error searching MangaDex: {ex.Message}");
        return new List<Comic>();
    }
}

public async Task<Comic?> GetMangaByIdAsync(string mangaDexId)
{
    try
    {
        var response = await _httpClient.GetAsync(
            $"https://api.mangadex.org/manga/{mangaDexId}");
        
        if (response.IsSuccessStatusCode)
        {
            var json = await response.Content.ReadAsStringAsync();
            using var document = JsonDocument.Parse(json);
            var dataElement = document.RootElement.GetProperty("data");
            return ParseMangaElement(dataElement);
        }
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Error getting manga by ID: {ex.Message}");
    }
    return null;
}

        private List<Comic> ParseMangaDexResponse(string json)
        {
            var comics = new List<Comic>();

            try
            {
                using var document = JsonDocument.Parse(json);
                var root = document.RootElement;

                if (root.TryGetProperty("data", out var dataElement) &&
                    dataElement.ValueKind == JsonValueKind.Array)
                {
                    foreach (var mangaElement in dataElement.EnumerateArray())
                    {
                        var comic = ParseMangaElement(mangaElement);
                        if (comic != null)
                            comics.Add(comic);
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"JSON parsing error: {ex.Message}");
            }

            return comics;
        }

private Comic? ParseMangaElement(JsonElement mangaElement)
{
    try
    {
        // Extract basic info
        var mangaId = mangaElement.GetProperty("id").GetString();
        var attributes = mangaElement.GetProperty("attributes");
        
        // Get title (try English first, then Japanese, then any available)
        var title = GetTitle(attributes.GetProperty("title"));
        
        // Get description
        var description = GetDescription(attributes.GetProperty("description"));
        
        // Get genres from tags
        var genres = GetGenres(attributes.GetProperty("tags"));
        
        // Get author from relationships (we'll simplify this for now)
        var author = GetAuthor(mangaElement.GetProperty("relationships"));
        
        return new Comic
        {
            MangaDexId = mangaId,
            Title = title,
            Author = author,
            Genre = genres,
            Description = description,
            CoverImageUrl = $"https://uploads.mangadex.org/covers/{mangaId}/cover.jpg",
            FollowerCount = new Random().Next(1000, 100000),
            LastSynced = DateTime.Now
        };
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Error parsing manga element: {ex.Message}");
        return null;
    }
}

private string GetTitle(JsonElement titleObj)
{
    // Try English title first
    if (titleObj.TryGetProperty("en", out var enTitle) && !string.IsNullOrEmpty(enTitle.GetString()))
        return enTitle.GetString()!;
    
    // Try Japanese
    if (titleObj.TryGetProperty("ja", out var jaTitle) && !string.IsNullOrEmpty(jaTitle.GetString()))
        return jaTitle.GetString()!;
    
    // Try any available title
    foreach (var property in titleObj.EnumerateObject())
    {
        if (!string.IsNullOrEmpty(property.Value.GetString()))
            return property.Value.GetString()!;
    }
    
    return "Unknown Title";
}

private string GetDescription(JsonElement descObj)
{
    if (descObj.TryGetProperty("en", out var enDesc) && !string.IsNullOrEmpty(enDesc.GetString()))
        return enDesc.GetString()!;
    
    // Take first available description
    foreach (var property in descObj.EnumerateObject())
    {
        var desc = property.Value.GetString();
        if (!string.IsNullOrEmpty(desc) && desc.Length > 10) // Ensure it's meaningful
            return desc.Length > 200 ? desc.Substring(0, 200) + "..." : desc;
    }
    
    return "No description available";
}

private string GetGenres(JsonElement tagsArray)
{
    var genres = new List<string>();
    
    try
    {
        foreach (var tagElement in tagsArray.EnumerateArray())
        {
            var tagAttributes = tagElement.GetProperty("attributes");
            var tagName = tagAttributes.GetProperty("name").GetProperty("en").GetString();
            
            if (!string.IsNullOrEmpty(tagName) && genres.Count < 3) // Limit to 3 genres
                genres.Add(tagName);
        }
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Error parsing genres: {ex.Message}");
    }
    
    return genres.Any() ? string.Join(", ", genres) : "Manga";
}

private string GetAuthor(JsonElement relationshipsArray)
{
    try
    {
        foreach (var relationship in relationshipsArray.EnumerateArray())
        {
            if (relationship.GetProperty("type").GetString() == "author")
            {
                // In a real app, we'd look up the author name, but for now:
                return "Eiichiro Oda"; // Placeholder - we'll fix this later
            }
        }
    }
    catch (Exception ex)
    {
        Console.WriteLine($"Error getting author: {ex.Message}");
    }
    
    return "Unknown Author";
}
        
    }
}