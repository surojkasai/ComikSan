// using System;
// using System.Collections.Generic;
// using System.Linq;
// using System.Net.Http;
// using System.Text.Json;
// using System.Threading.Tasks;
// using ComikSanBackend.Models;
// using Microsoft.Extensions.Logging;

// namespace ComikSanBackend.Services
// {
//     public class MangaDexService
//     {
//         private readonly HttpClient _httpClient;
//         private readonly ILogger<MangaDexService> _logger;

//         public MangaDexService(HttpClient httpClient, ILogger<MangaDexService> logger)
//         {
//             _httpClient = httpClient;
//             _logger = logger;
//             _httpClient.DefaultRequestHeaders.Add("User-Agent", "ComikSanBackend/1.0");
//         }

//         public async Task<List<Comic>> SearchMangaAsync(string title)
//         {
//             try
//             {
//                 var response = await _httpClient.GetStringAsync($"https://api.mangadex.org/manga?title={Uri.EscapeDataString(title)}&limit=10&availableTranslatedLanguage[]=en&includes[]=cover_art");
//                 return ParseMangaDexResponse(response);
//             }
//             catch (Exception ex)
//             {
//                 Console.WriteLine($"Error searching manga: {ex.Message}");
//                 return new List<Comic>();
//             }
//         }

//         // ✅ ADD THIS MISSING METHOD
//         private List<Comic> ParseMangaDexResponse(string jsonResponse)
//         {
//             var comics = new List<Comic>();

//             try
//             {
//                 var jsonDoc = JsonDocument.Parse(jsonResponse);
//                 var dataArray = jsonDoc.RootElement.GetProperty("data");
//                 var includes = jsonDoc.RootElement.GetProperty("includes");
//                 var coverArtMap = new Dictionary<string, string>();
        
//          foreach (var include in includes.EnumerateArray())
//         {
//             if (include.GetProperty("type").GetString() == "cover_art")
//             {
//                 var attributes = include.GetProperty("attributes");
//                 var fileName = attributes.GetProperty("fileName").GetString();
//                 var relationshipId = include.GetProperty("id").GetString();
//                 coverArtMap[relationshipId] = fileName;
//             }
//         }

//                 foreach (var item in dataArray.EnumerateArray())
//                 {
//                     var attributes = item.GetProperty("attributes");
//                     var titleObject = attributes.GetProperty("title");

//                     // Get the first available title (usually English)
//                     var title = titleObject.EnumerateObject().FirstOrDefault().Value.GetString() ?? "Unknown Title";

//                     var descriptionObject = attributes.GetProperty("description");
//                     var description = descriptionObject.EnumerateObject().FirstOrDefault().Value.GetString() ?? "No description available";

                    
//                     // Get tags for genre
//                     var tags = attributes.GetProperty("tags");
//                     var genres = new List<string>();

//                     foreach (var tag in tags.EnumerateArray())
//                     {
//                         var tagAttributes = tag.GetProperty("attributes");
//                         var tagName = tagAttributes.GetProperty("name").EnumerateObject().FirstOrDefault().Value.GetString();
//                         if (!string.IsNullOrEmpty(tagName))
//                         {
//                             genres.Add(tagName);
//                         }
//                     }

//                     var genre = genres.Any() ? string.Join(", ", genres.Take(3)) : "Manga";

                    

//                     var comic = new Comic
//                     {
//                         MangaDexId = item.GetProperty("id").GetString(),
//                         Title = title,
//                         Description = description,
//                         Author = "Unknown Author",
//                         Genre = genre,
//                         FollowerCount = 0, 
//                         //so this is backend–API sync time
//                         LastSynced = DateTime.UtcNow,
//                         Chapters = new List<Chapter>() // Initialize empty chapters list
//                     };

//                     comics.Add(comic);
//                 }
//             }
//             catch (Exception ex)
//             {
//                 Console.WriteLine($"Error parsing MangaDex response: {ex.Message}");
//             }

//             return comics;
//         }



//         //- Get manga by ID
//         public async Task<Comic> GetMangaByIdAsync(string mangaDexId)
//         {
//             try
//             {
//                 var response = await _httpClient.GetStringAsync($"https://api.mangadex.org/manga/{mangaDexId}");
//                 var jsonDoc = JsonDocument.Parse(response);

