using System;
using System.Collections.Generic;
using System.Linq;
using System.Net.Http;
using System.Text.Json;
using System.Threading.Tasks;
using ComikSanBackend.Models;
using Microsoft.Extensions.Logging;

namespace ComikSanBackend.Services
{
    public class MangaDexService
    {
        private readonly HttpClient _httpClient;
        private readonly ILogger<MangaDexService> _logger;

        public MangaDexService(HttpClient httpClient, ILogger<MangaDexService> logger)
        {
            _httpClient = httpClient;
            _logger = logger;
            _httpClient.DefaultRequestHeaders.Add("User-Agent", "ComikSanBackend/1.0");
        }

        public async Task<List<Comic>> SearchMangaAsync(string title)
        {
            try
            {
                // ✅ FIXED: Include both author and artist
                var response = await _httpClient.GetStringAsync(
                    $"https://api.mangadex.org/manga?title={Uri.EscapeDataString(title)}&limit=10&availableTranslatedLanguage[]=en&includes[]=cover_art&includes[]=author&includes[]=artist"
                );

                Console.WriteLine($"✅ Search API called successfully for: {title}");
                var results = ParseMangaDexResponse(response);
                Console.WriteLine($"✅ Parsed {results.Count} results");

                // ✅ FIXED: If covers are still missing, fetch them individually
                var comicsWithCovers = new List<Comic>();
                foreach (var comic in results)
                {
                    if (string.IsNullOrEmpty(comic.CoverImageUrl))
                    {
                        Console.WriteLine($"⚠️ Missing cover for {comic.Title}, fetching individually...");
                        try
                        {
                            var coverFilename = await GetCoverFilenameAsync(comic.MangaDexId);
                            if (!string.IsNullOrEmpty(coverFilename))
                            {
                                comic.CoverImageUrl = $"https://uploads.mangadex.org/covers/{comic.MangaDexId}/{coverFilename}";
                                Console.WriteLine($"✅ Set cover for {comic.Title}: {comic.CoverImageUrl}");
                            }
                        }
                        catch (Exception ex)
                        {
                            Console.WriteLine($"❌ Failed to get cover for {comic.Title}: {ex.Message}");
                        }
                    }
                    comicsWithCovers.Add(comic);
                }

                return comicsWithCovers;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Error searching manga: {ex.Message}");
                return new List<Comic>();
            }
        }

