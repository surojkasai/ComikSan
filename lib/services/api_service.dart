import 'dart:convert';
import 'package:comiksan/config/environment.dart';
import 'package:comiksan/model/chapter.dart';
import 'package:comiksan/model/comic.dart';
import 'package:comiksan/model/import.dart';
import 'package:http/http.dart' as http;

class ApiService {
  // static const String baseUrl = 'http://10.0.2.2:5055/api'; // For Android emulator
  static const String baseUrl = Environment.baseUrl;
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

  // In api_service.dart - Add these methods
  Future<List<Chapter>> getChapterList(String mangaDexId, {int limit = 500}) async {
    try {
      print('🔄 ApiService: Getting chapter list for: $mangaDexId');

      final response = await client.get(
        Uri.parse('$baseUrl/mangadex/manga/$mangaDexId/chapters/list?limit=$limit'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final chapters = jsonList.map((json) => Chapter.fromJson(json)).toList();

        print('✅ Chapter list loaded: ${chapters.length} chapters');
        return chapters;
      } else {
        throw Exception('Failed to load chapter list: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error loading chapter list: $e');
      rethrow;
    }
  }

  // Keep your existing method for loading pages
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

  // In api_service.dart - Replace the findChapterByNumber method
  Future<Chapter?> findChapterByNumber(String mangaDexId, String chapterNumber) async {
    try {
      print('🔄 ApiService: Searching for chapter $chapterNumber in manga $mangaDexId');

      final response = await client.get(
        Uri.parse(
          '$baseUrl/mangadex/manga/$mangaDexId/chapters?limit=200',
        ), // Get more chapters to search through
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final chapters = jsonList.map((json) => Chapter.fromJson(json)).toList();

        print('✅ Found ${chapters.length} chapters, searching for chapter $chapterNumber');

        // Search for the chapter by number
        for (var chapter in chapters) {
          // Try exact match first
          if (chapter.chapterNumber == chapterNumber) {
            print('✅ Found exact match: Chapter ${chapter.chapterNumber}');
            return chapter;
          }

          // Try numeric comparison (handles decimal formatting differences)
          final inputNum = double.tryParse(chapterNumber);
          final chapterNum = double.tryParse(chapter.chapterNumber);
          if (inputNum != null && chapterNum != null && inputNum == chapterNum) {
            print('✅ Found numeric match: Chapter ${chapter.chapterNumber}');
            return chapter;
          }
        }

        // If no exact match, try fuzzy search
        for (var chapter in chapters) {
          if (chapter.chapterNumber.contains(chapterNumber) ||
              chapterNumber.contains(chapter.chapterNumber)) {
            print('✅ Found fuzzy match: Chapter ${chapter.chapterNumber}');
            return chapter;
          }
        }

        print('❌ No chapter found with number: $chapterNumber');
        return null;
      } else {
        print('❌ Failed to load chapters: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('❌ Error searching chapter: $e');
      return null;
    }
  }

  // Add this to your ApiService class
  Future<List<Chapter>> getFirstAndLatestChapters(String mangaDexId) async {
    try {
      print('🔄 ApiService: Getting first and latest chapters for: $mangaDexId');

      final response = await client.get(
        Uri.parse('$baseUrl/mangadex/manga/$mangaDexId/chapters/first-and-latest'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        final chapters = jsonList.map((json) => Chapter.fromJson(json)).toList();

        print('✅ First and latest chapters loaded: ${chapters.length}');
        for (var chapter in chapters) {
          print('   - Chapter ${chapter.chapterNumber}: ${chapter.title}');
        }
        return chapters;
      } else {
        throw Exception('Failed to load first and latest chapters: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error loading first and latest chapters: $e');
      rethrow;
    }
  }

  void dispose() {
    client.close();
  }
}
