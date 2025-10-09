import 'package:comiksan/pages/ComicReader.dart';
import 'package:comiksan/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:comiksan/model/comic.dart';

class ChaptersSection extends StatefulWidget {
  final List<Chapter> chapters;
  final String mangaDexId;

  const ChaptersSection({super.key, required this.chapters, required this.mangaDexId});

  @override
  State<ChaptersSection> createState() => _ChaptersSectionState();
}

class _ChaptersSectionState extends State<ChaptersSection> {
  List<Chapter> _displayChapters = [];
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _searchLoading = false;

  @override
  void initState() {
    super.initState();
    _prepareDisplayChapters();
  }

  void _prepareDisplayChapters() {
    if (widget.chapters.isEmpty) {
      _displayChapters = [];
      return;
    }

    // Sort all chapters numerically (1, 2, 3, ...)
    final sortedChapters = List<Chapter>.from(widget.chapters)..sort((a, b) {
      final aNum = double.tryParse(a.chapterNumber) ?? 0;
      final bNum = double.tryParse(b.chapterNumber) ?? 0;
      return aNum.compareTo(bNum);
    });

    // Get first chapter (chapter 1)
    final firstChapter = sortedChapters.first;

    // Get latest chapter (highest number)
    final latestChapter = sortedChapters.last;

    // Only show these two chapters
    _displayChapters = [firstChapter, latestChapter];

    print('=== FLUTTER: Prepared display chapters ===');
    print('Total chapters available: ${widget.chapters.length}');
    print('First chapter: ${firstChapter.chapterNumber}');
    print('Latest chapter: ${latestChapter.chapterNumber}');
  }

  Future<void> _searchChapter() async {
    final input = _searchController.text.trim();
    if (input.isEmpty) return;

    print('🔄 Searching for chapter: $input');
    setState(() {
      _searchLoading = true;
    });

    try {
      // Find the chapter with the specified number in ALL chapters
      final foundChapter = widget.chapters.firstWhere(
        (chapter) => chapter.chapterNumber == input,
        orElse: () => Chapter(chapterId: '', title: '', chapterNumber: '', pages: []),
      );

      if (foundChapter.chapterId.isNotEmpty) {
        print('✅ Found chapter: ${foundChapter.chapterNumber}');

        _searchController.clear();
        _searchFocusNode.unfocus();
        Navigator.of(context).pop(); // Close dialog

        // Navigate directly to the chapter reader
        _navigateToChapterReader(context, foundChapter);
      } else {
        print('❌ Chapter not found: $input');
        _showChapterNotFoundDialog(input);
      }
    } catch (e) {
      print('❌ Chapter not found: $input');
      _showChapterNotFoundDialog(input);
    } finally {
      setState(() {
        _searchLoading = false;
      });
    }
  }

