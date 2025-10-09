import 'dart:convert';
import 'package:comiksan/config/environment.dart';
import 'package:comiksan/model/comic.dart';
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
      final url = Uri.parse('$baseUrl/comics');
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

  Future<List<Comic>> searchManga(String title) async {
    try {
      final response = await client.get(
        Uri.parse('$baseUrl/mangadex/search?title=${Uri.encodeQueryComponent(title)}'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> jsonList = json.decode(response.body);
        return jsonList.map((json) => Comic.fromJson(json)).toList();
      } else {
        throw Exception('Failed to search manga: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to search manga: $e');
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

  Future<Comic> importManga(String mangaDexId) async {
    try {
      final response = await client.post(
        Uri.parse('$baseUrl/mangadex/import/$mangaDexId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200 || response.statusCode == 409) {
        final Map<String, dynamic> jsonResponse = json.decode(response.body);
        return Comic.fromJson(jsonResponse['comic']);
      } else {
        throw Exception('Failed to import manga: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to import manga: $e');
    }
  }

  void dispose() {
    client.close();
  }
}
