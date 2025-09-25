namespace ComikSanBackend.Models;
public class Page
{
    public int Id { get; set; }
    public string ImageUrl { get; set; }
    public int ChapterId { get; set; }
    public Chapter Chapter { get; set; }
}
