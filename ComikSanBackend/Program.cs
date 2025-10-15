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
        // policy.WithOrigins("http://localhost:5055", "https://localhost:5055")
        policy.AllowAnyOrigin()
        .AllowAnyHeader()
        .AllowAnyMethod();
    });
});

// Add Redis
// builder.Services.AddStackExchangeRedisCache(options =>
// {
//     options.Configuration = builder.Configuration.GetConnectionString("Redis");
// });

// Add this for the simple test
// builder.Services.AddSingleton<IConnectionMultiplexer>(sp => 
//     ConnectionMultiplexer.Connect(builder.Configuration.GetConnectionString("Redis")));

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

app.UseRouting();
app.UseCors("AllowAll");
// app.UseHttpsRedirection();
app.UseAuthorization();
app.MapControllers();

//force for now
// app.Urls.Add("http://localhost:5055");
// app.Urls.Add("http://192.168.101.12:5055");
app.Urls.Add("http://10.20.86.114:5055");
//to test a specific endpoint
// app.MapGet("/", () => "ComikSan Backend API is running!");
app.Run();

// using ComikSanBackend.Data;
// using Microsoft.EntityFrameworkCore;
// using ComikSanBackend.Services;
// using StackExchange.Redis; 

// var builder = WebApplication.CreateBuilder(args);

// // Add services
// builder.Services.AddControllers();
// builder.Services.AddEndpointsApiExplorer();
// builder.Services.AddSwaggerGen();

// // Database
// builder.Services.AddDbContext<ComikSanDbContext>(options =>
//     options.UseSqlite(builder.Configuration.GetConnectionString("DefaultConnection")));

// // CORS
// builder.Services.AddCors(options =>
// {
//     options.AddPolicy("AllowAll", policy =>
//     {
//         policy.AllowAnyOrigin()
//               .AllowAnyHeader()
//               .AllowAnyMethod();
//     });
// });

// // Add Redis (after your other services)
// builder.Services.AddStackExchangeRedisCache(options =>
// {
//     options.Configuration = builder.Configuration.GetConnectionString("Redis");
// });

// // Add this for the simple test
// builder.Services.AddSingleton<IConnectionMultiplexer>(sp => 
//     ConnectionMultiplexer.Connect(builder.Configuration.GetConnectionString("Redis")));

// // Add MangaDex service
// builder.Services.AddHttpClient<MangaDexService>();

// var app = builder.Build();

// if (app.Environment.IsDevelopment())
// {
//     app.UseSwagger();
//     app.UseSwaggerUI();
// }

// app.UseCors("AllowAll");
// app.UseAuthorization();
// app.UseRouting();
// app.MapControllers();

// app.Urls.Add("http://localhost:5055");
// app.Run();