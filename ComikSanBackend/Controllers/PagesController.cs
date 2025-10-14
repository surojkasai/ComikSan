// using Microsoft.AspNetCore.Mvc;
// using ComikSanBackend.Data;
// using ComikSanBackend.Models;

// namespace ComikSanBackend.Controllers;

//     [ApiController]
//     [Route("api/[controller]")]
//     public class PagesController : ControllerBase
//     {
//         private readonly ComikSanDbContext _context;

//         public PagesController(ComikSanDbContext context)
//         {
//             _context = context;
//         }

//     // Get pages for a chapter
//     [HttpGet("chapter/{chapterId}")]
//         //  [HttpGet("/")]
//         public IActionResult GetPagesForChapter(int chapterId)
//     {
//         var pages = _context.Pages.Where(p => p.ChapterId == chapterId).ToList();
//         return Ok(pages);
//     }

//         // Add a new page
//         [HttpPost]
//         public IActionResult AddPage([FromBody] Page page)
//         {
//             _context.Pages.Add(page);
//             _context.SaveChanges();
//             return Ok(page);
//         }
//     }

