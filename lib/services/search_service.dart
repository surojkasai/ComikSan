import 'dart:convert';
import 'package:comiksan/config/environment.dart';
import 'package:comiksan/model/comic.dart';
import 'package:http/http.dart' as http;
import 'package:comiksan/model/import.dart';

class SearchService {
  static const String baseUrl = Environment.baseUrl; // Your backend URL

  static Future<List<Comic>> searchManga(String query) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/MangaDex/search?title=$query'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        return data.map((item) => Comic.fromJson(item)).toList();
      } else {
        throw Exception('Failed to search manga: ${response.statusCode}');
      }
    } catch (e) {
      print('Search error: $e');
      rethrow;
    }
  }
}
