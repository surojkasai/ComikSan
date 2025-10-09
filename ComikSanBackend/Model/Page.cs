namespace ComikSanBackend.Models;

public class Page
{
    public int Id { get; set; }
    public string ImageUrl { get; set; }
    public int PageNumber { get; set; }
    public int ChapterId { get; set; }
    public int Width { get; set; }
    public int Height { get; set; }
    public Chapter Chapter { get; set; }
    
    
     public Page()
    {
        ImageUrl = string.Empty;
    }
}
