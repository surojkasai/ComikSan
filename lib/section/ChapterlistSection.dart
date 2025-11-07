import 'dart:io';

import 'package:comiksan/model/chapter.dart';
import 'package:comiksan/model/comic.dart';
import 'package:comiksan/pages/ComicReader.dart';
import 'package:comiksan/services/api_service.dart';
import 'package:comiksan/services/download_Service.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/adapters.dart';

class ChaptersSection extends StatefulWidget {
  final Comic comic;
  final List<Chapter> chapters;
  final String mangaDexId;

  const ChaptersSection({
    super.key,
    required this.comic,
    required this.chapters,
    required this.mangaDexId,
  });

  @override
  State<ChaptersSection> createState() => _ChaptersSectionState();
}

class _ChaptersSectionState extends State<ChaptersSection> {
  List<Chapter> _displayChapters = [];
  final DownloadService _downloadService = DownloadService();
  final Map<String, double> _downloadProgress = {}; // chapterId -> progress
  final Map<String, bool> _isDownloading = {};
  final Map<String, bool> _chapterDownloadStatus = {};
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  bool _searchLoading = false;
  Box<Comic>? _downloadsBox;
  bool _isServiceInitialized = false;
  bool _isHiveInitialized = false;

  @override
  void initState() {
    super.initState();
    _prepareDisplayChapters();
    _checkDownloadStatus();
    _loadAllDownloadStatuses();
    _setupHiveListener();
    _initializeService();
  }

  Future<void> _initializeService() async {
    try {
      await _downloadService.init();

      if (_downloadService.isInitialized) {
        setState(() {
          _isServiceInitialized = true;
        });
        _downloadsBox = _downloadService.downloadsBox;
        _isHiveInitialized = _downloadsBox != null;

        // Now setup everything that depends on the service
        _setupHiveListener();
        await _loadAllDownloadStatuses();
        await _checkDownloadStatus();

        print('✅ ChaptersSection service initialization complete');
      } else {
        print('❌ Failed to initialize DownloadService in ChaptersSection');
      }
    } catch (e) {
      print('❌ Error initializing ChaptersSection service: $e');
    }
  }

  // Method to pre-load all download statuses
  Future<void> _loadAllDownloadStatuses() async {
    if (!_isServiceInitialized) {
      print('⚠️ Service not initialized in _loadAllDownloadStatuses');
      return;
    }

    print('🔄 Loading download statuses for ${_displayChapters.length} chapters');

    for (final chapter in _displayChapters) {
      try {
        final isDownloaded = await _downloadService.isChapterDownloaded(
          widget.comic.id.toString(),
          chapter.chapterId,
        );

        if (mounted) {
          setState(() {
            _chapterDownloadStatus[chapter.chapterId] = isDownloaded;

            // Also update the chapter in display list
            final chapterIndex = _displayChapters.indexWhere(
              (c) => c.chapterId == chapter.chapterId,
            );
            if (chapterIndex != -1) {
              _displayChapters[chapterIndex] = chapter.copyWith(isDownloaded: isDownloaded);
            }
          });
        }

        print('   - Chapter ${chapter.chapterNumber}: $isDownloaded');
      } catch (e) {
        print('❌ Error checking chapter ${chapter.chapterNumber}: $e');
      }
    }

    print('✅ Finished loading download statuses');
  }

  // Check download status for all chapters
  Future<void> _checkDownloadStatus() async {
    if (!_isServiceInitialized) {
      print('⚠️ Service not initialized in _checkDownloadStatus');
      return;
    }
    try {
      for (final chapter in widget.chapters) {
        final isDownloaded = await _downloadService.isChapterDownloaded(
          widget.comic.id.toString(),
          chapter.chapterId,
        );

        if (mounted) {
          setState(() {
            final chapterIndex = _displayChapters.indexWhere(
              (c) => c.chapterId == chapter.chapterId,
            );
            if (chapterIndex != -1) {
              _displayChapters[chapterIndex] = chapter.copyWith(isDownloaded: isDownloaded);
            }
          });
        }
      }
      print('✅ Checked download status for ${widget.chapters.length} chapters');
    } catch (e) {
      print('❌ Error checking download status: $e');
    }
  }

