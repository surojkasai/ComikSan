using ComikSanBackend.Data;
using Microsoft.EntityFrameworkCore;
using StackExchange.Redis;
using ComikSanBackend.Services;
var builder = WebApplication.CreateBuilder(args);

// Add services
builder.Services.AddControllers();
builder.Services.AddEndpointsApiExplorer();
builder.Services.AddSwaggerGen();
builder.Services.AddLogging();

// Database
builder.Services.AddDbContext<ComikSanDbContext>(options =>
    options.UseSqlite(builder.Configuration.GetConnectionString("DefaultConnection")));

// CORS
builder.Services.AddCors(options =>
{
    options.AddPolicy("AllowAll", policy =>
    {
        policy.AllowAnyOrigin()
        .AllowAnyHeader()
        .AllowAnyMethod();
    });
});

// Add MangaDex service
builder.Services.AddHttpClient<MangaDexService>();
var app = builder.Build();

if (app.Environment.IsDevelopment())
{
    app.UseSwagger();
    app.UseSwaggerUI();
}

app.UseRouting();
app.UseCors("AllowAll");
// app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();


app.Urls.Add("http://10.182.149.171:5055");
//to test a specific endpoint
// app.MapGet("/", () => "ComikSan Backend API is running!");
app.Run();



