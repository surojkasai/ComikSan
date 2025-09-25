using Microsoft.AspNetCore.Mvc;

namespace ComikSanBackend.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class HealthController : ControllerBase
    {
        [HttpGet]
        public IActionResult Get()
        {
            return Ok(new { 
                status = "Healthy",
                message = "Health controller is working!",
                timestamp = DateTime.Now
            });
        }
    }
}