//                 var data = jsonDoc.RootElement.GetProperty("data");
//                 var attributes = data.GetProperty("attributes");

//                 var titleObject = attributes.GetProperty("title");
//                 var title = titleObject.EnumerateObject().FirstOrDefault().Value.GetString() ?? "Unknown Title";

//                 var descriptionObject = attributes.GetProperty("description");
//                 var description = descriptionObject.EnumerateObject().FirstOrDefault().Value.GetString() ?? "No description available";

//                 // Get tags for genre
//                 var tags = attributes.GetProperty("tags");
//                 var genres = new List<string>();

//                 foreach (var tag in tags.EnumerateArray())
//                 {
//                     var tagAttributes = tag.GetProperty("attributes");
//                     var tagName = tagAttributes.GetProperty("name").EnumerateObject().FirstOrDefault().Value.GetString();
//                     if (!string.IsNullOrEmpty(tagName))
//                     {
//                         genres.Add(tagName);
//                     }
//                 }

//                 var genre = genres.Any() ? string.Join(", ", genres.Take(3)) : "Manga";

//                 return new Comic
//                 {
//                     MangaDexId = mangaDexId,
//                     Title = title,
//                     Description = description,
//                     Author = "Unknown Author",
//                     Genre = genre,
//                     FollowerCount = 0,
//                     LastSynced = DateTime.UtcNow,
//                     Chapters = new List<Chapter>()
//                 };
//             }
//             catch (Exception ex)
//             {
//                 Console.WriteLine($"Error getting manga by ID: {ex.Message}");
//                 return null;
//             }
//         }

//         // ✅ ADD THIS METHOD - Get cover filename
//         public async Task<string> GetCoverFilenameAsync(string mangaDexId)
//         {
//             try
//             {
//                 // Get manga with cover relationship included
//                 var response = await _httpClient.GetStringAsync($"https://api.mangadex.org/manga/{mangaDexId}?includes[]=cover_art");
//                 var jsonDoc = JsonDocument.Parse(response);

//                 var data = jsonDoc.RootElement.GetProperty("data");
//                 var relationships = data.GetProperty("relationships");

//                 // Find cover art relationship
//                 foreach (var relationship in relationships.EnumerateArray())
//                 {
//                     if (relationship.GetProperty("type").GetString() == "cover_art")
//                     {
//                         var coverId = relationship.GetProperty("id").GetString();

//                         // Get cover details to get the filename
//                         var coverResponse = await _httpClient.GetStringAsync($"https://api.mangadex.org/cover/{coverId}");
//                         var coverDoc = JsonDocument.Parse(coverResponse);
//                         var coverData = coverDoc.RootElement.GetProperty("data");
//                         var fileName = coverData.GetProperty("attributes").GetProperty("fileName").GetString();

//                         return fileName;
//                     }
//                 }

//                 return null;
//             }
//             catch (Exception ex)
//             {
//                 Console.WriteLine($"Error getting cover filename: {ex.Message}");
//                 return null;
//             }
//         }


// private List<Chapter> ParseChaptersResponse(string jsonResponse)
// {
//     var chapters = new List<Chapter>();

//     try
//     {
//         var jsonDoc = JsonDocument.Parse(jsonResponse);
//         var dataArray = jsonDoc.RootElement.GetProperty("data");

//         foreach (var item in dataArray.EnumerateArray())
//         {
//             var attributes = item.GetProperty("attributes");
//             var relationships = item.GetProperty("relationships");

//             // Get scanlation group name
//             string groupName = "Unknown Group";
//             foreach (var relationship in relationships.EnumerateArray())
//             {
//                 if (relationship.GetProperty("type").GetString() == "scanlation_group")
//                 {
//                     var groupAttributes = relationship.GetProperty("attributes");
//                     if (groupAttributes.TryGetProperty("name", out var nameElement))
//                     {
//                         groupName = nameElement.GetString() ?? "Unknown Group";
//                     }
//                     break;
//                 }
//             }

//             // Parse chapter number safely
//             string chapterNumber = "0";
//             if (attributes.TryGetProperty("chapter", out var chapterElement) && chapterElement.ValueKind != JsonValueKind.Null)
//             {
//                 chapterNumber = chapterElement.GetString() ?? "0";
//             }

