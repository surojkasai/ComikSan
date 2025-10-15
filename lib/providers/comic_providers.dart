import 'package:comiksan/model/comic.dart';
import 'package:comiksan/services/search_service.dart';
import 'package:flutter/foundation.dart';
import '../services/api_service.dart';

class ComicProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Comic> _comics = [];
  List<Comic> _searchResults = [];
  bool _isLoading = false;
  String _error = '';

  List<Comic> get comics => _comics;
  List<Comic> get searchResults => _searchResults;
  bool get isLoading => _isLoading;
  String get error => _error;

  Future<void> loadComics() async {
    _isLoading = true;
    _error = '';
    notifyListeners();

    try {
      _comics = await _apiService.getComics();
      _error = '';
    } catch (e) {
      _error = e.toString();
      _comics = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<Chapter>> loadChapters(String mangaDexId) async {
    try {
      print('🔄 ComicProvider: Loading chapters for manga: $mangaDexId');
      final chapters = await _apiService.getChapters(mangaDexId);

      // ✅ PRINT CHAPTERS IN PROVIDER
      print('=== ComicProvider: Chapters loaded ===');
      print('MangaDex ID: $mangaDexId');
      print('Total chapters: ${chapters.length}');
      for (var chapter in chapters.take(5)) {
        print('  Chapter ${chapter.chapterNumber}: ${chapter.title}');
        print('    ID: ${chapter.chapterId}');
        print('    Group: ${chapter.groupName}');
      }
      if (chapters.length > 5) {
        print('    ... and ${chapters.length - 5} more chapters');
      }
      print('');

      return chapters;
    } catch (e) {
      print('❌ ComicProvider: Error loading chapters: $e');
      return [];
    }
  }

  Future<void> searchManga(String query) async {
    if (query.isEmpty) {
      _searchResults = [];
      notifyListeners();
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _searchResults = await SearchService.searchManga(query);
      _error = '';
    } catch (e) {
      _error = e.toString();
      _searchResults = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> importManga(String mangaDexId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _apiService.importMangaByTitle(mangaDexId);
      // Reload comics after import
      await loadComics();
      _error = '';
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _apiService.dispose();
    super.dispose();
  }
}
