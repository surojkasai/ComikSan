// using StackExchange.Redis;
// using System.Text.Json;

// namespace ComikSanBackend.Services
// {
//     public class RedisCacheService : IRedisCacheService
//     {
//         private readonly IConnectionMultiplexer _redis;
//         private readonly IDatabase _database;
//         private readonly ILogger<RedisCacheService> _logger;

//         public RedisCacheService(IConnectionMultiplexer redis, ILogger<RedisCacheService> logger)
//         {
//             _redis = redis;
//             _database = redis.GetDatabase();
//             _logger = logger;
//         }

//         public async Task<T?> GetAsync<T>(string key)
//         {
//             try
//             {
//                 var value = await _database.StringGetAsync(key);
//                 if (value.HasValue)
//                 {
//                     _logger.LogInformation($"Redis cache HIT for key: {key}");
//                     return JsonSerializer.Deserialize<T>(value!);
//                 }
                
//                 _logger.LogInformation($"Redis cache MISS for key: {key}");
//                 return default(T);
//             }
//             catch (Exception ex)
//             {
//                 _logger.LogError(ex, $"Error getting key {key} from Redis");
//                 return default(T);
//             }
//         }

//         public async Task SetAsync<T>(string key, T value, TimeSpan? expiry = null)
//         {
//             try
//             {
//                 var serializedValue = JsonSerializer.Serialize(value);
//                 await _database.StringSetAsync(key, serializedValue, expiry);
//                 _logger.LogInformation($"Redis cache SET for key: {key} with expiry: {expiry}");
//             }
//             catch (Exception ex)
//             {
//                 _logger.LogError(ex, $"Error setting key {key} in Redis");
//             }
//         }

//         public async Task RemoveAsync(string key)
//         {
//             try
//             {
//                 await _database.KeyDeleteAsync(key);
//                 _logger.LogInformation($"Redis cache REMOVE for key: {key}");
//             }
//             catch (Exception ex)
//             {
//                 _logger.LogError(ex, $"Error removing key {key} from Redis");
//             }
//         }

//         public async Task<bool> ExistsAsync(string key)
//         {
//             try
//             {
//                 return await _database.KeyExistsAsync(key);
//             }
//             catch (Exception ex)
//             {
//                 _logger.LogError(ex, $"Error checking existence for key {key} in Redis");
//                 return false;
//             }
//         }

//         public async Task<IEnumerable<string>> GetKeysAsync(string pattern)
//         {
//             try
//             {
//                 var endpoints = _redis.GetEndPoints();
//                 var server = _redis.GetServer(endpoints.First());
//                 var keys = server.Keys(pattern: pattern).Select(k => k.ToString());
//                 return await Task.FromResult(keys);
//             }
//             catch (Exception ex)
//             {
//                 _logger.LogError(ex, $"Error getting keys for pattern {pattern} from Redis");
//                 return Enumerable.Empty<string>();
//             }
//         }

//         public async Task ClearPatternAsync(string pattern)
//         {
//             try
//             {
//                 var keys = await GetKeysAsync(pattern);
//                 foreach (var key in keys)
//                 {
//                     await RemoveAsync(key);
//                 }
//                 _logger.LogInformation($"Cleared Redis cache pattern: {pattern}");
//             }
//             catch (Exception ex)
//             {
//                 _logger.LogError(ex, $"Error clearing pattern {pattern} from Redis");
//             }
//         }
//     }
// }