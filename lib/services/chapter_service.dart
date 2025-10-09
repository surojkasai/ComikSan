// lib/services/chapter_service.dart
import 'package:comiksan/model/comic.dart' as comic_model;

class ChapterService {
  static final ChapterService _instance = ChapterService._internal();
  factory ChapterService() => _instance;
  ChapterService._internal();

  // Cache for loaded chapters
  final Map<String, comic_model.Chapter> _chapterCache = {};

  // Track current chapter and its neighbors
  String? _currentChapterId;
  String? _previousChapterId;
  String? _nextChapterId;

  comic_model.Chapter? get currentChapter =>
      _currentChapterId != null ? _chapterCache[_currentChapterId] : null;
  comic_model.Chapter? get previousChapter =>
      _previousChapterId != null ? _chapterCache[_previousChapterId] : null;
  comic_model.Chapter? get nextChapter =>
      _nextChapterId != null ? _chapterCache[_nextChapterId] : null;

  // Method to load a chapter and its neighbors
  Future<void> loadChapterWithNeighbors(
    String chapterId,
    Future<comic_model.Chapter> Function(String) fetchChapter,
    Future<List<comic_model.Chapter>> Function() fetchChapterList,
  ) async {
    try {
      // Get the chapter list to find neighbors
      final chapters = await fetchChapterList();
      final currentIndex = chapters.indexWhere((ch) => ch.chapterId == chapterId);

      if (currentIndex == -1) {
        throw Exception('Chapter not found in list');
      }

      // Update neighbor tracking
      _currentChapterId = chapterId;
      _previousChapterId = currentIndex > 0 ? chapters[currentIndex - 1].chapterId : null;
      _nextChapterId =
          currentIndex < chapters.length - 1 ? chapters[currentIndex + 1].chapterId : null;

      // Load current chapter if not cached
      if (!_chapterCache.containsKey(chapterId)) {
        _chapterCache[chapterId] = await fetchChapter(chapterId);
      }

      // Pre-load neighbors in background
      _preloadNeighbors(fetchChapter);
    } catch (e) {
      print('Error loading chapter with neighbors: $e');
      rethrow;
    }
  }

  Future<void> _preloadNeighbors(Future<comic_model.Chapter> Function(String) fetchChapter) async {
    try {
      // Pre-load previous chapter
      if (_previousChapterId != null && !_chapterCache.containsKey(_previousChapterId)) {
        fetchChapter(_previousChapterId!)
            .then((chapter) {
              _chapterCache[_previousChapterId!] = chapter;
              print('✅ Pre-loaded previous chapter: ${chapter.title}');
            })
            .catchError((e) {
              print('❌ Failed to pre-load previous chapter: $e');
            });
      }

      // Pre-load next chapter
      if (_nextChapterId != null && !_chapterCache.containsKey(_nextChapterId)) {
        fetchChapter(_nextChapterId!)
            .then((chapter) {
              _chapterCache[_nextChapterId!] = chapter;
              print('✅ Pre-loaded next chapter: ${chapter.title}');
            })
            .catchError((e) {
              print('❌ Failed to pre-load next chapter: $e');
            });
      }
    } catch (e) {
      print('Error in preloading neighbors: $e');
    }
  }

  // Clear cache if needed
  void clearCache() {
    _chapterCache.clear();
    _currentChapterId = null;
    _previousChapterId = null;
    _nextChapterId = null;
  }
}
