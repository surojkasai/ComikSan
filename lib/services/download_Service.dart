import 'dart:io';
import 'package:comiksan/model/chapter.dart';
import 'package:comiksan/model/comic.dart';
import 'package:comiksan/model/page.dart';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:hive/hive.dart';

class DownloadService {
  static final DownloadService _instance = DownloadService._internal();
  factory DownloadService() => _instance;
  DownloadService._internal();
  final Dio _dio = Dio();
  Box<Comic>? _downloadsBox;
  bool _isInitialized = false;

  // Initialize the downloads box
  Future<void> init() async {
    if (_isInitialized) {
      print('✅ DownloadService already initialized');
      return;
    }
    try {
      _downloadsBox = await Hive.openBox<Comic>('downloaded_comics');
      _isInitialized = true;
      print('✅ DownloadService initialized successfully');
      print('📦 Hive box has ${_downloadsBox!.length} entries');
    } catch (e) {
      print('❌ Error initializing DownloadService: $e');
      _isInitialized = false;
    }
  }

  // ✅ ADD: Check if service is ready
  bool get isInitialized => _isInitialized && _downloadsBox != null;

  // ✅ ADD: Safe access to box
  Box<Comic>? get downloadsBox {
    if (!_isInitialized || _downloadsBox == null) {
      print('⚠️ DownloadService not initialized yet');
      return null;
    }
    return _downloadsBox;
  }

  void _debugPrintDownloadState(Comic comic, Chapter chapter) {
    print('=== DOWNLOAD DEBUG INFO ===');
    print('Comic ID: ${comic.id}');
    print('Comic Title: ${comic.title}');
    print('Chapter ID: ${chapter.chapterId}');
    print('Chapter Number: ${chapter.chapterNumber}');
    print('Total Pages: ${chapter.pages.length}');
    print('Pages URLs:');
    for (int i = 0; i < chapter.pages.length; i++) {
      print('  Page ${i + 1}: ${chapter.pages[i].imageUrl}');
    }
    print('==========================');
  }

  void _debugHiveState(Comic comic) {
    print('=== HIVE DEBUG ===');
    print('Comic ID: ${comic.id}');
    print('Comic Title: ${comic.title}');
    print('Total Chapters: ${comic.chapters.length}');
    print('Downloaded Chapters: ${comic.chapters.where((c) => c.isDownloaded).length}');

    for (final chapter in comic.chapters) {
      if (chapter.isDownloaded) {
        print('  - Chapter ${chapter.chapterNumber}: Downloaded (${chapter.pages.length} pages)');
      }
    }
    print('==================');
  }

  Future<DownloadResult> downloadChapter({
    required Comic comic,
    required Chapter chapter,
    required Function(double progress) onProgress,
  }) async {
    // ✅ FIXED: Check if service is ready
    if (!isInitialized) {
      print('❌ DownloadService not initialized');
      return DownloadResult(
        success: false,
        downloadedPages: 0,
        totalPages: chapter.pages.length,
        error: 'Download service not ready',
      );
    }

    try {
      print('🔄 Starting download for chapter: ${chapter.chapterNumber}');

      // Get app documents directory
      final dir = await getApplicationDocumentsDirectory();
      final chapterDir = Directory('${dir.path}/downloads/${comic.id}/${chapter.chapterId}');

      if (!await chapterDir.exists()) {
        await chapterDir.create(recursive: true);
      }

      // Download each page image
      List<Page> downloadedPages = [];
      int successfulDownloads = 0;

      for (int i = 0; i < chapter.pages.length; i++) {
        final page = chapter.pages[i];
        final imagePath =
            '${chapterDir.path}/page_${page.pageNumber}.${_getFileExtension(page.imageUrl)}';

        try {
          await _dio.download(page.imageUrl, imagePath);
          downloadedPages.add(
            page.copyWith(imageUrl: imagePath), // Use local path
          );
          successfulDownloads++;

          // Update progress
          final progress = (i + 1) / chapter.pages.length;
          onProgress(progress);

          print('✅ Downloaded page ${page.pageNumber}/${chapter.pages.length}');
        } catch (e) {
          print('❌ Failed to download page ${page.pageNumber}: $e');
          // Continue with other pages
        }

        // Small delay to avoid overwhelming the server
        await Future.delayed(Duration(milliseconds: 100));
      }

      if (successfulDownloads == 0) {
        return DownloadResult(
          success: false,
          downloadedPages: 0,
          totalPages: chapter.pages.length,
          error: 'No pages were downloaded',
        );
      }

      // Mark chapter as downloaded
      final downloadedChapter = chapter.copyWith(
        isDownloaded: true,
        localPath: chapterDir.path,
        pages: downloadedPages,
      );

      // Check if comic already exists in downloads
      Comic? existingComic = _downloadsBox!.get(comic.id.toString());
      Comic updatedComic;

      if (existingComic != null) {
        print('📖 Updating existing comic in Hive');
        // Update existing comic - replace the specific chapter
        List<Chapter> updatedChapters = [];
        bool chapterReplaced = false;

        for (var c in existingComic.chapters) {
          if (c.chapterId == chapter.chapterId) {
            updatedChapters.add(downloadedChapter);
            chapterReplaced = true;
            print('✅ Replaced existing chapter ${c.chapterNumber}');
          } else {
            updatedChapters.add(c);
          }
        }

        // If chapter wasn't found, add it
        if (!chapterReplaced) {
          updatedChapters.add(downloadedChapter);
          print('✅ Added new chapter ${downloadedChapter.chapterNumber}');
        }

        updatedComic = existingComic.copyWith(chapters: updatedChapters);
      } else {
        print('🆕 Creating new comic in Hive');
        // Create new comic with only the downloaded chapter
        updatedComic = comic.copyWith(chapters: [downloadedChapter]);
      }

      print('💾 Saving comic to Hive: ${comic.title}');
      await _downloadsBox!.put(comic.id.toString(), updatedComic);
      await _downloadsBox!.flush(); // Force write to disk

      _debugHiveState(updatedComic);

      // Verify the save
      final savedComic = _downloadsBox!.get(comic.id.toString());
      if (savedComic != null) {
        print('✅ Successfully saved comic to Hive!');
        print('📊 Saved comic has ${savedComic.chapters.length} chapters');
        final downloadedCount = savedComic.chapters.where((c) => c.isDownloaded).length;
        print('📚 Downloaded chapters: $downloadedCount');
      } else {
        print('❌ Failed to save comic to Hive!');
      }

      print('✅ Chapter ${chapter.chapterNumber} download completed!');

      return DownloadResult(
        success: true,
        downloadedPages: successfulDownloads,
        totalPages: chapter.pages.length,
        error:
            successfulDownloads < chapter.pages.length
                ? 'Some pages failed to download ($successfulDownloads/${chapter.pages.length} successful)'
                : null,
      );
    } catch (e) {
      print('❌ Chapter download failed: $e');
      return DownloadResult(
        success: false,
        downloadedPages: 0,
        totalPages: chapter.pages.length,
        error: 'Download failed: $e',
      );
    }
  }

