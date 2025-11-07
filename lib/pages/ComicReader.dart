import 'package:comiksan/model/bookmark_model.dart';
import 'package:comiksan/model/chapter.dart' as comic_model;
import 'package:comiksan/model/comic.dart' as comic_model;
import 'package:comiksan/model/page.dart' as comic_model;
import 'package:comiksan/services/download_Service.dart';
import 'package:flutter/material.dart';
import 'package:comiksan/services/chapter_service.dart';
import 'package:hive/hive.dart';

class ComicReader extends StatefulWidget {
  final comic_model.Comic comic;
  final comic_model.Chapter chapter;
  final Future<comic_model.Chapter> Function(String) fetchChapter;
  final Future<List<comic_model.Chapter>> Function() fetchChapterList;
  final int startPage;

  const ComicReader({
    super.key,
    required this.comic,
    required this.chapter,
    required this.fetchChapter,
    required this.fetchChapterList,
    this.startPage = 0,
  });

  @override
  State<ComicReader> createState() => _ComicReaderState();
}

class _ComicReaderState extends State<ComicReader> {
  final ScrollController _scrollController = ScrollController();
  final PageController _pageController = PageController();
  final ChapterService _chapterService = ChapterService();

  int _currentPageIndex = 0;
  bool _isLoadingChapter = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _currentPageIndex = widget.startPage;
    _checkBookmark();
    _initializeChapter();
  }

  bool isBookmarked = false;

  Future<void> _checkBookmark() async {
    final currentComic = widget.comic;

    final box = Hive.box<BookmarkModel>('bookmarks');
    final saved = box.get(currentComic.id.toString());

    if (saved != null && saved.pageNumber == _currentPageIndex) {
      setState(() => isBookmarked = true);
    } else {
      setState(() => isBookmarked = false);
    }
  }

  Future<void> _initializeChapter() async {
    try {
      setState(() {
        _isLoadingChapter = true;
        _errorMessage = null;
      });

      await _chapterService.loadChapterWithNeighbors(
        widget.chapter.chapterId,
        widget.fetchChapter,
        widget.fetchChapterList,
      );

      setState(() {
        _isLoadingChapter = false;
      });

      print('✅ Chapter loaded with neighbors');
      print('Current: ${_chapterService.currentChapter?.title}');
      print('Previous: ${_chapterService.previousChapter?.title}');
      print('Next: ${_chapterService.nextChapter?.title}');
    } catch (e) {
      setState(() {
        _isLoadingChapter = false;
        _errorMessage = 'Failed to load chapter: $e';
      });
      print('❌ Error initializing chapter: $e');
    }
  }

  comic_model.Chapter? get currentChapter => _chapterService.currentChapter;

  void _goToNextPage() {
    if (currentChapter == null) return;

    if (_currentPageIndex < currentChapter!.pages.length - 1) {
      setState(() {
        _currentPageIndex++;
      });
      _scrollToPage(_currentPageIndex);
      _checkBookmark();
    } else {
      // If on last page, go to next chapter
      _goToNextChapter();
    }
  }

  void _goToPreviousPage() {
    if (currentChapter == null) return;

    if (_currentPageIndex > 0) {
      setState(() {
        _currentPageIndex--;
      });
      _scrollToPage(_currentPageIndex);
      // _autoSaveBookmark();
      _checkBookmark();
    } else {
      // If on first page, go to previous chapter
      _goToPreviousChapter();
    }
  }

  Future<void> _goToNextChapter() async {
    if (_chapterService.nextChapter == null) {
      _showSnackBar('No next chapter available');
      return;
    }

    await _switchChapter(_chapterService.nextChapter!, isNext: true);
  }

  Future<void> _goToPreviousChapter() async {
    if (_chapterService.previousChapter == null) {
      _showSnackBar('No previous chapter available');
      return;
    }

    await _switchChapter(_chapterService.previousChapter!, isNext: false);
  }

  Future<void> _switchChapter(comic_model.Chapter newChapter, {required bool isNext}) async {
    try {
      setState(() {
        _isLoadingChapter = true;
        _errorMessage = null;
      });

      await _chapterService.loadChapterWithNeighbors(
        newChapter.chapterId,
        widget.fetchChapter,
        widget.fetchChapterList,
      );

      setState(() {
        _currentPageIndex = isNext ? 0 : (currentChapter?.pages.length ?? 1) - 1;
        _isLoadingChapter = false;
      });

      _scrollToTop();
      // _autoSaveBookmark();
      _checkBookmark();
      _showSnackBar('${isNext ? 'Next' : 'Previous'} chapter: ${currentChapter?.title}');
    } catch (e) {
      setState(() {
        _isLoadingChapter = false;
        _errorMessage = 'Failed to load chapter: $e';
      });
      _showSnackBar('Error loading chapter: $e');
    }
  }

  void _scrollToPage(int pageIndex) {
    if (_scrollController.hasClients) {
      final double estimatedPageHeight = MediaQuery.of(context).size.height * 0.8;
      final double targetPosition = pageIndex * estimatedPageHeight;

      _scrollController.animateTo(
        targetPosition,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: Duration(milliseconds: 2000),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title:
            _isLoadingChapter
                ? Row(
                  children: [
                    SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 12),
                    Text('Loading...', style: TextStyle(color: Colors.white)),
                  ],
                )
                : Text(
                  currentChapter != null
                      ? '${currentChapter!.title} - Page ${_currentPageIndex + 1}/${currentChapter!.pages.length}'
                      : 'Comic Reader',
                  style: TextStyle(color: Colors.white),
                ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Chapter navigation
          if (_chapterService.previousChapter != null)
            IconButton(
              icon: Icon(Icons.skip_previous, color: Colors.white),
              onPressed: _isLoadingChapter ? null : _goToPreviousChapter,
              tooltip: 'Previous Chapter',
            ),
          if (_chapterService.nextChapter != null)
            IconButton(
              icon: Icon(Icons.skip_next, color: Colors.white),
              onPressed: _isLoadingChapter ? null : _goToNextChapter,
              tooltip: 'Next Chapter',
            ),
          // Page navigation
          IconButton(
            icon: Icon(Icons.arrow_back_ios, color: Colors.white),
            onPressed: _isLoadingChapter ? null : _goToPreviousPage,
            tooltip: 'Previous Page',
          ),
          IconButton(
            icon: Icon(Icons.arrow_forward_ios, color: Colors.white),
            onPressed: _isLoadingChapter ? null : _goToNextPage,
            tooltip: 'Next Page',
          ),
        ],
      ),
      body: _buildReaderBody(),
    );
  }

  Widget _buildReaderBody() {
    if (_isLoadingChapter) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Loading chapter...', style: TextStyle(color: Colors.white)),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.white, size: 64),
            SizedBox(height: 16),
            Text('Error loading chapter', style: TextStyle(color: Colors.white, fontSize: 18)),
            SizedBox(height: 8),
            Text(
              _errorMessage!,
              style: TextStyle(color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16),
            ElevatedButton(onPressed: _initializeChapter, child: Text('Retry')),
          ],
        ),
      );
    }

    if (currentChapter == null || currentChapter!.pages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, color: Colors.white, size: 64),
            SizedBox(height: 16),
            Text('No pages available', style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
      );
    }

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (_isLoadingChapter) return;

        if (details.primaryVelocity! > 0) {
          _goToPreviousChapter();
        } else if (details.primaryVelocity! < 0) {
          _goToNextChapter();
        }
      },
      child: Stack(
        children: [
          // The scrollable pages
          Positioned.fill(
            child: NotificationListener<ScrollNotification>(
              onNotification: (scrollNotification) {
                if (scrollNotification is ScrollUpdateNotification ||
                    scrollNotification is ScrollEndNotification) {
                  _updateCurrentPageFromScroll();
                }
                return false;
              },
              child: Scrollbar(
                controller: _scrollController,
                child: ListView.builder(
                  controller: _scrollController,
                  physics: AlwaysScrollableScrollPhysics(),
                  itemCount: currentChapter!.pages.length,
                  itemBuilder: (context, index) {
                    final page = currentChapter!.pages[index];
                    return _buildPageItem(page, index);
                  },
                ),
              ),
            ),
          ),

          // Bottom chapter navigation
          if (_chapterService.previousChapter != null || _chapterService.nextChapter != null)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                color: Colors.grey[800]?.withOpacity(0.9),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Previous chapter
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Icon(Icons.arrow_back, color: Colors.white54, size: 16),
                          SizedBox(width: 4),
                          Flexible(
                            child: Tooltip(
                              message:
                                  _chapterService.previousChapter?.title ?? 'No previous chapter',
                              child: Text(
                                'Prev: ${_chapterService.previousChapter?.title ?? ''}',
                                style: const TextStyle(color: Colors.white54, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Bookmark button
                    SizedBox(
                      width: 45,
                      height: 45,
                      child: FloatingActionButton(
                        backgroundColor: Colors.white,
                        onPressed: () async {
                          final currentComic = widget.comic;
                          final current = currentChapter;

                          if (current != null && current.pages.isNotEmpty) {
                            final box = Hive.box<BookmarkModel>('bookmarks');
                            final bookmark = BookmarkModel(
                              comicId: currentComic.id.toString(),
                              chapterId: current.chapterId.toString(),
                              pageNumber: _currentPageIndex,
                            );
                            await box.put(currentComic.id.toString(), bookmark);

                            setState(() => isBookmarked = true);
                            _showSnackBar('Bookmarked page ${bookmark.pageNumber}');
                          } else {
                            _showSnackBar('No page to bookmark');
                          }
                        },
                        child: Icon(
                          isBookmarked ? Icons.bookmark : Icons.bookmark_border,
                          color: Colors.black,
                        ),
                      ),
                    ),

                    // Next chapter
                    Expanded(
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Flexible(
                            child: Tooltip(
                              message:
                                  _chapterService.nextChapter != null
                                      ? 'Next: ${_chapterService.nextChapter!.title}'
                                      : 'No next chapter',
                              child: Text(
                                _chapterService.nextChapter != null
                                    ? 'Next: ${_chapterService.nextChapter!.title}'
                                    : 'No next chapter',
                                style: TextStyle(color: Colors.white54, fontSize: 12),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ),
                          SizedBox(width: 4),
                          Icon(Icons.arrow_forward, color: Colors.white54, size: 16),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  void _updateCurrentPageFromScroll() {
    if (!_scrollController.hasClients || currentChapter == null) return;

    final scrollPosition = _scrollController.position.pixels;
    final estimatedPageHeight = MediaQuery.of(context).size.height * 0.8;
    final newPageIndex = (scrollPosition / estimatedPageHeight).round();

    if (newPageIndex >= 0 &&
        newPageIndex < currentChapter!.pages.length &&
        newPageIndex != _currentPageIndex) {
      setState(() {
        _currentPageIndex = newPageIndex;
      });
      // _autoSaveBookmark();
    }
  }

  Widget _buildPageItem(comic_model.Page page, int index) {
    final isCurrentPage = index == _currentPageIndex;

    return Container(
      margin: EdgeInsets.only(bottom: 2),
      decoration:
          isCurrentPage ? BoxDecoration(border: Border.all(color: Colors.blue, width: 3)) : null,
      child: GestureDetector(
        onTap: () {
          _showFullScreenImage(page, index);
        },
        child: Image.network(
          page.imageUrl,
          width: double.infinity,
          fit: BoxFit.contain,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;

            return Container(
              height: 400,
              color: Colors.grey[900],
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      value:
                          loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                                  loadingProgress.expectedTotalBytes!
                              : null,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Loading page ${page.pageNumber}...',
                      style: TextStyle(color: Colors.white70),
                    ),
                  ],
                ),
              ),
            );
          },

          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 400,
              color: Colors.grey[900],
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: Colors.white, size: 50),
                  SizedBox(height: 10),
                  Text(
                    'Failed to load page ${page.pageNumber}',
                    style: TextStyle(color: Colors.white),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(onPressed: () => setState(() {}), child: Text('Retry')),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  void _showFullScreenImage(comic_model.Page page, int index) {
    showDialog(
      context: context,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.black,
            insetPadding: EdgeInsets.zero,
            child: Stack(
              children: [
                GestureDetector(
                  onHorizontalDragEnd: (details) {
                    if (details.primaryVelocity! > 0) {
                      Navigator.pop(context);
                      _goToPreviousChapter();
                    } else if (details.primaryVelocity! < 0) {
                      Navigator.pop(context);
                      _goToNextChapter();
                    } else {
                      Navigator.pop(context);
                    }
                  },
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.black,
                    child: InteractiveViewer(
                      panEnabled: true,
                      scaleEnabled: true,
                      minScale: 0.5,
                      maxScale: 3.0,
                      child: Center(child: Image.network(page.imageUrl, fit: BoxFit.contain)),
                    ),
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: IconButton(
                    icon: Icon(Icons.close, color: Colors.white, size: 30),
                    onPressed: () => Navigator.pop(context),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 0,
                  right: 0,
                  child: Container(
                    padding: EdgeInsets.all(16),
                    color: Colors.black54,
                    child: Column(
                      children: [
                        Text(
                          '${currentChapter?.title ?? "Chapter"} - Page ${page.pageNumber}',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Swipe for chapters • Tap to close',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _pageController.dispose();
    super.dispose();
  }
}
