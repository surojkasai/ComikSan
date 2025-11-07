
namespace ComikSanBackend.Models
{
    public class Chapter
    {
        public int Id { get; set; }
        public string ChapterId { get; set; } // MangaDex chapter ID
        public string Title { get; set; }
        public string ChapterNumber { get; set; }
        public string? GroupName { get; set; }
        public string Volume { get; set; }
        public List<Page> Pages { get; set; }
        public DateTime? PublishedAt { get; set; }

        // Foreign key
        public int ComicId { get; set; }
        public Comic Comic { get; set; }
        
         public Chapter()
    {
        ChapterId = string.Empty;
        Title = string.Empty;
        ChapterNumber = string.Empty;
        GroupName = "Unknown Group";
        Volume = string.Empty;
        Pages = new List<Page>();
    }
    }
}