  // Add this to your DownloadService class
  Chapter? getDownloadedChapter(String comicId, String chapterId) {
    if (!isInitialized) return null;

    try {
      final comic = _downloadsBox!.get(comicId);
      if (comic == null) return null;

      final chapter = comic.chapters.firstWhere(
        (c) => c.chapterId == chapterId && c.isDownloaded,
        orElse: () => Chapter(chapterId: '', title: '', chapterNumber: '', pages: []),
      );

      return chapter.chapterId.isNotEmpty ? chapter : null;
    } catch (e) {
      print('❌ Error getting downloaded chapter: $e');
      return null;
    }
  }

  // Check if chapter is downloaded
  Future<bool> isChapterDownloaded(String comicId, String chapterId) async {
    // ✅ FIXED: Better initialization check
    if (!isInitialized) {
      print('❌ DownloadService not initialized in isChapterDownloaded');
      return false;
    }

    try {
      final comic = _downloadsBox!.get(comicId);
      if (comic == null) return false;

      final chapter = comic.chapters.firstWhere(
        (c) => c.chapterId == chapterId,
        orElse:
            () => Chapter(
              chapterId: '',
              title: '',
              chapterNumber: '',
              pages: [],
              isDownloaded: false,
            ),
      );

      if (chapter.chapterId.isEmpty) {
        print('📭 Chapter $chapterId not found in comic $comicId');
        return false;
      }

      print('🔍 Checked chapter $chapterId in comic $comicId: ${chapter.isDownloaded}');
      return chapter.isDownloaded;
    } catch (e) {
      print('❌ Error in isChapterDownloaded: $e');
      return false;
    }
  }

  // Get downloaded comic
  Comic? getDownloadedComic(String comicId) {
    if (!isInitialized) return null;
    return _downloadsBox!.get(comicId);
  }

  // Get all downloaded comics
  List<Comic> getAllDownloadedComics() {
    if (!isInitialized) {
      print('❌ DownloadService not initialized in getAllDownloadedComics');
      return [];
    }

    try {
      final comics =
          _downloadsBox!.values.where((comic) {
            return comic.chapters.any((chapter) => chapter.isDownloaded);
          }).toList();

      print('📦 Found ${comics.length} downloaded comics in Hive');
      return comics;
    } catch (e) {
      print('❌ Error getting downloaded comics: $e');
      return [];
    }
  }

  // Delete downloaded chapter
  Future<void> deleteDownloadedChapter(String comicId, String chapterId) async {
    if (!isInitialized) {
      print('❌ DownloadService not initialized in deleteDownloadedChapter');
      return;
    }

    try {
      final comic = _downloadsBox!.get(comicId);
      if (comic == null) return;

      // Remove the chapter from downloaded comic
      final updatedChapters =
          comic.chapters.map((c) {
            if (c.chapterId == chapterId) {
              return c.copyWith(isDownloaded: false, localPath: null);
            }
            return c;
          }).toList();

      final updatedComic = comic.copyWith(chapters: updatedChapters);
      await _downloadsBox!.put(comicId, updatedComic);

      // Delete files
      final dir = await getApplicationDocumentsDirectory();
      final chapterDir = Directory('${dir.path}/downloads/$comicId/$chapterId');
      if (await chapterDir.exists()) {
        await chapterDir.delete(recursive: true);
      }

      print('🗑️ Deleted downloaded chapter: $chapterId');
    } catch (e) {
      print('❌ Error deleting chapter: $e');
    }
  }

  // Helper method to get file extension
  String _getFileExtension(String url) {
    try {
      final uri = Uri.parse(url);
      final path = uri.path;
      final dotIndex = path.lastIndexOf('.');
      return dotIndex != -1 ? path.substring(dotIndex + 1).toLowerCase() : 'jpg';
    } catch (e) {
      return 'jpg';
    }
  }
}

class DownloadResult {
  final bool success;
  final int downloadedPages;
  final int totalPages;
  final String? error;

  DownloadResult({
    required this.success,
    required this.downloadedPages,
    required this.totalPages,
    this.error,
  });
}
