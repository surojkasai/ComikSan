using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Mvc.Filters;
using Microsoft.AspNetCore.Mvc;
using ComikSanBackend.Data;     // for ComikSanDbContext
using ComikSanBackend.Models;   // for Comic

namespace ComikSanBackend.Controllers;

[ApiController]
[Route("api/[controller]")]
public class ComicsController : ControllerBase
{
    private readonly ComikSanDbContext _context;

    public ComicsController(ComikSanDbContext context)
    {
        _context = context;
    }

    // [HttpGet("/")]
    [HttpGet]
    public IActionResult GetAllComics()
    {
        return Ok(_context.Comics.ToList());
    }

    [HttpPost]
    public IActionResult AddComic([FromBody] Comic comic)
    {
        _context.Comics.Add(comic);
        _context.SaveChanges();
        return Ok(comic);
    }
}