  void _setupHiveListener() {
    if (_downloadsBox == null) {
      print('⚠️ Hive box not available for listener setup');
      return;
    }
    _downloadsBox?.listenable().addListener(() {
      if (mounted) {
        _checkDownloadStatus();
      }
    });
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

    _displayChapters = sortedChapters;

    print('=== FLUTTER: Prepared display chapters ===');
    print('Total chapters available: ${widget.chapters.length}');
  }

  Future<void> _searchChapter() async {
    final input = _searchController.text.trim();
    if (input.isEmpty) return;

    print('🔄 Searching for chapter: $input');
    setState(() {
      _searchLoading = true;
    });

    try {
      // ✅ FIRST: Try local search (faster and more reliable)
      Chapter? foundChapter;

      // Exact match
      foundChapter = widget.chapters.firstWhere(
        (chapter) => chapter.chapterNumber == input,
        orElse:
            () => Chapter(chapterId: '', title: '', chapterNumber: '', pages: [], groupName: ''),
      );

      // If not found, try numeric comparison
      if (foundChapter.chapterId.isEmpty) {
        final inputNum = double.tryParse(input);
        if (inputNum != null) {
          for (var chapter in widget.chapters) {
            final chapterNum = double.tryParse(chapter.chapterNumber);
            if (chapterNum != null && chapterNum == inputNum) {
              foundChapter = chapter;
              break;
            }
          }
        }
      }

      // If still not found locally, try API search
      if (foundChapter!.chapterId.isEmpty) {
        print('⚠️ Chapter not found locally, trying API search...');
        final apiService = ApiService();
        foundChapter = await apiService.findChapterByNumber(widget.mangaDexId, input);
      }

      if (foundChapter != null && foundChapter.chapterId.isNotEmpty) {
        print('✅ Found chapter: ${foundChapter.chapterNumber}');

        _searchController.clear();
        _searchFocusNode.unfocus();
        Navigator.of(context).pop();

        // Navigate to reader
        _navigateToChapterReader(context, foundChapter);
      } else {
        print('❌ Chapter not found: $input');
        _showChapterNotFoundDialog(input);
      }
    } catch (e) {
      print('❌ Search error: $e');
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
    } // Show loading while service is initializing
    if (!_isServiceInitialized || !_isHiveInitialized) {
      return Container(
        margin: EdgeInsets.only(top: 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                'Chapters',
                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            Center(
              child: Column(
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text('Initializing download service...', style: TextStyle(color: Colors.white70)),
                ],
              ),
            ),
            // Show chapters without download status while loading
            _buildChaptersListWithoutHive(),
          ],
        ),
      );
    }
    return ValueListenableBuilder(
      valueListenable: _downloadsBox!.listenable(),
      builder: (context, Box<Comic> box, _) {
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
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
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
                    _buildHeaderCell('Chapter', flex: 3),
                    _buildHeaderCellWithSearch('Go', flex: 2, onTap: _showSearchDialog),
                    _buildHeaderCell('Uploaded', flex: 2),
                    _buildHeaderCell('Group', flex: 2),
                  ],
                ),
              ),

              ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: _displayChapters.length,
                itemBuilder: (context, index) {
                  final chapter = _displayChapters[index];
                  final isLatestChapter =
                      index == _displayChapters.length - 1; // Second item is latest
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
      },
    );
  }

  Widget _buildChaptersListWithoutHive() {
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
                _buildHeaderCell('Chapter', flex: 3),
                _buildHeaderCellWithSearch('Go', flex: 2, onTap: _showSearchDialog),
                _buildHeaderCell('Uploaded', flex: 2),
                _buildHeaderCell('Group', flex: 2),
              ],
            ),
          ),

          // Chapters list without download status
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _displayChapters.length,
            itemBuilder: (context, index) {
              final chapter = _displayChapters[index];
              final isLatestChapter = index == _displayChapters.length - 1;
              final isFirstChapter = index == 0;

              return _buildChapterRowWithoutDownloadStatus(
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

  Widget _buildChaptersListWithHive() {
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
                _buildHeaderCell('Chapter', flex: 3),
                _buildHeaderCellWithSearch('Go', flex: 2, onTap: _showSearchDialog),
                _buildHeaderCell('Uploaded', flex: 2),
                _buildHeaderCell('Group', flex: 2),
              ],
            ),
          ),

          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: _displayChapters.length,
            itemBuilder: (context, index) {
              final chapter = _displayChapters[index];
              final isLatestChapter = index == _displayChapters.length - 1;
              final isFirstChapter = index == 0;

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

  Widget _buildChapterRowWithoutDownloadStatus(
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
                    Icon(Icons.whatshot_outlined, color: Colors.amber, size: 16),
                    SizedBox(width: 4),
                  ],
                  Flexible(
                    child: Text(
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
                            (isFirstChapter || isLatestChapter)
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Download button (disabled while initializing)
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: IconButton(
                icon: Icon(Icons.download_for_offline_outlined, color: Colors.grey),
                onPressed: null,
                tooltip: 'Initializing...',
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
    final isDownloading = _isDownloading[chapter.chapterId] ?? false;
    final progress = _downloadProgress[chapter.chapterId] ?? 0.0;
    final isDownloaded = _chapterDownloadStatus[chapter.chapterId] ?? false;
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
                    Icon(Icons.whatshot_outlined, color: Colors.amber, size: 16),
                    SizedBox(width: 4),
                  ],
                  if (isDownloaded) ...[
                    Icon(Icons.offline_bolt, color: Colors.green, size: 16),
                    SizedBox(width: 4),
                  ],
                  Flexible(
                    child: Text(
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
                            (isFirstChapter || isLatestChapter)
                                ? FontWeight.bold
                                : FontWeight.normal,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          //download button
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: _buildDownloadButton(chapter, isDownloading, isDownloaded, progress),
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

  Widget _buildDownloadButton(
    Chapter chapter,
    bool isDownloading,
    bool isDownloaded,
    double progress,
  ) {
    // ✅ Use the cached status instead of FutureBuilder
    final actualDownloaded = _chapterDownloadStatus[chapter.chapterId] ?? isDownloaded;

    if (actualDownloaded) {
      return IconButton(
        icon: Icon(Icons.offline_bolt, color: Colors.green),
        onPressed: () {
          _showDeleteDownloadDialog(chapter);
        },
        tooltip: 'Downloaded - Tap to delete',
      );
    }

    if (isDownloading) {
      return Stack(
        alignment: Alignment.center,
        children: [
          CircularProgressIndicator(
            value: progress,
            strokeWidth: 3,
            backgroundColor: Colors.grey[700],
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
          ),
          Text(
            '${(progress * 100).toInt()}%',
            style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
          ),
        ],
      );
    }

    return IconButton(
      icon: Icon(Icons.download_for_offline_outlined, color: Colors.amber),
      onPressed: () => _downloadChapter(chapter),
      tooltip: 'Download for offline reading',
    );
  }

  void _checkHiveState(String comicId) async {
    try {
      final box = await Hive.openBox<Comic>('downloaded_comics');
      final comic = box.get(comicId);

      print('=== HIVE STATE CHECK ===');
      print('Comic ID: $comicId');
      print('Comic exists: ${comic != null}');

      if (comic != null) {
        print('Comic title: ${comic.title}');
        print('Total chapters in Hive: ${comic.chapters.length}');

        for (var chapter in comic.chapters) {
          print('  Chapter ${chapter.chapterNumber}:');
          print('    - ID: ${chapter.chapterId}');
          print('    - Downloaded: ${chapter.isDownloaded}');
          print('    - Pages: ${chapter.pages.length}');
          print('    - Local Path: ${chapter.localPath}');
        }
      } else {
        print('❌ Comic not found in Hive!');
      }
      print('========================');
    } catch (e) {
      print('❌ Error checking Hive state: $e');
    }
  }

  Future<void> _downloadChapter(Chapter chapter) async {
    if (_isDownloading[chapter.chapterId] == true) return;

    _debugChapterState(chapter);
    setState(() {
      _isDownloading[chapter.chapterId] = true;
      _downloadProgress[chapter.chapterId] = 0.0;
    });

    try {
      print('🔄 Starting download for chapter: ${chapter.chapterNumber}');

      // ✅ Check if chapter has pages, if not load them first
      Chapter chapterToDownload = chapter;

      if (chapterToDownload.pages.isEmpty) {
        print('📄 No pages found, loading pages first...');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Loading chapter pages...'),
            backgroundColor: Colors.blue,
            duration: Duration(seconds: 5),
          ),
        );

        final apiService = ApiService();
        chapterToDownload = await apiService.getChapterPages(chapter.chapterId);

        // Update the chapter in our list
        final chapterIndex = _displayChapters.indexWhere((c) => c.chapterId == chapter.chapterId);
        if (chapterIndex != -1) {
          setState(() {
            _displayChapters[chapterIndex] = chapterToDownload;
          });
        }

        if (chapterToDownload.pages.isEmpty) {
          throw Exception('Failed to load pages for this chapter');
        }

        print('✅ Loaded ${chapterToDownload.pages.length} pages for download');
      }

      print('📊 Starting download with ${chapterToDownload.pages.length} pages');

      final result = await _downloadService.downloadChapter(
        comic: widget.comic,
        chapter: chapterToDownload,
        onProgress: (progress) {
          if (mounted) {
            setState(() {
              _downloadProgress[chapter.chapterId] = progress;
            });
          }
        },
      );

      if (mounted) {
        setState(() {
          _isDownloading[chapter.chapterId] = false;
        });
      }

      if (result.success) {
        // ✅ Update the cached status
        setState(() {
          _chapterDownloadStatus[chapter.chapterId] = true;
        });

        // ✅ Also update the chapter in display list
        final chapterIndex = _displayChapters.indexWhere((c) => c.chapterId == chapter.chapterId);
        if (chapterIndex != -1) {
          setState(() {
            _displayChapters[chapterIndex] = _displayChapters[chapterIndex].copyWith(
              isDownloaded: true,
            );
          });
        }

        String successMessage = 'Chapter ${chapter.chapterNumber} downloaded successfully!';
        if (result.downloadedPages < result.totalPages) {
          successMessage += ' (${result.downloadedPages}/${result.totalPages} pages)';
        }

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(successMessage),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 3),
          ),
        );
        print('✅ Download successful: ${result.downloadedPages}/${result.totalPages} pages');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.error ?? 'Download failed'),
            backgroundColor: Colors.red,
            duration: Duration(seconds: 3),
          ),
        );
        print('❌ Download failed: ${result.error}');
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isDownloading[chapter.chapterId] = false;
        });
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Download error: $e'),
          backgroundColor: Colors.red,
          duration: Duration(seconds: 3),
        ),
      );
      print('❌ Download error: $e');
    }
  }

  // ✅ NEW METHOD: Show delete confirmation dialog
  Future<void> _showDeleteDownloadDialog(Chapter chapter) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text('Delete Download', style: TextStyle(color: Colors.white)),
            content: Text(
              'Are you sure you want to delete Chapter ${chapter.chapterNumber} from downloads?',
              style: TextStyle(color: Colors.white70),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel', style: TextStyle(color: Colors.white70)),
              ),
              ElevatedButton(
                onPressed: () => Navigator.pop(context, true),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                child: Text('Delete', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );

    if (shouldDelete == true) {
      await _deleteDownloadedChapter(chapter);
    }
  }

  // ✅ NEW METHOD: Delete downloaded chapter
  // ✅ NEW METHOD: Delete downloaded chapter
  Future<void> _deleteDownloadedChapter(Chapter chapter) async {
    try {
      await _downloadService.deleteDownloadedChapter(widget.comic.id.toString(), chapter.chapterId);

      // Update the UI
      setState(() {
        _chapterDownloadStatus[chapter.chapterId] = false; // ✅ Update cached status

        final chapterIndex = _displayChapters.indexWhere((c) => c.chapterId == chapter.chapterId);
        if (chapterIndex != -1) {
          _displayChapters[chapterIndex] = chapter.copyWith(isDownloaded: false, localPath: null);
        }
        _downloadProgress.remove(chapter.chapterId);
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Chapter ${chapter.chapterNumber} deleted from downloads'),
          backgroundColor: Colors.green,
        ),
      );

      print('🗑️ Deleted downloaded chapter: ${chapter.chapterNumber}');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete: $e'), backgroundColor: Colors.red));
      print('❌ Error deleting chapter: $e');
    }
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
    // CHECK IF CHAPTER IS DOWNLOADED FIRST
    final isDownloaded = _chapterDownloadStatus[chapter.chapterId] == true;

    if (isDownloaded) {
      print('📱 Using downloaded chapter: ${chapter.chapterNumber}');

      // Get the downloaded chapter from Hive
      final downloadedComic = _downloadService.getDownloadedComic(widget.comic.id.toString());
      if (downloadedComic != null) {
        final downloadedChapter = downloadedComic.chapters.firstWhere(
          (c) => c.chapterId == chapter.chapterId,
          orElse: () => Chapter(chapterId: '', title: '', chapterNumber: '', pages: []),
        );

        if (downloadedChapter.chapterId.isNotEmpty && downloadedChapter.pages.isNotEmpty) {
          print(
            '✅ Using local pages for downloaded chapter: ${downloadedChapter.pages.length} pages',
          );
          // ✅ DEBUG: Check the first page's image URL
          if (downloadedChapter.pages.isNotEmpty) {
            final firstPage = downloadedChapter.pages.first;
            print('🔍 First page URL: ${firstPage.imageUrl}');
            print('🔍 Is local file: ${firstPage.imageUrl.startsWith('/')}');

            // Check if file exists
            final file = File(firstPage.imageUrl);
            final exists = await file.exists();
            print('🔍 File exists: $exists');
            print('🔍 File path: ${file.path}');
          }
          // Navigate directly with local pages - no loading dialog needed
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ComicReader(
                    comic: widget.comic,
                    chapter: downloadedChapter,
                    fetchChapter: (chapterId) async {
                      // For downloaded chapters, try to get from local first
                      final localComic = _downloadService.getDownloadedComic(
                        widget.comic.id.toString(),
                      );
                      if (localComic != null) {
                        final localChapter = localComic.chapters.firstWhere(
                          (c) => c.chapterId == chapterId,
                          orElse:
                              () => Chapter(chapterId: '', title: '', chapterNumber: '', pages: []),
                        );
                        if (localChapter.chapterId.isNotEmpty && localChapter.isDownloaded) {
                          return localChapter;
                        }
                      }
                      // Fallback to API if not found locally
                      return ApiService().getChapterPages(chapterId);
                    },
                    fetchChapterList: () {
                      return ApiService().getChapters(widget.mangaDexId);
                    },
                  ),
            ),
          );
          return;
        } else {
          print('⚠️ Downloaded chapter found but has no pages, falling back to API');
        }
      } else {
        print('⚠️ Chapter marked as downloaded but comic not found in Hive, falling back to API');
      }
    }

    // FALLBACK TO API FOR NON-DOWNLOADED CHAPTERS
    print('🌐 Loading from API for chapter: ${chapter.chapterNumber}');

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

      // LOAD PAGES FOR THIS CHAPTER
      final apiService = ApiService();
      final chapterWithPages = await apiService.getChapterPages(chapter.chapterId);

      // CLOSE LOADING DIALOG
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

      // NAVIGATE TO READER WITH PAGES
      Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (context) => ComicReader(
                comic: widget.comic,
                chapter: chapterWithPages,
                fetchChapter: (chapterId) {
                  return ApiService().getChapterPages(chapterId);
                },
                fetchChapterList: () {
                  return ApiService().getChapters(widget.mangaDexId);
                },
              ),
        ),
      );
    } catch (e) {
      // CLOSE LOADING DIALOG ON ERROR
      Navigator.of(context).pop();

      print('❌ Error loading chapter pages: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to load chapter: $e'), backgroundColor: Colors.red),
      );
    }
  }

  void _debugChapterState(Chapter chapter) {
    print('=== CHAPTER DEBUG INFO ===');
    print('Chapter ID: ${chapter.chapterId}');
    print('Chapter Number: ${chapter.chapterNumber}');
    print('Chapter Title: ${chapter.title}');
    print('Pages Count: ${chapter.pages.length}');
    print('Is Downloaded: ${chapter.isDownloaded}');
    print('Local Path: ${chapter.localPath}');

    if (chapter.pages.isNotEmpty) {
      print('First Page URL: ${chapter.pages.first.imageUrl}');
    } else {
      print('❌ NO PAGES AVAILABLE');
    }
    print('==========================');
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }
}