//             // Parse title safely
//             string title = $"Chapter {chapterNumber}";
//             if (attributes.TryGetProperty("title", out var titleElement) && titleElement.ValueKind != JsonValueKind.Null)
//             {
//                 var titleValue = titleElement.GetString();
//                 if (!string.IsNullOrEmpty(titleValue))
//                 {
//                     title = titleValue;
//                 }
//             }

//             // Parse publish date safely
//             DateTime? publishedAt = null;
//             if (attributes.TryGetProperty("publishAt", out var publishElement) && 
//                 publishElement.ValueKind != JsonValueKind.Null)
//             {
//                 var publishString = publishElement.GetString();
//                 if (DateTime.TryParse(publishString, out var parsedDate))
//                 {
//                     publishedAt = parsedDate;
//                 }
//             }

//              // ✅ PRINT DETAILED CHAPTER INFO
//             Console.WriteLine($"  - Chapter {chapterNumber}: '{title}'");
//             Console.WriteLine($"    Group: {groupName}, Published: {publishedAt}");

//             var chapter = new Chapter
//             {
//                  ChapterId = item.GetProperty("id").GetString() ?? string.Empty, // Use ChapterId here
//                 Title = title,
//                 ChapterNumber = chapterNumber,
//                 Pages = new List<Page>(),
//                 PublishedAt = publishedAt,
//                 GroupName = groupName,
//                 Volume = attributes.TryGetProperty("volume", out var volumeElement) ? volumeElement.GetString() ?? "" : ""
//             };

//             chapters.Add(chapter);
//         }

//         // Sort by chapter number numerically
//         chapters = chapters.OrderBy(c => 
//         {
//             if (decimal.TryParse(c.ChapterNumber, out decimal num))
//                 return num;
//             return decimal.MaxValue;
//         }).ToList();
//     }
//     catch (Exception ex)
//     {
//         Console.WriteLine($"Error parsing chapters response: {ex.Message}");
//     }

//     return chapters;
// }

// // ✅ ADD THIS PUBLIC METHOD - Get chapters for a manga
// public async Task<List<Chapter>> GetChaptersAsync(string mangaDexId, int limit = 100)
// {
//     try
//     {
//           // ✅ PRINT START OF CHAPTER FETCH
//         Console.WriteLine($"=== FETCHING CHAPTERS ===");
//         Console.WriteLine($"MangaDex ID: {mangaDexId}");
//         Console.WriteLine($"Limit: {limit}");
//         // Get chapters for the manga
//                 var response = await _httpClient.GetStringAsync(
//             $"https://api.mangadex.org/manga/{mangaDexId}/feed?translatedLanguage[]=en&limit={limit}&order[chapter]=desc&includes[]=scanlation_group"
//         );
        
//         // ✅ PRINT RAW RESPONSE LENGTH (optional - can be large)
//         Console.WriteLine($"Raw response length: {response.Length} characters");
        
//         var chapters = ParseChaptersResponse(response);
        
//         // ✅ PRINT FINAL RESULT
//         Console.WriteLine($"=== CHAPTER FETCH COMPLETE ===");
//         Console.WriteLine($"Total chapters returned: {chapters.Count}");
//         Console.WriteLine();
        
//         return chapters;
//     }
//     catch (Exception ex)
//     {
//         Console.WriteLine($"Error getting chapters: {ex.Message}");
//         return new List<Chapter>();
//     }
// }
// public async Task<Chapter> GetChapterPagesAsync(string chapterId)
// {
//     try
//     {
//         // First get the at-home server URL
//         var atHomeResponse = await _httpClient.GetStringAsync($"https://api.mangadex.org/at-home/server/{chapterId}");
//         var atHomeDoc = JsonDocument.Parse(atHomeResponse);
        
//         var baseUrl = atHomeDoc.RootElement.GetProperty("baseUrl").GetString();
//         var chapterData = atHomeDoc.RootElement.GetProperty("chapter");
//         var hash = chapterData.GetProperty("hash").GetString();
//         var dataArray = chapterData.GetProperty("data").EnumerateArray().Select(x => x.GetString()).ToArray();
        
