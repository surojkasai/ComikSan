// using Microsoft.AspNetCore.Mvc;
// using ComikSanBackend.Data;
// using ComikSanBackend.Models;

// namespace ComikSanBackend.Controllers;
//     [ApiController]
//     [Route("api/[controller]")]
//     public class ChaptersControl : ControllerBase
//     {
//         private readonly ComikSanDbContext _context;

//         public ChaptersControl(ComikSanDbContext context)
//         {
//             _context = context;
//         }

//     // Get chapters for a comic
//     [HttpGet("comic/{comicId}")]
//         //  [HttpGet("/")]
//         public IActionResult GetChaptersForComic(int comicId)
//     {
//         var chapters = _context.Chapters.Where(c => c.ComicId == comicId).ToList();
//         return Ok(chapters);
//     }

//         // Add a new chapter
//         [HttpPost]
//         public IActionResult AddChapter([FromBody] Chapter chapter)
//         {
//             _context.Chapters.Add(chapter);
//             _context.SaveChanges();
//             return Ok(chapter);
//         }
//     }

