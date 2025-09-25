
namespace ComikSanBackend.Models
{

    public class Chapter
    {
        public int Id { get; set; }
        public string Title { get; set; }
        public int ComicId { get; set; }
        public Comic Comic { get; set; }
        public List<Page> Pages { get; set; }

    }
}