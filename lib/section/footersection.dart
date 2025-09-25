import 'package:comiksan/pages/comick_details.dart';
import 'package:comiksan/pages/download_page.dart';
import 'package:flutter/material.dart';

class Footersection extends StatefulWidget {
  //final VoidCallback onSettingsPressed;
  const Footersection({
    super.key,
    //required this.onSettingsPressed
  });

  @override
  State<Footersection> createState() => _FootersectionState();

  //void settings() {}
}

class _FootersectionState extends State<Footersection> {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          IconButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, '/');
            },
            icon: Icon(Icons.home, color: Colors.white),
          ),
          //IconButton(onPressed: () {}, icon: Icon(Icons.category_outlined)),
          IconButton(
            onPressed: () {},
            icon: Image.asset(
              'assets/images/categories.png',
              height: 20,
              width: 20,
              color: Colors.white,
            ),
          ),
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder:
                      (context) => Downloadpage(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => ComickDetails()),
                          );
                        },
                      ),
                ),
              );
            },
            icon: Icon(Icons.download),
            color: Colors.white,
          ),
          // IconButton(
          //   onPressed: widget.onSettingsPressed,
          //   icon: Icon(Icons.settings),
          // ),
        ],
      ),
    );
  }
}
