import 'package:comiksan/pages/comick_details.dart';
import 'package:comiksan/pages/download_page.dart';
import 'package:comiksan/providers/comic_providers.dart';
import 'package:comiksan/section/comiccard.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Followingsection extends StatefulWidget {
  const Followingsection({super.key});

  @override
  State<Followingsection> createState() => _FollowingsectionState();
}

class _FollowingsectionState extends State<Followingsection> with AutomaticKeepAliveClientMixin {
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);
    return Consumer<ComicProvider>(
      builder: (context, comicProvider, child) {
        print('🔴 ComicProvider consumer rebuilding');

        final comics = comicProvider.comics;
        print('🔴 Comics count: ${comics.length}');

        // Handle error state
        if (comicProvider.error.isNotEmpty) {
          return Center(
            child: Text(
              "Error loading comics: ${comicProvider.error}",
              style: const TextStyle(color: Colors.white),
            ),
          );
        }

        // Handle empty state
        if (comics.isEmpty) {
          return const Center(
            child: Text("No comics in your following list", style: TextStyle(color: Colors.white)),
          );
        }

        // Show comics when data is available
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Following", style: TextStyle(fontSize: 18, color: Colors.amber)),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children:
                        comics.map((comic) {
                          return SizedBox(
                            width: (MediaQuery.of(context).size.width - 40) / 3, // 3 items per row
                            child: ComicCard(
                              downloadIcon: Icons.download,
                              comic: comic,
                              onDownloadTap: () {
                                Navigator.of(
                                  context,
                                  rootNavigator: true,
                                ).push(MaterialPageRoute(builder: (_) => Downloadpage()));
                              },
                            ),
                          );
                        }).toList(),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}
