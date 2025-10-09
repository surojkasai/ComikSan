using System.ComponentModel.DataAnnotations;

namespace ComikSanBackend.Models
{
    public class Comic
    {
        public int Id { get; set; }

        [Required]
        public string Title { get; set; }

        public string Author { get; set; }

        public string Genre { get; set; }

        public int FollowerCount { get; set; }

        // ✅ Initialize to avoid null during POST

        //mangadex fields
        public string? MangaDexId { get; set; }
        public string? Description { get; set; }
        public string? CoverImageUrl { get; set; }
        public DateTime? LastSynced { get; set; }

        public List<Chapter> Chapters { get; set; } = new List<Chapter>();


 public Comic()
    {
        Title = string.Empty;
        Author = string.Empty;
        Genre = string.Empty;
        Chapters = new List<Chapter>();
    }
    }
}
