// import 'package:comiksan/model/comic.dart' as comic_model;
// import 'package:comiksan/util/headfooter.dart';
// import 'package:flutter/material.dart';
// import 'package:comiksan/model/comic.dart';

// class ComicReader extends StatefulWidget {
//   final Chapter chapter;

//   const ComicReader({super.key, required this.chapter});

//   @override
//   State<ComicReader> createState() => _ComicReaderState();
// }

// class _ComicReaderState extends State<ComicReader> {
//   final ScrollController _scrollController = ScrollController();
//   bool _isLoading = false;

//   @override
//   void initState() {
//     super.initState();
//     print('=== FLUTTER: ComicReader initialized ===');
//     print('Chapter: ${widget.chapter.title}');
//     print('Chapter ID: ${widget.chapter.chapterId}');
//     print('Total pages: ${widget.chapter.pages.length}');
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Headfooter(
//       body: Scaffold(
//         backgroundColor: Colors.black,
//         appBar: AppBar(
//           backgroundColor: Colors.black,
//           title: Text('${widget.chapter.title}', style: TextStyle(color: Colors.white)),
//           leading: IconButton(
//             icon: Icon(Icons.arrow_back, color: Colors.white),
//             onPressed: () => Navigator.pop(context),
//           ),
//         ),
//         body: _buildReaderBody(),
//       ),
//     );
//   }

//   Widget _buildReaderBody() {
//     if (widget.chapter.pages.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline, color: Colors.white, size: 64),
//             SizedBox(height: 16),
//             Text('No pages available', style: TextStyle(color: Colors.white, fontSize: 18)),
//           ],
//         ),
//       );
//     }

//     return Column(
//       children: [
//         // Progress indicator
//         if (_isLoading)
//           LinearProgressIndicator(
//             backgroundColor: Colors.grey[800],
//             valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
//           ),

//         // Vertical scrollable pages
//         Expanded(
//           child: NotificationListener<ScrollNotification>(
//             onNotification: (scrollNotification) {
//               // You can add lazy loading or other scroll-based features here
//               return false;
//             },
//             child: Scrollbar(
//               controller: _scrollController,
//               child: ListView.builder(
//                 controller: _scrollController,
//                 physics: AlwaysScrollableScrollPhysics(),
//                 itemCount: widget.chapter.pages.length,
//                 itemBuilder: (context, index) {
//                   final page = widget.chapter.pages[index];
//                   return _buildPageItem(page, index);
//                 },
//               ),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   Widget _buildPageItem(comic_model.Page page, int index) {
//     return Container(
//       margin: EdgeInsets.only(bottom: 8),
//       child: Column(
//         children: [
//           // Page image
//           GestureDetector(
//             onTap: () {
//               // Optional: Add tap to zoom functionality
//               _showFullScreenImage(page, index);
//             },
//             child: Container(
//               color: Colors.black,
//               child: Image.network(
//                 page.imageUrl,
//                 width: double.infinity,
//                 fit: BoxFit.contain,
//                 loadingBuilder: (context, child, loadingProgress) {
//                   if (loadingProgress == null) {
//                     print('✅ Page ${page.pageNumber} loaded successfully');
//                     return child;
//                   }

//                   // Show loading indicator
//                   return Container(
//                     height: 400, // Minimum height while loading
//                     color: Colors.grey[900],
//                     child: Center(
//                       child: Column(
//                         mainAxisAlignment: MainAxisAlignment.center,
//                         children: [
//                           CircularProgressIndicator(
//                             value:
//                                 loadingProgress.expectedTotalBytes != null
//                                     ? loadingProgress.cumulativeBytesLoaded /
//                                         loadingProgress.expectedTotalBytes!
//                                     : null,
//                           ),
//                           SizedBox(height: 8),
//                           Text(
//                             'Loading page ${page.pageNumber}...',
//                             style: TextStyle(color: Colors.white70),
//                           ),
//                         ],
//                       ),
//                     ),
//                   );
//                 },
//                 errorBuilder: (context, error, stackTrace) {
//                   print('❌ Error loading page ${page.pageNumber}: $error');
//                   print('URL: ${page.imageUrl}');

//                   return Container(
//                     height: 400,
//                     color: Colors.grey[900],
//                     child: Column(
//                       mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         Icon(Icons.error, color: Colors.white, size: 50),
//                         SizedBox(height: 10),
//                         Text(
//                           'Failed to load page ${page.pageNumber}',
//                           style: TextStyle(color: Colors.white),
//                         ),
//                         SizedBox(height: 10),
//                         ElevatedButton(
//                           onPressed: () {
//                             setState(() {
//                               // Trigger rebuild to retry loading
//                             });
//                           },
//                           child: Text('Retry'),
//                         ),
//                       ],
//                     ),
//                   );
//                 },
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _showFullScreenImage(comic_model.Page page, int index) {
//     showDialog(
//       context: context,
//       builder:
//           (context) => Dialog(
//             backgroundColor: Colors.black,
//             insetPadding: EdgeInsets.zero,
//             child: GestureDetector(
//               onTap: () => Navigator.pop(context),
//               child: Container(
//                 width: double.infinity,
//                 height: double.infinity,
//                 color: Colors.black,
//                 child: InteractiveViewer(
//                   panEnabled: true,
//                   scaleEnabled: true,
//                   minScale: 0.5,
//                   maxScale: 3.0,
//                   child: Center(child: Image.network(page.imageUrl, fit: BoxFit.contain)),
//                 ),
//               ),
//             ),
//           ),
//     );
//   }

//   // Optional: Add jump to page functionality
//   void _showJumpToPageDialog() {
//     showDialog(
//       context: context,
//       builder:
//           (context) => AlertDialog(
//             backgroundColor: Colors.grey[900],
//             title: Text('Jump to Page', style: TextStyle(color: Colors.white)),
//             content: TextField(
//               keyboardType: TextInputType.number,
//               style: TextStyle(color: Colors.white),
//               decoration: InputDecoration(
//                 hintText: 'Enter page number (1-${widget.chapter.pages.length})',
//                 hintStyle: TextStyle(color: Colors.white54),
//                 border: OutlineInputBorder(),
//               ),
//               onSubmitted: (value) {
//                 final pageNumber = int.tryParse(value);
//                 if (pageNumber != null &&
//                     pageNumber >= 1 &&
//                     pageNumber <= widget.chapter.pages.length) {
//                   _jumpToPage(pageNumber - 1);
//                   Navigator.pop(context);
//                 }
//               },
//             ),
//             actions: [
//               TextButton(
//                 onPressed: () => Navigator.pop(context),
//                 child: Text('Cancel', style: TextStyle(color: Colors.white70)),
//               ),
//             ],
//           ),
//     );
//   }

//   void _jumpToPage(int index) {
//     if (_scrollController.hasClients) {
//       final itemHeight = MediaQuery.of(context).size.height * 0.8; // Estimate height
//       final position = index * itemHeight;
//       _scrollController.animateTo(
//         position,
//         duration: Duration(milliseconds: 500),
//         curve: Curves.easeInOut,
//       );
//     }
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }
// }

import 'package:flutter/material.dart';
import 'package:comiksan/model/comic.dart' as comic_model;
import 'package:comiksan/services/chapter_service.dart';

class ComicReader extends StatefulWidget {
  final comic_model.Chapter chapter;
  final Future<comic_model.Chapter> Function(String) fetchChapter;
  final Future<List<comic_model.Chapter>> Function() fetchChapterList;

  const ComicReader({
    super.key,
    required this.chapter,
    required this.fetchChapter,
    required this.fetchChapterList,
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
    _initializeChapter();
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
          // Swipe right - go to previous chapter
          _goToPreviousChapter();
        } else if (details.primaryVelocity! < 0) {
          // Swipe left - go to next chapter
          _goToNextChapter();
        }
      },
      child: Column(
        children: [
          // Chapter navigation info
          if (_chapterService.previousChapter != null || _chapterService.nextChapter != null)
            Container(
              padding: EdgeInsets.symmetric(vertical: 8),
              color: Colors.grey[800],
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Previous chapter info
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(Icons.arrow_back, color: Colors.white54, size: 16),
                        SizedBox(width: 4),
                        Text(
                          _chapterService.previousChapter != null
                              ? 'Prev: ${_chapterService.previousChapter!.title}'
                              : 'No previous chapter',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  // Current chapter indicator
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.blue[800],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      'Chapter',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),

                  // Next chapter info
                  Expanded(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Text(
                          _chapterService.nextChapter != null
                              ? 'Next: ${_chapterService.nextChapter!.title}'
                              : 'No next chapter',
                          style: TextStyle(color: Colors.white54, fontSize: 12),
                          overflow: TextOverflow.ellipsis,
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, color: Colors.white54, size: 16),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Vertical scrollable pages
          Expanded(
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
