import 'package:comiksan/section/comiccard.dart';
import 'package:flutter/material.dart';

class Trendingsection extends StatelessWidget {
  final VoidCallback? onTap;
  const Trendingsection({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    // This data would usually come from your backend or database
    final comics = [
      {
        'image': 'assets/bookImages/Demon_Slayer.jpg',
        'title': 'Demon Slayer',
        'chapter': '92',
        'time': '5 hours ago',
        'translator': 'Asurascans',
      },
      {
        'image': 'assets/bookImages/Demon_Slayer.jpg',
        'title': 'God of Martial Arts',
        'chapter': '702',
        'time': '5 hours ago',
        'translator': 'Official',
      },
      {
        'image': 'assets/bookImages/Demon_Slayer.jpg',
        'title': 'The Knight King',
        'chapter': '113',
        'time': '6 hours ago',
        'translator': 'Asurascans',
      },
      {
        'image': 'assets/bookImages/Demon_Slayer.jpg',
        'title': 'The Knight King',
        'chapter': '113',
        'time': '6 hours ago',
        'translator': 'Asurascans',
      },
    ];

    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Trending", style: TextStyle(fontSize: 18, color: Colors.amber)),
          SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children:
                  comics.map((comic) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 2.0),
                      child: ComicCard(
                        downloadIcon: Icons.download,
                        imagePath: comic['image']!,
                        title: comic['title']!,
                        chapter: comic['chapter']!,
                        time: comic['time']!,
                        translator: comic['translator']!,
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
