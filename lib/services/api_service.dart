import 'dart:convert';
import 'package:comiksan/config/environment.dart';
import 'package:comiksan/model/comic.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // static const String baseUrl = 'http://10.0.2.2:5055/api'; // For Android emulator
  static const String baseUrl = 'http://10.20.86.114:5055/api';
  final http.Client client = http.Client();
  // static const String baseUrl = 'http://192.168.101.17/api';
  // static const String baseUrl = 'http://localhost:5055/api'; // For iOS simulator
  // static const String baseUrl = 'http://192.168.1.XXX:5055/api'; // For physical device

  Future<List<Comic>> getComics() async {
    try {
      final url = Uri.parse('$baseUrl/MangaDex/all-comics');
      print('🔍 Attempting to call: $url');
      print('🔍 Full URL breakdown:');
      print('   - Scheme: ${url.scheme}');
      print('   - Host: ${url.host}');
      print('   - Port: ${url.port}');
      print('   - Path: ${url.path}');

      final response = await client.get(url, headers: {'Content-Type': 'application/json'});

      print('🔍 Response status: ${response.statusCode}');
      print('🔍 Response body: ${response.body}');

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Comic.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load comics: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error details: $e');
      throw Exception('Failed to load comics: $e');
    }
  }

  Future<List<Chapter>> getChapters(String mangaDexId, {int limit = 100}) async {
    try {
      print('🔄 ApiService: Fetching chapters for $mangaDexId');

      final response = await client.get(
        Uri.parse('$baseUrl/mangadex/manga/$mangaDexId/chapters?limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final chapters = jsonList.map((json) => Chapter.fromJson(json)).toList();

        print('✅ ApiService: Successfully loaded ${chapters.length} chapters');
        return chapters;
      } else {
        print('❌ ApiService: Failed to load chapters: ${response.statusCode}');
        throw Exception('Failed to load chapters: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ApiService: Error loading chapters: $e');
      throw Exception('Failed to load chapters: $e');
    }
  }

  Future<Chapter> getChapterPages(String chapterId) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/mangadex/chapters/$chapterId/pages'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return Chapter.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to load chapter pages: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to load chapter pages: $e');
    }
  }

  // In api_service.dart - Add this method
  Future<ImportResult> importMangaByTitle(String title) async {
    try {
      print('🔄 ApiService: Importing manga by title: $title');

      final response = await client.post(
        Uri.parse('$baseUrl/mangadex/import-by-title?title=${Uri.encodeQueryComponent(title)}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        print('✅ Import successful: ${jsonResponse['message']}');
        return ImportResult.fromJson(jsonResponse);
      } else if (response.statusCode == 409) {
        // Already exists - treat as success for user experience
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return ImportResult.fromJson(jsonResponse);
      } else {
        throw Exception('Failed to import manga: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ ApiService: Import error: $e');
      throw Exception('Failed to import manga: $e');
    }
  }

  // Future<List<Comic>> getTrendingManga({int limit = 5}) async {
  //   try {
  //     final response = await http.get(Uri.parse('$baseUrl/api/MangaDex/trending?limit=$limit'));

  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = json.decode(response.body);
  //       return data.map((item) => Comic.fromJson(item)).toList();
  //     } else {
  //       throw Exception('Failed to load trending manga: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error getting trending manga: $e');
  //     rethrow;
  //   }
  // }

  // Future<List<Comic>> getRecentlyUpdatedManga({int limit = 5}) async {
  //   try {
  //     final response = await http.get(
  //       Uri.parse('$baseUrl/api/MangaDex/recently-updated?limit=$limit'),
  //     );

  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = json.decode(response.body);
  //       return data.map((item) => Comic.fromJson(item)).toList();
  //     } else {
  //       throw Exception('Failed to load recently updated manga: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error getting recently updated manga: $e');
  //     rethrow;
  //   }
  // }

  // Future<List<Comic>> getNewManga({int limit = 5}) async {
  //   try {
  //     final response = await http.get(Uri.parse('$baseUrl/api/MangaDex/new?limit=$limit'));

  //     if (response.statusCode == 200) {
  //       final List<dynamic> data = json.decode(response.body);
  //       return data.map((item) => Comic.fromJson(item)).toList();
  //     } else {
  //       throw Exception('Failed to load new manga: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     print('Error getting new manga: $e');
  //     rethrow;
  //   }
  // }

  void dispose() {
    client.close();
  }
}
