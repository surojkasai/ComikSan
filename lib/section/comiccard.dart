import 'package:flutter/material.dart';

//this code is responsible for the homepage comicks structure
class ComicCard extends StatelessWidget {
  final IconData? downloadIcon;
  final String imagePath;
  final String chapter;
  final String translator;
  final String title;
  final String time;

  ComicCard({
    super.key,
    required this.imagePath,
    required this.title,
    required this.chapter,
    required this.time,
    required this.translator,
    this.downloadIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Container(
            alignment: Alignment.centerLeft,
            height: 150,
            width: 110,
            child:
            //Image.asset(imagePath, fit: BoxFit.cover),
            Stack(
              alignment: Alignment.bottomRight,
              children: <Widget>[
                Image.asset(imagePath, fit: BoxFit.cover),
                if (downloadIcon != null)
                  IconButton(
                    onPressed: () {},
                    icon: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.white, // White border color
                          width: 2.0, // Border width
                        ),
                        borderRadius: BorderRadius.circular(
                          8.0,
                        ), // Optional: if you want rounded corners
                      ),
                      child: Icon(
                        downloadIcon,
                        color: Colors.black, // Make the icon black
                        size: 40,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        SizedBox(height: 6),
        Text("Chap $chapter", style: TextStyle(color: Colors.white)),
        Text(time, style: TextStyle(color: Colors.white70, fontSize: 12)),
        Text(translator, style: TextStyle(color: Colors.white54, fontSize: 12)),
        SizedBox(height: 2),
        Text(
          title,
          style: TextStyle(color: Colors.white, fontSize: 12),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
