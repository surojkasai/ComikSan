import 'package:comiksan/model/comic.dart';
import 'package:comiksan/providers/comic_providers.dart';
import 'package:comiksan/section/comiccard.dart';
import 'package:comiksan/services/download_Service.dart';
import 'package:comiksan/util/headfooter.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';

class Downloadpage extends StatefulWidget {
  final VoidCallback? onTap;
  const Downloadpage({super.key, this.onTap});

  @override
  State<Downloadpage> createState() => _DownloadpageState();
}

class _DownloadpageState extends State<Downloadpage> {
  final DownloadService _downloadService = DownloadService();
  bool _isLoading = true;
  bool _isServiceInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeService();
  }

  // ✅ FIXED: Simple and reliable initialization
  Future<void> _initializeService() async {
    try {
      print('🔄 Initializing DownloadService...');
      await _downloadService.init();

      setState(() {
        _isServiceInitialized = _downloadService.isInitialized;
        _isLoading = false;
      });

      if (_isServiceInitialized) {
        print('✅ DownloadService initialized successfully');
        _debugHiveContents();
      } else {
        print('❌ DownloadService failed to initialize');
      }
    } catch (e) {
      print('❌ Error initializing DownloadPage: $e');
      setState(() {
        _isLoading = false;
        _isServiceInitialized = false;
      });
    }
  }

  // ✅ FIXED: Refresh method with proper initialization check
  Future<void> _refreshDownloads() async {
    if (!_isServiceInitialized) {
      print('🔄 Service not initialized, reinitializing...');
      await _initializeService();
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await Future.delayed(Duration(milliseconds: 500));

    setState(() {
      _isLoading = false;
    });

    _debugHiveContents();
  }

  // ✅ FIXED: Safe Hive debug method
  void _debugHiveContents() {
    if (!_isServiceInitialized) {
      print('❌ Service not initialized for Hive debug');
      return;
    }

    final box = _downloadService.downloadsBox;
    if (box == null) {
      print('❌ Hive box is null');
      return;
    }

    try {
      print('=== HIVE CONTENTS DEBUG ===');
      print('Total keys in box: ${box.keys.length}');

      if (box.keys.isEmpty) {
        print('📭 Hive box is empty');
      } else {
        for (var key in box.keys) {
          final comic = box.get(key);
          print('Key: $key');
          print('Comic: ${comic?.title}');
          print('ID: ${comic?.id}');
          print('Total chapters: ${comic?.chapters.length}');

          final downloadedChapters = comic?.chapters.where((c) => c.isDownloaded).length ?? 0;
          print('Downloaded chapters: $downloadedChapters');

          if (comic != null && downloadedChapters > 0) {
            for (var chapter in comic.chapters) {
              if (chapter.isDownloaded) {
                print('  ✅ Chapter ${chapter.chapterNumber}: DOWNLOADED');
                print('     ID: ${chapter.chapterId}');
                print('     Pages: ${chapter.pages.length}');
                print('     Local Path: ${chapter.localPath}');
              }
            }
          } else if (comic != null) {
            print('  📭 No downloaded chapters in this comic');
          }
          print('---');
        }
      }
      print('==========================');
    } catch (e) {
      print('❌ Error debugging Hive: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Headfooter(
        body: RefreshIndicator(
          onRefresh: _refreshDownloads,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            child: Container(
              color: Colors.black,
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with refresh button
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Your Downloads", style: TextStyle(fontSize: 18, color: Colors.amber)),
                      IconButton(
                        icon: Icon(Icons.refresh, color: Colors.white),
                        onPressed: _refreshDownloads,
                        tooltip: 'Refresh downloads',
                      ),
                    ],
                  ),
                  SizedBox(height: 12),

                  // Loading, Error, or Content states
                  if (_isLoading) ...[
                    _buildLoadingState(),
                  ] else if (!_isServiceInitialized) ...[
                    _buildErrorState(),
                  ] else ...[
                    // ✅ FIXED: Use ValueListenableBuilder with service's box
                    ValueListenableBuilder(
                      valueListenable: _downloadService.downloadsBox!.listenable(),
                      builder: (context, Box<Comic> box, _) {
                        final downloadedComics = _getDownloadedComics(box);

                        if (downloadedComics.isEmpty) {
                          return _buildEmptyState();
                        }

                        return Column(
                          children: [
                            _buildDownloadsGrid(downloadedComics),
                            SizedBox(height: 20),
                            _buildStorageInfo(downloadedComics),
                          ],
                        );
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 80, color: Colors.red),
          SizedBox(height: 16),
          Text('Failed to load downloads', style: TextStyle(color: Colors.white, fontSize: 18)),
          SizedBox(height: 8),
          Text(
            'Please check your storage and try again',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(onPressed: _initializeService, child: Text('Retry')),
        ],
      ),
    );
  }

  // ✅ FIXED: Method to get downloaded comics from Hive box
  List<Comic> _getDownloadedComics(Box<Comic> box) {
    try {
      final comics =
          box.values.where((comic) {
            final hasDownloads = comic.chapters.any((chapter) => chapter.isDownloaded);
            if (hasDownloads) {
              print('✅ Found downloaded comic: ${comic.title}');
              print(
                '   - Downloaded chapters: ${comic.chapters.where((c) => c.isDownloaded).length}',
              );
              print('   - Total chapters: ${comic.chapters.length}');
            }
            return hasDownloads;
          }).toList();

      print('📊 Total downloaded comics found: ${comics.length}');
      return comics;
    } catch (e) {
      print('❌ Error getting downloaded comics: $e');
      return [];
    }
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Loading downloads...', style: TextStyle(color: Colors.white)),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        children: [
          Icon(Icons.download_for_offline_outlined, size: 80, color: Colors.grey),
          SizedBox(height: 16),
          Text('No Downloads Yet', style: TextStyle(color: Colors.white, fontSize: 18)),
          SizedBox(height: 8),
          Text(
            'Download chapters from comic details to read them offline',
            style: TextStyle(color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 20),
          ElevatedButton(onPressed: _refreshDownloads, child: Text('Check Again')),
        ],
      ),
    );
  }

  Widget _buildDownloadsGrid(List<Comic> downloadedComics) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children:
          downloadedComics.map((comic) {
            return SizedBox(
              width: (MediaQuery.of(context).size.width - 40) / 3,
              child: _buildDownloadedComicCard(comic),
            );
          }).toList(),
    );
  }

  Widget _buildDownloadedComicCard(Comic comic) {
    final downloadedChapters = comic.chapters.where((c) => c.isDownloaded).length;
    final totalPages = comic.chapters.fold(0, (sum, chapter) => sum + chapter.pages.length);

    return Stack(
      children: [
        ComicCard(
          downloadIcon: Icons.offline_bolt,
          comic: comic,
          // onTap: () {
          //   Navigator.pushNamed(context, '/comic-details', arguments: comic);
          // },
        ),

        // Download badge
        Positioned(
          top: 4,
          right: 4,
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(8)),
            child: Text(
              '$downloadedChapters',
              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ),
        ),

        // Delete button
        Positioned(
          top: 4,
          left: 4,
          child: GestureDetector(
            onTap: () => _showDeleteDialog(comic),
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: Icon(Icons.delete_outline, color: Colors.white, size: 16),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStorageInfo(List<Comic> downloadedComics) {
    final totalChapters = downloadedComics.fold(
      0,
      (sum, comic) => sum + comic.chapters.where((c) => c.isDownloaded).length,
    );

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(color: Colors.grey[900], borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Storage Info',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 4),
              Text(
                '$totalChapters chapter${totalChapters != 1 ? 's' : ''} across ${downloadedComics.length} comic${downloadedComics.length != 1 ? 's' : ''}',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: downloadedComics.isNotEmpty ? _showClearAllDialog : null,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text('Clear All'),
          ),
        ],
      ),
    );
  }

  Future<void> _showDeleteDialog(Comic comic) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text('Delete Download', style: TextStyle(color: Colors.white)),
            content: Text(
              'Delete "${comic.title}" from downloads?',
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
      await _deleteComic(comic);
    }
  }

  Future<void> _deleteComic(Comic comic) async {
    if (!_isServiceInitialized) {
      print('❌ Service not initialized, cannot delete comic');
      return;
    }

    try {
      // Remove from Hive using the service
      await _downloadService.deleteDownloadedChapter(
        comic.id.toString(),
        '', // We need to delete all chapters or implement a different method
      );

      // For now, we'll delete the entire comic
      await _downloadService.downloadsBox?.delete(comic.id.toString());

      // Refresh the list by triggering rebuild
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${comic.title}" removed from downloads'),
          backgroundColor: Colors.green,
        ),
      );

      print('🗑️ Deleted comic: ${comic.title}');
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to delete: $e'), backgroundColor: Colors.red));
    }
  }

  Future<void> _showClearAllDialog() async {
    final shouldClear = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            backgroundColor: Colors.grey[900],
            title: Text('Clear All Downloads', style: TextStyle(color: Colors.white)),
            content: Text(
              'Delete all downloaded comics? This cannot be undone.',
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
                child: Text('Clear All', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
    );

    if (shouldClear == true) {
      await _clearAllDownloads();
    }
  }

  Future<void> _clearAllDownloads() async {
    if (!_isServiceInitialized) {
      print('❌ Service not initialized, cannot clear downloads');
      return;
    }

    try {
      await _downloadService.downloadsBox?.clear();

      // Refresh the list by triggering rebuild
      setState(() {});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('All downloads cleared'), backgroundColor: Colors.green),
      );

      print('🗑️ Cleared all downloads');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to clear downloads: $e'), backgroundColor: Colors.red),
      );
    }
  }
}
