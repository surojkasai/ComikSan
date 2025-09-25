using Microsoft.EntityFrameworkCore;
using ComikSanBackend .Models;

namespace ComikSanBackend.Data;

public class ComikSanDbContext : DbContext
{
    public ComikSanDbContext(DbContextOptions<ComikSanDbContext> options) : base(options) { }

    public DbSet<Comic> Comics { get; set; }
    public DbSet<Chapter> Chapters { get; set; }
    public DbSet<Page> Pages { get; set; }

}