        private List<Comic> ParseMangaDexResponse(string jsonResponse)
        {
            var comics = new List<Comic>();

            try
            {
                var jsonDoc = JsonDocument.Parse(jsonResponse);
                var dataArray = jsonDoc.RootElement.GetProperty("data");
                
                // ✅ FIXED: Parse includes for cover art, authors, and artists
                var coverArtMap = new Dictionary<string, string>();
                var authorMap = new Dictionary<string, string>();
                var artistMap = new Dictionary<string, string>();

                // Check if includes exists
                if (jsonDoc.RootElement.TryGetProperty("includes", out var includes))
                {
                    foreach (var include in includes.EnumerateArray())
                    {
                        var type = include.GetProperty("type").GetString();
                        
                        if (type == "cover_art")
                        {
                            if (include.TryGetProperty("id", out var idElement) &&
                                include.TryGetProperty("attributes", out var attributes))
                            {
                                if (attributes.TryGetProperty("fileName", out var fileNameElement))
                                {
                                    var fileName = fileNameElement.GetString();
                                    var relationshipId = idElement.GetString();
                                    if (!string.IsNullOrEmpty(fileName) && !string.IsNullOrEmpty(relationshipId))
                                    {
                                        coverArtMap[relationshipId] = fileName;
                                        Console.WriteLine($"✅ Added cover art to map: {relationshipId} -> {fileName}");
                                    }
                                }
                            }
                        }
                        else if (type == "author")
                        {
                            if (include.TryGetProperty("id", out var idElement) &&
                                include.TryGetProperty("attributes", out var attributes))
                            {
                                if (attributes.TryGetProperty("name", out var nameElement))
                                {
                                    var authorName = nameElement.GetString();
                                    var authorId = idElement.GetString();
                                    if (!string.IsNullOrEmpty(authorName) && !string.IsNullOrEmpty(authorId))
                                    {
                                        authorMap[authorId] = authorName;
                                        Console.WriteLine($"✅ Added author to map: {authorId} -> {authorName}");
                                    }
                                }
                            }
                        }
                        else if (type == "artist")
                        {
                            if (include.TryGetProperty("id", out var idElement) &&
                                include.TryGetProperty("attributes", out var attributes))
                            {
                                if (attributes.TryGetProperty("name", out var nameElement))
                                {
                                    var artistName = nameElement.GetString();
                                    var artistId = idElement.GetString();
                                    if (!string.IsNullOrEmpty(artistName) && !string.IsNullOrEmpty(artistId))
                                    {
                                        artistMap[artistId] = artistName;
                                        Console.WriteLine($"✅ Added artist to map: {artistId} -> {artistName}");
                                    }
                                }
                            }
                        }
                    }
                }

                Console.WriteLine($"✅ Cover art map count: {coverArtMap.Count}");
                Console.WriteLine($"✅ Author map count: {authorMap.Count}");
                Console.WriteLine($"✅ Artist map count: {artistMap.Count}");

                foreach (var item in dataArray.EnumerateArray())
                {
                    try
                    {
                        var mangaId = item.GetProperty("id").GetString();
                        var attributes = item.GetProperty("attributes");

                        // ✅ FIXED: Safe title parsing
                        string title = "Unknown Title";
                        if (attributes.TryGetProperty("title", out var titleObject))
                        {
                            var firstTitle = titleObject.EnumerateObject().FirstOrDefault();
                            if (firstTitle.Value.ValueKind != JsonValueKind.Undefined)
                            {
                                title = firstTitle.Value.GetString() ?? "Unknown Title";
                            }
                        }

                        // ✅ FIXED: Safe description parsing
                        string description = "No description available";
                        if (attributes.TryGetProperty("description", out var descriptionObject))
                        {
                            var firstDescription = descriptionObject.EnumerateObject().FirstOrDefault();
                            if (firstDescription.Value.ValueKind != JsonValueKind.Undefined)
                            {
                                description = firstDescription.Value.GetString() ?? "No description available";
                            }
                        }

                        // ✅ FIXED: Safe genre/tags parsing
                        var genres = new List<string>();
                        if (attributes.TryGetProperty("tags", out var tags))
                        {
                            foreach (var tag in tags.EnumerateArray())
                            {
                                if (tag.TryGetProperty("attributes", out var tagAttributes))
                                {
                                    if (tagAttributes.TryGetProperty("name", out var nameObject))
                                    {
                                        var firstTagName = nameObject.EnumerateObject().FirstOrDefault();
                                        if (firstTagName.Value.ValueKind != JsonValueKind.Undefined)
                                        {
                                            var tagName = firstTagName.Value.GetString();
                                            if (!string.IsNullOrEmpty(tagName))
                                            {
                                                genres.Add(tagName);
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        var genre = genres.Any() ? string.Join(", ", genres.Take(3)) : "Manga";

                        // ✅ FIXED: Extract author information from relationships
                        string authorName = "Unknown Author";
                        var creators = new List<string>();
                        
                        if (item.TryGetProperty("relationships", out var relationships))
                        {
                            foreach (var relationship in relationships.EnumerateArray())
                            {
                                var relationType = relationship.GetProperty("type").GetString();
                                var relationId = relationship.GetProperty("id").GetString();
                                
                                if (relationType == "author" && authorMap.TryGetValue(relationId, out var author))
                                {
                                    creators.Add(author);
                                    Console.WriteLine($"✅ Found author for {title}: {author}");
                                }
                                else if (relationType == "artist" && artistMap.TryGetValue(relationId, out var artist))
                                {
                                    creators.Add(artist);
                                    Console.WriteLine($"✅ Found artist for {title}: {artist}");
                                }
                            }
                        }

                        // Combine authors and artists
                        if (creators.Any())
                        {
                            authorName = string.Join(", ", creators.Distinct());
                            Console.WriteLine($"✅ Final author name for {title}: {authorName}");
                        }
                        else
                        {
                            Console.WriteLine($"⚠️ No author/artist found for {title}, using default");
                        }

                        // ✅ FIXED: Safe cover URL parsing
                        string coverUrl = null;
                        if (item.TryGetProperty("relationships", out relationships))
                        {
                            foreach (var relationship in relationships.EnumerateArray())
                            {
                                if (relationship.TryGetProperty("type", out var typeElement) && 
                                    typeElement.GetString() == "cover_art")
                                {
                                    if (relationship.TryGetProperty("id", out var coverIdElement))
                                    {
                                        var coverId = coverIdElement.GetString();
                                        if (!string.IsNullOrEmpty(coverId) && coverArtMap.TryGetValue(coverId, out var fileName))
                                        {
                                            coverUrl = $"https://uploads.mangadex.org/covers/{mangaId}/{fileName}";
                                            Console.WriteLine($"✅ Found cover for {title}: {coverUrl}");
                                        }
                                        else
                                        {
                                            Console.WriteLine($"⚠️ Cover ID {coverId} not found in coverArtMap");
                                        }
                                    }
                                    break;
                                }
                            }
                        }

                        var comic = new Comic
                        {
                            MangaDexId = mangaId,
                            Title = title,
                            Description = description,
                            Author = authorName, // ✅ NOW USING REAL AUTHOR DATA
                            Genre = genre,
                            FollowerCount = 0,
                            LastSynced = DateTime.UtcNow,
                            Chapters = new List<Chapter>(),
                            CoverImageUrl = coverUrl
                        };

                        comics.Add(comic);
                    }
                    catch (Exception ex)
                    {
                        Console.WriteLine($"❌ Error parsing individual manga item: {ex.Message}");
                    }
                }
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Error parsing MangaDex response: {ex.Message}");
                Console.WriteLine($"❌ Stack trace: {ex.StackTrace}");
            }

            Console.WriteLine($"✅ Successfully parsed {comics.Count} comics");
            return comics;
        }

        //- Get manga by ID
        public async Task<Comic> GetMangaByIdAsync(string mangaDexId)
        {
            try
            {
                // ✅ FIXED: Include author and artist in the request
                var response = await _httpClient.GetStringAsync($"https://api.mangadex.org/manga/{mangaDexId}?includes[]=cover_art&includes[]=author&includes[]=artist");
                var jsonDoc = JsonDocument.Parse(response);

                var data = jsonDoc.RootElement.GetProperty("data");
                var attributes = data.GetProperty("attributes");

                // ✅ FIXED: Safe title parsing
                string title = "Unknown Title";
                if (attributes.TryGetProperty("title", out var titleObject))
                {
                    var firstTitle = titleObject.EnumerateObject().FirstOrDefault();
                    if (firstTitle.Value.ValueKind != JsonValueKind.Undefined)
                    {
                        title = firstTitle.Value.GetString() ?? "Unknown Title";
                    }
                }

                // ✅ FIXED: Safe description parsing
                string description = "No description available";
                if (attributes.TryGetProperty("description", out var descriptionObject))
                {
                    var firstDescription = descriptionObject.EnumerateObject().FirstOrDefault();
                    if (firstDescription.Value.ValueKind != JsonValueKind.Undefined)
                    {
                        description = firstDescription.Value.GetString() ?? "No description available";
                    }
                }

                // ✅ FIXED: Safe genre/tags parsing
                var genres = new List<string>();
                if (attributes.TryGetProperty("tags", out var tags))
                {
                    foreach (var tag in tags.EnumerateArray())
                    {
                        if (tag.TryGetProperty("attributes", out var tagAttributes))
                        {
                            if (tagAttributes.TryGetProperty("name", out var nameObject))
                            {
                                var firstTagName = nameObject.EnumerateObject().FirstOrDefault();
                                if (firstTagName.Value.ValueKind != JsonValueKind.Undefined)
                                {
                                    var tagName = firstTagName.Value.GetString();
                                    if (!string.IsNullOrEmpty(tagName))
                                    {
                                        genres.Add(tagName);
                                    }
                                }
                            }
                        }
                    }
                }

                var genre = genres.Any() ? string.Join(", ", genres.Take(3)) : "Manga";

                // ✅ FIXED: Extract author information
                string authorName = "Unknown Author";
                var creators = new List<string>();
                var relationships = data.GetProperty("relationships");
                
                foreach (var relationship in relationships.EnumerateArray())
                {
                    var relationType = relationship.GetProperty("type").GetString();
                    var relationId = relationship.GetProperty("id").GetString();
                    
                    if (relationType == "author" || relationType == "artist")
                    {
                        try
                        {
                            // Get creator details
                            var creatorResponse = await _httpClient.GetStringAsync($"https://api.mangadex.org/{relationType}/{relationId}");
                            var creatorDoc = JsonDocument.Parse(creatorResponse);
                            var creatorData = creatorDoc.RootElement.GetProperty("data");
                            var creatorAttributes = creatorData.GetProperty("attributes");
                            var creatorName = creatorAttributes.GetProperty("name").GetString();
                            
                            creators.Add(creatorName);
                            Console.WriteLine($"✅ Found {relationType} for {title}: {creatorName}");
                        }
                        catch (Exception ex)
                        {
                            Console.WriteLine($"⚠️ Failed to get {relationType} details: {ex.Message}");
                        }
                    }
                }

                // Combine authors and artists
                if (creators.Any())
                {
                    authorName = string.Join(", ", creators.Distinct());
                    Console.WriteLine($"✅ Final author name for {title}: {authorName}");
                }

                // ✅ FIXED: Safe cover URL parsing for single manga
                string coverUrl = null;
                foreach (var relationship in relationships.EnumerateArray())
                {
                    if (relationship.TryGetProperty("type", out var typeElement) &&
                        typeElement.GetString() == "cover_art")
                    {
                        if (relationship.TryGetProperty("id", out var coverIdElement))
                        {
                            var coverId = coverIdElement.GetString();

                            // Get cover details to get the filename
                            var coverResponse = await _httpClient.GetStringAsync($"https://api.mangadex.org/cover/{coverId}");
                            var coverDoc = JsonDocument.Parse(coverResponse);
                            var coverData = coverDoc.RootElement.GetProperty("data");
                            var fileName = coverData.GetProperty("attributes").GetProperty("fileName").GetString();

                            coverUrl = $"https://uploads.mangadex.org/covers/{mangaDexId}/{fileName}";
                            Console.WriteLine($"✅ Found cover for {title}: {coverUrl}");
                        }
                        break;
                    }
                }

                return new Comic
                {
                    MangaDexId = mangaDexId,
                    Title = title,
                    Description = description,
                    Author = authorName, // ✅ NOW USING REAL AUTHOR DATA
                    Genre = genre,
                    FollowerCount = 0,
                    LastSynced = DateTime.UtcNow,
                    Chapters = new List<Chapter>(),
                    CoverImageUrl = coverUrl
                };
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Error getting manga by ID: {ex.Message}");
                return null;
            }
        }

        public async Task<string> GetCoverFilenameAsync(string mangaDexId)
        {
            try
            {
                // Get manga with cover relationship included
                var response = await _httpClient.GetStringAsync($"https://api.mangadex.org/manga/{mangaDexId}?includes[]=cover_art");
                var jsonDoc = JsonDocument.Parse(response);

                var data = jsonDoc.RootElement.GetProperty("data");
                var relationships = data.GetProperty("relationships");

                // Find cover art relationship
                foreach (var relationship in relationships.EnumerateArray())
                {
                    if (relationship.GetProperty("type").GetString() == "cover_art")
                    {
                        var coverId = relationship.GetProperty("id").GetString();

                        // Get cover details to get the filename
                        var coverResponse = await _httpClient.GetStringAsync($"https://api.mangadex.org/cover/{coverId}");
                        var coverDoc = JsonDocument.Parse(coverResponse);
                        var coverData = coverDoc.RootElement.GetProperty("data");
                        var fileName = coverData.GetProperty("attributes").GetProperty("fileName").GetString();

                        return fileName;
                    }
                }

                return null;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error getting cover filename: {ex.Message}");
                return null;
            }
        }

        public List<Chapter> ParseChaptersResponse(string jsonResponse)
        {
            var chapters = new List<Chapter>();

            try
            {
                var jsonDoc = JsonDocument.Parse(jsonResponse);
                var dataArray = jsonDoc.RootElement.GetProperty("data");

                foreach (var item in dataArray.EnumerateArray())
                {
                    var attributes = item.GetProperty("attributes");
                    var relationships = item.GetProperty("relationships");

                    // Get scanlation group name
                    string groupName = "Unknown Group";
                    foreach (var relationship in relationships.EnumerateArray())
                    {
                        if (relationship.GetProperty("type").GetString() == "scanlation_group")
                        {
                            var groupAttributes = relationship.GetProperty("attributes");
                            if (groupAttributes.TryGetProperty("name", out var nameElement))
                            {
                                groupName = nameElement.GetString() ?? "Unknown Group";
                            }
                            break;
                        }
                    }

                    // Parse chapter number safely
                    string chapterNumber = "0";
                    if (attributes.TryGetProperty("chapter", out var chapterElement) && chapterElement.ValueKind != JsonValueKind.Null)
                    {
                        chapterNumber = chapterElement.GetString() ?? "0";
                    }

                    // Parse title safely
                    string title = $"Chapter {chapterNumber}";
                    if (attributes.TryGetProperty("title", out var titleElement) && titleElement.ValueKind != JsonValueKind.Null)
                    {
                        var titleValue = titleElement.GetString();
                        if (!string.IsNullOrEmpty(titleValue))
                        {
                            title = titleValue;
                        }
                    }

                    // Parse publish date safely
                    DateTime? publishedAt = null;
                    if (attributes.TryGetProperty("publishAt", out var publishElement) && 
                        publishElement.ValueKind != JsonValueKind.Null)
                    {
                        var publishString = publishElement.GetString();
                        if (DateTime.TryParse(publishString, out var parsedDate))
                        {
                            publishedAt = parsedDate;
                        }
                    }

                    // ✅ PRINT DETAILED CHAPTER INFO
                    Console.WriteLine($"  - Chapter {chapterNumber}: '{title}'");
                    Console.WriteLine($"    Group: {groupName}, Published: {publishedAt}");

                    var chapter = new Chapter
                    {
                         ChapterId = item.GetProperty("id").GetString() ?? string.Empty,
                        Title = title,
                        ChapterNumber = chapterNumber,
                        Pages = new List<Page>(),
                        PublishedAt = publishedAt,
                        GroupName = groupName,
                        Volume = attributes.TryGetProperty("volume", out var volumeElement) ? volumeElement.GetString() ?? "" : ""
                    };

                    chapters.Add(chapter);
                }

                // Sort by chapter number numerically
                chapters = chapters.OrderBy(c => 
                {
                    if (decimal.TryParse(c.ChapterNumber, out decimal num))
                        return num;
                    return decimal.MaxValue;
                }).ToList();
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error parsing chapters response: {ex.Message}");
            }

            return chapters;
        }

        public async Task<List<Chapter>> GetChaptersAsync(string mangaDexId, int limit = 100)
        {
            try
            {
                Console.WriteLine($"=== FETCHING CHAPTERS ===");
                Console.WriteLine($"MangaDex ID: {mangaDexId}");
                Console.WriteLine($"Limit: {limit}");
                
                var response = await _httpClient.GetStringAsync(
                    $"https://api.mangadex.org/manga/{mangaDexId}/feed?translatedLanguage[]=en&limit={limit}&order[chapter]=desc&includes[]=scanlation_group"
                );
                
                Console.WriteLine($"Raw response length: {response.Length} characters");
                
                var chapters = ParseChaptersResponse(response);
                
                Console.WriteLine($"=== CHAPTER FETCH COMPLETE ===");
                Console.WriteLine($"Total chapters returned: {chapters.Count}");
                Console.WriteLine();
                
                return chapters;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error getting chapters: {ex.Message}");
                return new List<Chapter>();
            }
        }
// In MangaDexService.cs - Add this method
public async Task<List<Chapter>> GetChapterListAsync(string mangaDexId, int limit = 500)
{
    try
    {
        Console.WriteLine($"🔍 Getting chapter list for: {mangaDexId}");
        
        var response = await _httpClient.GetStringAsync(
            $"https://api.mangadex.org/manga/{mangaDexId}/feed?translatedLanguage[]=en&limit={limit}&order[chapter]=asc&includes[]=scanlation_group"
        );
        
        var chapters = ParseChaptersResponse(response);
        
        // ✅ Remove page data to reduce payload size
        foreach (var chapter in chapters)
        {
            chapter.Pages = new List<Page>(); // Empty pages list
        }
        
        Console.WriteLine($"✅ Chapter list loaded: {chapters.Count} chapters");
        return chapters;
    }
    catch (Exception ex)
    {
        Console.WriteLine($"❌ Error getting chapter list: {ex.Message}");
        return new List<Chapter>();
    }
}
        public async Task<Chapter> GetChapterPagesAsync(string chapterId)
        {
            try
            {
                Console.WriteLine($"🔍 Getting chapter pages for: {chapterId}");
                
                var atHomeResponse = await _httpClient.GetStringAsync($"https://api.mangadex.org/at-home/server/{chapterId}");
                var atHomeDoc = JsonDocument.Parse(atHomeResponse);
                
                var baseUrl = atHomeDoc.RootElement.GetProperty("baseUrl").GetString();
                var chapterData = atHomeDoc.RootElement.GetProperty("chapter");
                var hash = chapterData.GetProperty("hash").GetString();
                var dataArray = chapterData.GetProperty("data").EnumerateArray().Select(x => x.GetString()).ToArray();
                
                // Get chapter details to include metadata
                var chapterDetailsResponse = await _httpClient.GetStringAsync($"https://api.mangadex.org/chapter/{chapterId}");
                var chapterDetailsDoc = JsonDocument.Parse(chapterDetailsResponse);
                var chapterAttributes = chapterDetailsDoc.RootElement.GetProperty("data").GetProperty("attributes");

                var pages = new List<Page>();
                for (int i = 0; i < dataArray.Length; i++)
                {
                    pages.Add(new Page
                    {
                        PageNumber = i + 1,
                        ImageUrl = $"{baseUrl}/data/{hash}/{dataArray[i]}",
                        Width = 0,
                        Height = 0
                    });
                }

                // Parse chapter details safely
                string chapterNumber = "0";
                if (chapterAttributes.TryGetProperty("chapter", out var chapterElement) && chapterElement.ValueKind != JsonValueKind.Null)
                {
                    chapterNumber = chapterElement.GetString() ?? "0";
                }

                string title = $"Chapter {chapterNumber}";
                if (chapterAttributes.TryGetProperty("title", out var titleElement) && titleElement.ValueKind != JsonValueKind.Null)
                {
                    var titleValue = titleElement.GetString();
                    if (!string.IsNullOrEmpty(titleValue))
                    {
                        title = titleValue;
                    }
                }

                DateTime? publishedAt = null;
                if (chapterAttributes.TryGetProperty("publishAt", out var publishElement) && 
                    publishElement.ValueKind != JsonValueKind.Null)
                {
                    var publishString = publishElement.GetString();
                    if (DateTime.TryParse(publishString, out var parsedDate))
                    {
                        publishedAt = parsedDate;
                    }
                }

                return new Chapter
                {
                    ChapterId = chapterId,
                    Title = title,
                    ChapterNumber = chapterNumber,
                    Pages = pages,
                    PublishedAt = publishedAt,
                    Volume = chapterAttributes.TryGetProperty("volume", out var volumeElement) ? volumeElement.GetString() ?? "" : ""
                };
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Error getting chapter pages: {ex.Message}");
                return null;
            }
        }


// ✅ ADD THESE METHODS TO MangaDexService.cs
public async Task<Chapter> GetFirstChapterAsync(string mangaDexId)
{
    try
    {
        Console.WriteLine($"🔍 Getting first chapter for: {mangaDexId}");
        
        var response = await _httpClient.GetStringAsync(
            $"https://api.mangadex.org/manga/{mangaDexId}/feed?translatedLanguage[]=en&limit=1&order[chapter]=asc&includes[]=scanlation_group"
        );
        
        var chapters = ParseChaptersResponse(response);
        var firstChapter = chapters.FirstOrDefault();
        
        if (firstChapter != null)
        {
            Console.WriteLine($"✅ Found first chapter: {firstChapter.ChapterNumber}");
        }
        else
        {
            Console.WriteLine($"⚠️ No first chapter found for: {mangaDexId}");
        }
        
        return firstChapter;
    }
    catch (Exception ex)
    {
        Console.WriteLine($"❌ Error getting first chapter: {ex.Message}");
        return null;
    }
}

public async Task<Chapter> GetLatestChapterAsync(string mangaDexId)
{
    try
    {
        Console.WriteLine($"🔍 Getting latest chapter for: {mangaDexId}");
        
        var response = await _httpClient.GetStringAsync(
            $"https://api.mangadex.org/manga/{mangaDexId}/feed?translatedLanguage[]=en&limit=500&order[chapter]=desc&includes[]=scanlation_group"
        );
        
        var chapters = ParseChaptersResponse(response);
        
        // ✅ ENHANCED: Better chapter number parsing
        Chapter latestChapter = null;
        decimal highestChapter = 0;
        
        foreach (var chapter in chapters)
        {
            var chapterNum = ParseChapterNumber(chapter.ChapterNumber);
            if (chapterNum > highestChapter)
            {
                highestChapter = chapterNum;
                latestChapter = chapter;
            }
        }
        
        if (latestChapter != null)
        {
            Console.WriteLine($"✅ Found latest chapter: {latestChapter.ChapterNumber} (parsed as {highestChapter})");
        }
        else
        {
            latestChapter = chapters.FirstOrDefault();
            Console.WriteLine($"⚠️ Using fallback: {latestChapter?.ChapterNumber}");
        }
        
        return latestChapter;
    }
    catch (Exception ex)
    {
        Console.WriteLine($"❌ Error getting latest chapter: {ex.Message}");
        return null;
    }
}

        // ✅ HELPER: Parse complex chapter numbers
        private decimal ParseChapterNumber(string chapterNumber)
        {
            if (string.IsNullOrEmpty(chapterNumber))
                return 0;

            // Remove non-numeric characters except decimal points
            var cleanNumber = System.Text.RegularExpressions.Regex.Replace(chapterNumber, @"[^\d.]", "");

            if (decimal.TryParse(cleanNumber, out decimal result))
            {
                return result;
            }

            // Try to extract number from beginning
            var match = System.Text.RegularExpressions.Regex.Match(chapterNumber, @"^(\d+(\.\d+)?)");
            if (match.Success && decimal.TryParse(match.Value, out decimal extracted))
            {
                return extracted;
            }

            return 0;
        }

public async Task<List<Chapter>> GetFirstAndLatestChaptersAsync(string mangaDexId)
{
    try
    {
        Console.WriteLine($"🔍 Getting first and latest chapters for: {mangaDexId}");
        
        var firstChapter = await GetFirstChapterAsync(mangaDexId);
        var latestChapter = await GetLatestChapterAsync(mangaDexId);
        
        var result = new List<Chapter>();
        
        if (firstChapter != null)
        {
            result.Add(firstChapter);
            Console.WriteLine($"✅ First chapter: {firstChapter.ChapterNumber}");
        }
        
        if (latestChapter != null && (firstChapter == null || firstChapter.ChapterId != latestChapter.ChapterId))
        {
            result.Add(latestChapter);
            Console.WriteLine($"✅ Latest chapter: {latestChapter.ChapterNumber}");
        }
        
        Console.WriteLine($"✅ Returning {result.Count} chapters total");
        return result;
    }
    catch (Exception ex)
    {
        Console.WriteLine($"❌ Error getting first and latest chapters: {ex.Message}");
        return new List<Chapter>();
    }
}
        public async Task<string> DebugRawSearchResponse(string title)
        {
            try
            {
                var response = await _httpClient.GetStringAsync($"https://api.mangadex.org/manga?title={Uri.EscapeDataString(title)}&limit=1&availableTranslatedLanguage[]=en&includes[]=cover_art");
                Console.WriteLine($"RAW RESPONSE: {response}");
                return response;
            }
            catch (Exception ex)
            {
                Console.WriteLine($"Debug error: {ex.Message}");
                return null;
            }
        }

        public void Dispose()
        {
            _httpClient?.Dispose();
        }
    }   
}