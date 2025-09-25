import 'package:comiksan/section/comiccard.dart';
import 'package:comiksan/util/headfooter.dart';
import 'package:flutter/material.dart';

class Downloadpage extends StatefulWidget {
  final VoidCallback? onTap;
  const Downloadpage({super.key, this.onTap});

  @override
  State<Downloadpage> createState() => _DownloadpageState();
}

class _DownloadpageState extends State<Downloadpage> {
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

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: Headfooter(
        topicon: Icon(Icons.category_outlined),
        body: SingleChildScrollView(
          child: Container(
            color: Colors.black,
            padding: EdgeInsets.all(10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              //mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text("Your Download's", style: TextStyle(fontSize: 18, color: Colors.amber)),
                SizedBox(height: 12),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children:
                      comics.map((comic) {
                        return SizedBox(
                          width: (MediaQuery.of(context).size.width - 40) / 3, // 3 items per row
                          child: ComicCard(
                            imagePath: comic['image']!,
                            title: comic['title']!,
                            chapter: comic['chapter']!,
                            time: comic['time']!,
                            translator: comic['translator']!,
                          ),
                        );
                      }).toList(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
