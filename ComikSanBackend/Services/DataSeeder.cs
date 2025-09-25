// using ComikSanBackend.Data;
// using ComikSanBackend.Models;
// using Microsoft.EntityFrameworkCore;

// namespace ComikSanBackend.Services
// {
//     public class DataSeeder
//     {
//         private readonly ComikSanDbContext _context;
//         private readonly ILogger<DataSeeder> _logger;

//         public DataSeeder(ComikSanDbContext context, ILogger<DataSeeder> logger)
//         {
//             _context = context;
//             _logger = logger;
//         }

//         public void SeedData()
//         {
//             try
//             {
//                 _logger.LogInformation("🔍 Checking if database needs seeding...");
                
//                 // Check if database is accessible
//                 var canConnect = _context.Database.CanConnect();
//                 _logger.LogInformation($"Database can connect: {canConnect}");
                
//                 if (!canConnect)
//                 {
//                     _logger.LogError("Cannot connect to database!");
//                     return;
//                 }

//                 // Check if we already have comics
//                 var existingComics = _context.Comics.Count();
//                 _logger.LogInformation($"Found {existingComics} existing comics");
                
//                 if (existingComics > 0)
//                 {
//                     _logger.LogInformation("⏩ Database already has data, skipping seed");
//                     return;
//                 }

//                 _logger.LogInformation("🌱 Seeding sample data...");

//                 var comic = new Comic
//                 {
//                     Title = "One Piece",
//                     Author = "Eiichiro Oda",
//                     Genre = "Adventure, Fantasy",
//                     FollowerCount = 5000000
//                 };

//                 var chapter = new Chapter
//                 {
//                     Title = "Chapter 1: Romance Dawn",
//                     Comic = comic,
//                     Pages = new List<Page>
//                     {
//                         new Page { ImageUrl = "/images/one-piece-1-1.jpg" },
//                         new Page { ImageUrl = "/images/one-piece-1-2.jpg" },
//                         new Page { ImageUrl = "/images/one-piece-1-3.jpg" }
//                     }
//                 };

//                 _context.Comics.Add(comic);
//                 _context.Chapters.Add(chapter);
//                 _context.SaveChanges();
                
//                 _logger.LogInformation("✅ Sample data seeded successfully!");
//             }
//             catch (Exception ex)
//             {
//                 _logger.LogError(ex, "❌ Error seeding data: {Message}", ex.Message);
//             }
//         }
//     }
// }