  void _showChapterNotFoundDialog(String chapterNumber) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text('Chapter Not Found', style: TextStyle(color: Colors.white)),
            content: Text(
              'Chapter $chapterNumber not found.\n\nAvailable chapters: ${widget.chapters.length}\nChapter range: ${_getChapterRange()}',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK', style: TextStyle(color: Colors.blue)),
              ),
            ],
          ),
    );
  }

  String _getChapterRange() {
    if (widget.chapters.isEmpty) return 'No chapters';

    final sorted = List<Chapter>.from(widget.chapters)..sort((a, b) {
      final aNum = double.tryParse(a.chapterNumber) ?? 0;
      final bNum = double.tryParse(b.chapterNumber) ?? 0;
      return aNum.compareTo(bNum);
    });

    return '${sorted.first.chapterNumber} - ${sorted.last.chapterNumber}';
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text('Go to Chapter', style: TextStyle(color: Colors.white)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Enter chapter number:', style: TextStyle(color: Colors.white70)),
                SizedBox(height: 10),
                TextField(
                  controller: _searchController,
                  focusNode: _searchFocusNode,
                  keyboardType: TextInputType.numberWithOptions(decimal: true),
                  style: TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'e.g., 1, 2.5, 10',
                    hintStyle: TextStyle(color: Colors.white54),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                    enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey)),
                  ),
                  onSubmitted: (_) => _searchChapter(),
                ),
                SizedBox(height: 10),
                Text(
                  'Total chapters: ${widget.chapters.length}',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                SizedBox(height: 5),
                Text(
                  'Chapter range: ${_getChapterRange()}',
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('Cancel', style: TextStyle(color: Colors.white70)),
              ),
              ElevatedButton(
                onPressed: _searchController.text.isEmpty ? null : _searchChapter,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                child:
                    _searchLoading
                        ? SizedBox(
                          height: 16,
                          width: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                        : Text('Go', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    print('=== FLUTTER: ChaptersSection building ===');
    print('Display chapters: ${_displayChapters.length}');
    print('Total available chapters: ${widget.chapters.length}');

    if (_displayChapters.isEmpty) {
      return Container(
        margin: EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('No chapters available yet', style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
      );
    }

    return Container(
      margin: EdgeInsets.only(top: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with info
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Chapters: ${widget.chapters.length}',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 4),
                Text(
                  'Use "Go" to find any chapter',
                  style: TextStyle(color: Colors.amber, fontSize: 12),
                ),
              ],
            ),
          ),

          // Table Header
          Container(
            decoration: BoxDecoration(
              color: Colors.grey[900],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                topRight: Radius.circular(8),
              ),
            ),
            child: Row(
              children: [
                _buildHeaderCell('Chapter', flex: 2),
                _buildHeaderCellWithSearch('Go', flex: 2, onTap: _showSearchDialog),
                _buildHeaderCell('Uploaded', flex: 2),
                _buildHeaderCell('Group', flex: 3),
              ],
            ),
          ),

          // Chapters List - Only 2 chapters
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _displayChapters.length,
            itemBuilder: (context, index) {
              final chapter = _displayChapters[index];
              final isLatestChapter = index == 1; // Second item is latest
              final isFirstChapter = index == 0; // First item is chapter 1

              return _buildChapterRow(
                chapter,
                index,
                context,
                isFirstChapter: isFirstChapter,
                isLatestChapter: isLatestChapter,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeaderCellWithSearch(String text, {int flex = 1, required VoidCallback onTap}) {
    return Expanded(
      flex: flex,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                text,
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(width: 4),
              Icon(Icons.search, color: Colors.white, size: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderCell(String text, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Text(
          text,
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
        ),
      ),
    );
  }

  Widget _buildChapterRow(
    Chapter chapter,
    int index,
    BuildContext context, {
    bool isFirstChapter = false,
    bool isLatestChapter = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: index.isEven ? Colors.grey[800] : Colors.grey[900],
        border: Border(bottom: BorderSide(color: Colors.grey[700]!, width: 0.5)),
      ),
      child: Row(
        children: [
          // Chapter Number with indicator
          Expanded(
            flex: 4,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Row(
                children: [
                  if (isFirstChapter) ...[
                    Icon(Icons.play_arrow, color: Colors.green, size: 16),
                    SizedBox(width: 4),
                  ] else if (isLatestChapter) ...[
                    Icon(Icons.new_releases, color: Colors.amber, size: 16),
                    SizedBox(width: 4),
                  ],
                  Text(
                    'Ch. ${chapter.chapterNumber}${isFirstChapter ? ' (Start)' : ''}${isLatestChapter ? '' : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    style: TextStyle(
                      color:
                          isFirstChapter
                              ? Colors.green
                              : (isLatestChapter ? Colors.amber : Colors.white),
                      fontSize: 14,
                      fontWeight:
                          (isFirstChapter || isLatestChapter) ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Read Button
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 8),
              child: ElevatedButton(
                onPressed: () {
                  _navigateToChapterReader(context, chapter);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                      isFirstChapter
                          ? Colors.green
                          : (isLatestChapter ? Colors.amber : Colors.blue),
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  minimumSize: Size(0, 0),
                ),
                child: Text(
                  'Read',
                  style: TextStyle(
                    color: isLatestChapter ? Colors.black : Colors.white,
                    fontSize: 12,
                    fontWeight:
                        (isFirstChapter || isLatestChapter) ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
            ),
          ),

          // Upload Time
          Expanded(
            flex: 2,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Text(
                _getUploadTime(chapter),
                style: TextStyle(color: Colors.white70, fontSize: 14),
              ),
            ),
          ),

          // Group Name
          Expanded(
            flex: 3,
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Text(
                chapter.groupName ?? 'Unknown Group',
                style: TextStyle(color: Colors.white, fontSize: 14),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getUploadTime(Chapter chapter) {
    if (chapter.publishedAt == null) return 'Unknown';

    final now = DateTime.now();
    final difference = now.difference(chapter.publishedAt!);

    if (difference.inDays > 365) {
      final years = (difference.inDays / 365).floor();
      return '$years ${years == 1 ? 'year' : 'years'} ago';
    } else if (difference.inDays > 30) {
      final months = (difference.inDays / 30).floor();
      return '$months ${months == 1 ? 'month' : 'months'} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} ${difference.inDays == 1 ? 'day' : 'days'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} ${difference.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} ${difference.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _navigateToChapterReader(BuildContext context, Chapter chapter) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder:
          (context) => Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.grey[900],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading Chapter ${chapter.chapterNumber}...',
                    style: TextStyle(color: Colors.white),
                  ),
                ],
              ),
            ),
          ),
    );

    try {
      print('🔄 Loading pages for chapter: ${chapter.chapterId}');

      // ✅ LOAD PAGES FOR THIS CHAPTER
      final apiService = ApiService();
      final chapterWithPages = await apiService.getChapterPages(chapter.chapterId);

      // ✅ CLOSE LOADING DIALOG
      Navigator.of(context).pop();

      if (chapterWithPages.pages.isEmpty) {
        // Show error if no pages loaded
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('No pages available for this chapter'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      print('✅ Loaded ${chapterWithPages.pages.length} pages for chapter ${chapter.chapterNumber}');

      // ✅ NAVIGATE TO READER WITH PAGES
      Navigator.push(
        context,
        // MaterialPageRoute(builder: (context) => ComicReader(chapter: chapterWithPages)),
        MaterialPageRoute(
          builder:
              (context) => ComicReader(
                chapter: chapterWithPages,
                fetchChapter: (chapterId) {
                  return ApiService().getChapterPages(chapterId);
                },
                fetchChapterList: () {
                  // You need to have the mangaDexId available here
                  return ApiService().getChapters(widget.mangaDexId);
                },
              ),
        ),
      );
    } catch (e) {
      // ✅ CLOSE LOADING DIALOG ON ERROR
      Navigator.of(context).pop();

      print('❌ Error loading chapter pages: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load chapter: $e'), backgroundColor: Colors.red),
      );
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
