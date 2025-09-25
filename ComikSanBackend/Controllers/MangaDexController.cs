using Microsoft.AspNetCore.Mvc;
using ComikSanBackend.Services;
using ComikSanBackend.Data;  // Add this using directive
using ComikSanBackend.Models; // Add this using directive

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

        [HttpGet("test")]
        public async Task<IActionResult> TestSearch([FromQuery] string title = "One Piece")
        {
            var results = await _mangaDexService.SearchMangaAsync(title);

            if (results.Any())
            {
                return Ok(new
                {
                    message = $"✅ Found {results.Count} manga!",
                    manga = results
                });
            }
            else
            {
                return Ok(new
                {
                    message = $"❌ No results found for '{title}'",
                    suggestion = "Try a different title like 'Naruto' or 'Attack on Titan'"
                });
            }
        }

        [HttpGet("search")]
        public async Task<IActionResult> SearchManga([FromQuery] string title)
        {
            if (string.IsNullOrEmpty(title))
                return BadRequest("Title is required");

            var results = await _mangaDexService.SearchMangaAsync(title);
            return Ok(results);
        }

        // [HttpGet("raw")]
        // public async Task<IActionResult> GetRawResponse([FromQuery] string title = "One Piece")
        // {
        //     var rawJson = await _mangaDexService.GetRawResponseAsync(title);
        //     return Ok(new { 
        //         searchTitle = title,
        //         rawResponse = rawJson 
        //     });
        // }

        [HttpPost("import/{mangaDexId}")]
        public async Task<IActionResult> ImportManga(string mangaDexId)
        {
            try
            {
                // Search for the specific manga
                var results = await _mangaDexService.SearchMangaAsync(mangaDexId);
                var manga = results.FirstOrDefault(m => m.MangaDexId == mangaDexId);

                if (manga == null)
                    return NotFound($"Manga with ID {mangaDexId} not found");

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

                // Save to database
                _context.Comics.Add(manga);
                await _context.SaveChangesAsync();

                return Ok(new
                {
                    message = $"✅ Successfully imported '{manga.Title}'",
                    comic = manga
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

        // NEW: Import by title (easier to use)
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

                foreach (var manga in results.Take(3)) // Import first 3 results
                {
                    // Check if already exists
                    if (_context.Comics.Any(c => c.MangaDexId == manga.MangaDexId))
                        continue;

                    _context.Comics.Add(manga);
                    importedComics.Add(manga);
                }

                if (importedComics.Any())
                {
                    await _context.SaveChangesAsync();
                    return Ok(new
                    {
                        message = $"✅ Imported {importedComics.Count} manga",
                        comics = importedComics
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
                    details = ex.Message
                });
            }
        }
        
        [HttpGet("all-comics")]
public IActionResult GetAllComics()
{
    var comics = _context.Comics.ToList();
    return Ok(comics);
}

    }
}