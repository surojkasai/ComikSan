using Microsoft.AspNetCore.Mvc;
using ComikSanBackend.Services;
using ComikSanBackend.Data;
using ComikSanBackend.Models;
using System.Text.Json;
using System.Net.Http;
using Microsoft.EntityFrameworkCore;

namespace ComikSanBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class MangaDexController : ControllerBase
    {
        private readonly MangaDexService _mangaDexService;
        private readonly ComikSanDbContext _context; // Add this field

        // Update constructor to accept ComikSanDbContext
        public MangaDexController(MangaDexService mangaDexService, ComikSanDbContext context)
        {
            _mangaDexService = mangaDexService;
            _context = context; // Initialize the context
        }



     [HttpGet("search")]
public async Task<IActionResult> SearchManga([FromQuery] string title)
{
    if (string.IsNullOrEmpty(title))
        return BadRequest("Title is required");
    
    var results = await _mangaDexService.SearchMangaAsync(title);
    if (!results.Any())
        return NotFound($"No manga found with title '{title}'");

    // ✅ FIXED: Don't import during search - just return search results
    // If you want search results to have chapters, fetch them here:
    var enhancedResults = new List<Comic>();
    foreach (var manga in results.Take(3))
    {
        // Fetch chapters for search results display
        var chapters = await _mangaDexService.GetFirstAndLatestChaptersAsync(manga.MangaDexId);
        manga.Chapters = chapters;
        enhancedResults.Add(manga);
        
        Console.WriteLine($"✅ Search result: {manga.Title} - {chapters.Count} chapters");
    }

    return Ok(enhancedResults);
}
        [HttpGet("debug-search")]
        public async Task<IActionResult> DebugSearch([FromQuery] string title)
        {
            try
            {
                var results = await _mangaDexService.SearchMangaAsync(title);

                // Log each result with cover URL info
                foreach (var comic in results)
                {
                    Console.WriteLine($"📖 Title: {comic.Title}");
                    Console.WriteLine($"   CoverImageUrl: {comic.CoverImageUrl ?? "NULL"}");
                    Console.WriteLine($"   MangaDexId: {comic.MangaDexId}");
                }

                return Ok(new
                {
                    count = results.Count,
                    results = results.Select(r => new
                    {
                        title = r.Title,
                        coverImageUrl = r.CoverImageUrl,
                        mangaDexId = r.MangaDexId,
                        hasCover = !string.IsNullOrEmpty(r.CoverImageUrl)
                    })
                });
            }
            catch (Exception ex)
            {
                return BadRequest($"Debug error: {ex.Message}");
            }
        }

        [HttpPost("import/{mangaDexId}")]
        public async Task<IActionResult> ImportManga(string mangaDexId)
        {
            try
            {
                // Check if manga already exists in database
                var existingManga = _context.Comics.FirstOrDefault(c => c.MangaDexId == mangaDexId);
                if (existingManga != null)
                {
                    return Conflict(new
                    {
                        message = $"Manga '{existingManga.Title}' already exists in database",
                        comic = existingManga
                    });
                }

                // Get manga by ID
                var manga = await _mangaDexService.GetMangaByIdAsync(mangaDexId);
                if (manga == null)
                    return NotFound($"Manga with ID {mangaDexId} not found");

                // ✅ FIXED: Get cover filename
                var coverFilename = await _mangaDexService.GetCoverFilenameAsync(mangaDexId);
                if (!string.IsNullOrEmpty(coverFilename))
                {
                    manga.CoverImageUrl = $"https://uploads.mangadex.org/covers/{mangaDexId}/{coverFilename}";
                    Console.WriteLine($"✅ Cover URL set to: {manga.CoverImageUrl}");
                }

                // ✅ NEW: Fetch first and latest chapters for this comic
                Console.WriteLine($"🔄 Fetching chapters for: {manga.Title}");
                var chapters = await _mangaDexService.GetFirstAndLatestChaptersAsync(mangaDexId);
                manga.Chapters = chapters;
                Console.WriteLine($"✅ Loaded {chapters.Count} chapters for {manga.Title}");

                // Save to database
                _context.Comics.Add(manga);
                await _context.SaveChangesAsync();

                return Ok(new
                {
                    message = $"✅ Successfully imported '{manga.Title}' with {chapters.Count} chapters",
                    comic = manga,
                    coverUrl = manga.CoverImageUrl,
                    chaptersCount = chapters.Count
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    error = "Failed to import manga",
                    details = ex.Message
                });
            }
        }


        [HttpPost("import-by-title")]
public async Task<IActionResult> ImportByTitle([FromQuery] string title)
{
    try
    {
        if (string.IsNullOrEmpty(title))
            return BadRequest("Title is required");

        var results = await _mangaDexService.SearchMangaAsync(title);
        if (!results.Any())
            return NotFound($"No manga found with title '{title}'");

        var importedComics = new List<Comic>();

        foreach (var manga in results.Take(3))
        {
            // Check if already exists
            if (_context.Comics.Any(c => c.MangaDexId == manga.MangaDexId))
                continue;

            // Get cover image
            var coverFilename = await _mangaDexService.GetCoverFilenameAsync(manga.MangaDexId);
            if (!string.IsNullOrEmpty(coverFilename))
            {
                manga.CoverImageUrl = $"https://uploads.mangadex.org/covers/{manga.MangaDexId}/{coverFilename}";
                Console.WriteLine($"✅ Cover URL set for {manga.Title}: {manga.CoverImageUrl}");
            }

            // ✅ FIXED: Fetch chapters before saving
            Console.WriteLine($"🔄 Fetching chapters for: {manga.Title}");
            var chapters = await _mangaDexService.GetFirstAndLatestChaptersAsync(manga.MangaDexId);
            manga.Chapters = chapters;
            Console.WriteLine($"✅ Loaded {chapters.Count} chapters for {manga.Title}");

            _context.Comics.Add(manga);
            importedComics.Add(manga);
        }

        if (importedComics.Any())
        {
            await _context.SaveChangesAsync();
            return Ok(new
            {
                message = $"✅ Imported {importedComics.Count} manga with chapters",
                comics = importedComics.Select(c => new {
                    title = c.Title,
                    chaptersCount = c.Chapters?.Count ?? 0,
                    coverUrl = c.CoverImageUrl
                })
            });
        }
        else
        {
            return Conflict(new
            {
                message = "All searched manga already exist in database",
                searchedTitles = results.Select(r => r.Title)
            });
        }
    }
    catch (Exception ex)
    {
        return StatusCode(500, new
        {
            error = "Failed to import manga",
            details = ex.InnerException?.Message ?? ex.Message,
        });
    }
}
        [HttpGet("all-comics")]
        public IActionResult GetAllComics()
        {
            var comics = _context.Comics.ToList();
            return Ok(comics);
        }
        [HttpGet("manga/{mangaDexId}/chapters/first-and-latest")]
        public async Task<IActionResult> GetFirstAndLatestChapters(string mangaDexId)
        {
            try
            {
                Console.WriteLine($"🔍 Getting first and latest chapters for: {mangaDexId}");

                var firstChapter = await _mangaDexService.GetFirstChapterAsync(mangaDexId);
                var latestChapter = await _mangaDexService.GetLatestChapterAsync(mangaDexId);

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

                return Ok(result);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ Error getting first and latest chapters: {ex.Message}");
                return BadRequest($"Error: {ex.Message}");
            }
        }


        [HttpGet("manga/{mangaDexId}/chapters")]
        public async Task<ActionResult<List<Chapter>>> GetChapters(string mangaDexId, [FromQuery] int limit = 100)
        {
            try
            {
                Console.WriteLine($"=== BACKEND: GetChapters called ===");
                Console.WriteLine($"MangaDex ID: {mangaDexId}");

                var chapters = await _mangaDexService.GetChaptersAsync(mangaDexId, limit);

                Console.WriteLine($"=== BACKEND: Returning chapters ===");
                Console.WriteLine($"Total chapters: {chapters.Count}");
                foreach (var chapter in chapters.Take(5))
                {
                    Console.WriteLine($"  Chapter {chapter.ChapterNumber}: {chapter.Title}");
                    Console.WriteLine($"    ID: {chapter.ChapterId}");
                    Console.WriteLine($"    Group: {chapter.GroupName}");
                }
                if (chapters.Count > 5)
                {
                    Console.WriteLine($"  ... and {chapters.Count - 5} more chapters");
                }

                return Ok(chapters);
            }
            catch (Exception ex)
            {
                Console.WriteLine($"❌ BACKEND: Error in GetChapters: {ex.Message}");
                return BadRequest($"Error getting chapters: {ex.Message}");
            }
        }



        [HttpGet("chapters/{chapterId}/pages")]
        public async Task<IActionResult> GetChapterPages(string chapterId)
        {
            try
            {
                var chapter = await _mangaDexService.GetChapterPagesAsync(chapterId);
                if (chapter == null)
                    return NotFound("Chapter not found");

                return Ok(chapter);
            }
            catch (Exception ex)
            {
                return BadRequest($"Error getting chapter pages: {ex.Message}");
            }
        }

        // In MangaDexController.cs
[HttpGet("manga/{mangaDexId}/chapters/list")]
public async Task<IActionResult> GetChapterList(string mangaDexId, [FromQuery] int limit = 500)
{
    try
    {
        Console.WriteLine($"🔍 Getting chapter list for: {mangaDexId}");
        var chapters = await _mangaDexService.GetChapterListAsync(mangaDexId, limit);
        return Ok(chapters);
    }
    catch (Exception ex)
    {
        Console.WriteLine($"❌ Error getting chapter list: {ex.Message}");
        return BadRequest($"Error: {ex.Message}");
    }
}

        [HttpDelete("delete/{id}")]
        public async Task<IActionResult> DeleteComicById(int id)
        {
            try
            {
                // Find the comic by Id
                var comic = await _context.Comics.FindAsync(id);
                if (comic == null)
                {
                    return NotFound(new { message = $"Comic with Id {id} not found" });
                }

                // Remove the comic
                _context.Comics.Remove(comic);
                await _context.SaveChangesAsync();

                return Ok(new
                {
                    message = $"✅ Comic '{comic.Title}' deleted successfully",
                    deletedComicId = id
                });
            }
            catch (Exception ex)
            {
                return StatusCode(500, new
                {
                    error = "Failed to delete comic",
                    details = ex.Message
                });
            }

        }

[HttpGet("debug-comics-with-chapters")]
public IActionResult DebugComicsWithChapters()
{
    var comics = _context.Comics
        .Include(c => c.Chapters) // Make sure to include chapters
        .ToList();
    
    var result = comics.Select(c => new {
        id = c.Id,
        title = c.Title,
        mangaDexId = c.MangaDexId,
        chaptersCount = c.Chapters.Count,
        chapters = c.Chapters.Select(ch => new { 
            chapterId = ch.ChapterId, 
            number = ch.ChapterNumber 
        })
    });
    
    return Ok(result);
}

        // [HttpGet("trending")]
        // public async Task<IActionResult> GetTrendingManga([FromQuery] int limit = 20)
        // {
        //     try
        //     {
        //         var trendingManga = await _mangaDexService.GetTrendingMangaAsync(limit);
        //         return Ok(trendingManga);
        //     }
        //     catch (Exception ex)
        //     {
        //         return BadRequest($"Error getting trending manga: {ex.Message}");
        //     }
        // }

        // [HttpGet("recently-updated")]
        // public async Task<IActionResult> GetRecentlyUpdatedManga([FromQuery] int limit = 20)
        // {
        //     try
        //     {
        //         var updatedManga = await _mangaDexService.GetRecentlyUpdatedMangaAsync(limit);
        //         return Ok(updatedManga);
        //     }
        //     catch (Exception ex)
        //     {
        //         return BadRequest($"Error getting recently updated manga: {ex.Message}");
        //     }
        // }

        // [HttpGet("new")]
        // public async Task<IActionResult> GetNewManga([FromQuery] int limit = 20)
        // {
        //     try
        //     {
        //         var newManga = await _mangaDexService.GetNewMangaAsync(limit);
        //         return Ok(newManga);
        //     }
        //     catch (Exception ex)
        //     {
        //         return BadRequest($"Error getting new manga: {ex.Message}");
        //     }
        // }

        // Helper function
        private bool IsMostlyEnglish(string text)
        {
            int englishCount = text.Count(c => (c >= 'a' && c <= 'z') || (c >= 'A' && c <= 'Z') || char.IsWhiteSpace(c) || char.IsPunctuation(c));
            double ratio = (double)englishCount / text.Length;
            return ratio > 0.7; // consider it English if >70% characters are English
        }



    }




}