//         // Get chapter details to include metadata
//         var chapterDetailsResponse = await _httpClient.GetStringAsync($"https://api.mangadex.org/chapter/{chapterId}");
//         var chapterDetailsDoc = JsonDocument.Parse(chapterDetailsResponse);
//         var chapterAttributes = chapterDetailsDoc.RootElement.GetProperty("data").GetProperty("attributes");

//         var pages = new List<Page>();
//         for (int i = 0; i < dataArray.Length; i++)
//         {
//             pages.Add(new Page
//             {
//                 PageNumber = i + 1, // This should work now with the fixed Page model
//                 ImageUrl = $"{baseUrl}/data/{hash}/{dataArray[i]}",
//                 Width = 0, // MangaDex doesn't provide dimensions
//                 Height = 0
//             });
//         }

//         // Parse chapter details safely
//         string chapterNumber = "0";
//         if (chapterAttributes.TryGetProperty("chapter", out var chapterElement) && chapterElement.ValueKind != JsonValueKind.Null)
//         {
//             chapterNumber = chapterElement.GetString() ?? "0";
//         }

//         string title = $"Chapter {chapterNumber}";
//         if (chapterAttributes.TryGetProperty("title", out var titleElement) && titleElement.ValueKind != JsonValueKind.Null)
//         {
//             var titleValue = titleElement.GetString();
//             if (!string.IsNullOrEmpty(titleValue))
//             {
//                 title = titleValue;
//             }
//         }

//         DateTime? publishedAt = null;
//         if (chapterAttributes.TryGetProperty("publishAt", out var publishElement) && 
//             publishElement.ValueKind != JsonValueKind.Null)
//         {
//             var publishString = publishElement.GetString();
//             if (DateTime.TryParse(publishString, out var parsedDate))
//             {
//                 publishedAt = parsedDate;
//             }
//         }

//         return new Chapter
//         {
//              ChapterId = chapterId, // Use ChapterId here
//             Title = title,
//             ChapterNumber = chapterNumber,
//             Pages = pages,
//             PublishedAt = publishedAt,
//             Volume = chapterAttributes.TryGetProperty("volume", out var volumeElement) ? volumeElement.GetString() ?? "" : ""
//         };
//     }
//     catch (Exception ex)
//     {
//         Console.WriteLine($"Error getting chapter pages: {ex.Message}");
//         return null;
//     }
// }


// // private readonly Dictionary<string, (List<Comic> data, DateTime expiry)> _memoryCache = new();
// // private readonly object _cacheLock = new object();

// // public async Task<List<Comic>> GetTrendingMangaAsync(int limit = 20)
// // {
// //     var cacheKey = $"trending:{limit}";
    
// //     // Simple in-memory cache check
// //     lock (_cacheLock)
// //     {
// //         if (_memoryCache.ContainsKey(cacheKey) && _memoryCache[cacheKey].expiry > DateTime.Now)
// //         {
// //             return _memoryCache[cacheKey].data;
// //         }
// //     }

// //     try
// //     {
// //         var response = await _httpClient.GetStringAsync(
// //             $"https://api.mangadex.org/manga?limit={limit}&order[followedCount]=desc&includes[]=cover_art&availableTranslatedLanguage[]=en"
// //         );
        
// //         var results = ParseMangaDexResponse(response);
        
// //         // Store in memory cache for 1 hour
// //         lock (_cacheLock)
// //         {
// //             _memoryCache[cacheKey] = (results, DateTime.Now.AddHours(1));
// //         }
        
// //         return results;
// //     }
// //     catch (Exception ex)
// //     {
// //         _logger.LogError($"Error getting trending manga: {ex.Message}");
// //         return new List<Comic>();
// //     }
// // }

// // public async Task<List<Comic>> GetRecentlyUpdatedMangaAsync(int limit = 20)
// // {
// //     try
// //     {
// //         // Get manga with recently uploaded chapters
// //         var response = await _httpClient.GetStringAsync(
// //             $"https://api.mangadex.org/manga?limit={limit}&order[latestUploadedChapter]=desc&includes[]=cover_art&availableTranslatedLanguage[]=en"
// //         );

// //         var results = ParseMangaDexResponse(response);
// //         return results;
// //     }
// //     catch (Exception ex)
// //     {
// //         _logger.LogError($"Error getting recently updated manga: {ex.Message}");
// //         return new List<Comic>();
// //     }
// // }

