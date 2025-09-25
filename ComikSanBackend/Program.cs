using ComikSanBackend.Data;
using Microsoft.EntityFrameworkCore;
using ComikSanBackend.Services;
var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();

// Database
builder.Services.AddDbContext<ComikSanDbContext>(options =>
    options.UseSqlite(builder.Configuration.GetConnectionString("DefaultConnection")));

// CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
       // policy.WithOrigins("http://localhost:5055", "https://localhost:5055")
              policy.AllowAnyOrigin()
              .AllowAnyHeader()
              .AllowAnyMethod();
    });
});

// Register DataSeeder
// builder.Services.AddScoped<DataSeeder>();

// Use CORS
// app.UseCors("AllowFlutter");

// Add MangaDex service
builder.Services.AddHttpClient<MangaDexService>();
var app = builder.Build();
// using (var scope = app.Services.CreateScope())
// {
//     var seeder = scope.ServiceProvider.GetRequiredService<DataSeeder>();
//     seeder.SeedData();
// }


if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

// app.UseHttpsRedirection();
app.UseCors("AllowAll");
app.UseRouting();
app.MapControllers();

//force for now
app.Urls.Add("http://localhost:5055");
//to test a specific endpoint
// app.MapGet("/", () => "ComikSan Backend API is running!");
app.Run();