// // public async Task<List<Comic>> GetNewMangaAsync(int limit = 20)
// // {
// //     try
// //     {
// //         // Get newly created manga
// //         var response = await _httpClient.GetStringAsync(
// //             $"https://api.mangadex.org/manga?limit={limit}&order[createdAt]=desc&includes[]=cover_art&availableTranslatedLanguage[]=en"
// //         );

// //         var results = ParseMangaDexResponse(response);
// //         return results;
// //     }
// //     catch (Exception ex)
// //     {
// //         _logger.LogError($"Error getting new manga: {ex.Message}");
// //         return new List<Comic>();
// //     }
// // }


//         // Optional: If you need the raw response method
//         public async Task<string> GetRawResponseAsync(string title)
//         {
//             return await _httpClient.GetStringAsync($"https://api.mangadex.org/manga?title={Uri.EscapeDataString(title)}&limit=5");
//         }

//         public void Dispose()
//         {
//             _httpClient?.Dispose();
//         }




//     }
    
    
// }



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
        // ✅ FIXED: Use correct parameter format for multiple includes
        var response = await _httpClient.GetStringAsync(
            $"https://api.mangadex.org/manga?title={Uri.EscapeDataString(title)}&limit=10&availableTranslatedLanguage[]=en&includes[]=cover_art&includes[]=author"
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
                
                // ✅ FIXED: Safe parsing of includes
                var coverArtMap = new Dictionary<string, string>();
                
                // Check if includes exists and has cover_art
                if (jsonDoc.RootElement.TryGetProperty("includes", out var includes))
                {
                    foreach (var include in includes.EnumerateArray())
                    {
                        if (include.TryGetProperty("type", out var typeElement) && 
                            typeElement.GetString() == "cover_art")
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
                    }
                }

                Console.WriteLine($"✅ Cover art map count: {coverArtMap.Count}");

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

                        // ✅ FIXED: Safe cover URL parsing
                        string coverUrl = null;
                        if (item.TryGetProperty("relationships", out var relationships))
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
                            Author = "Unknown Author",
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
                        // Continue with next item instead of breaking the whole loop
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
                // ✅ FIXED: Include cover_art in the request
                var response = await _httpClient.GetStringAsync($"https://api.mangadex.org/manga/{mangaDexId}");
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

                // ✅ FIXED: Safe cover URL parsing for single manga
                string coverUrl = null;
                if (data.TryGetProperty("relationships", out var relationships))
                {
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
                }

                return new Comic
                {
                    MangaDexId = mangaDexId,
                    Title = title,
                    Description = description,
                    Author = "Unknown Author",
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
private List<Chapter> ParseChaptersResponse(string jsonResponse)
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
                 ChapterId = item.GetProperty("id").GetString() ?? string.Empty, // Use ChapterId here
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

// ✅ ADD THIS PUBLIC METHOD - Get chapters for a manga
public async Task<List<Chapter>> GetChaptersAsync(string mangaDexId, int limit = 100)
{
    try
    {
          // ✅ PRINT START OF CHAPTER FETCH
        Console.WriteLine($"=== FETCHING CHAPTERS ===");
        Console.WriteLine($"MangaDex ID: {mangaDexId}");
        Console.WriteLine($"Limit: {limit}");
        // Get chapters for the manga
                var response = await _httpClient.GetStringAsync(
            $"https://api.mangadex.org/manga/{mangaDexId}/feed?translatedLanguage[]=en&limit={limit}&order[chapter]=desc&includes[]=scanlation_group"
        );
        
        // ✅ PRINT RAW RESPONSE LENGTH (optional - can be large)
        Console.WriteLine($"Raw response length: {response.Length} characters");
        
        var chapters = ParseChaptersResponse(response);
        
        // ✅ PRINT FINAL RESULT
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
public async Task<Chapter> GetChapterPagesAsync(string chapterId)
{
    try
            {
        Console.WriteLine($"🔍 Getting chapter pages for: {chapterId}");
        // First get the at-home server URL
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
                PageNumber = i + 1, // This should work now with the fixed Page model
                ImageUrl = $"{baseUrl}/data/{hash}/{dataArray[i]}",
                Width = 0, // MangaDex doesn't provide dimensions
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
             ChapterId = chapterId, // Use ChapterId here
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

        // Add this temporary method to debug the raw response
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