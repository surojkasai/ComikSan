import 'package:comiksan/util/headfooter.dart';
import 'package:flutter/material.dart';

class ComickDetails extends StatefulWidget {
  const ComickDetails({super.key});

  @override
  State<ComickDetails> createState() => _ComickDetailsState();
}

class _ComickDetailsState extends State<ComickDetails> {
  final details = [
    {'label': 'Origination:', 'value': 'Manhwa'},
    {'label': 'Author:', 'value': 'Koyoharu'},
    {'label': 'Genre:', 'value': 'Action'},
    {'label': 'Status:', 'value': 'Completed'},
    {'label': 'Rating:', 'value': '9.5'},
  ];

  @override
  Widget build(BuildContext context) {
    return Headfooter(
      //i have used the topicon here so that i can use same button at different places and perform different actions and icons
      topicon: Icon(Icons.search),

      body: SingleChildScrollView(
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight:
                MediaQuery.of(context).size.height - kToolbarHeight - kBottomNavigationBarHeight,
          ),
          child: Container(
            padding: EdgeInsets.all(10),
            color: Colors.black,
            child: Column(
              children: [
                Text('Title', style: TextStyle(fontSize: 25, color: Colors.white)),
                Container(
                  //color: Colors.blueGrey,
                  height: 300,
                  width: double.infinity,
                  child: Row(
                    children: [
                      Container(
                        //color: Colors.red,
                        height: 250,
                        width: 150,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(22),
                          child: Image.asset('assets/bookImages/Demon_Slayer.jpg'),
                        ),
                      ),

                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(top: 20, right: 10, left: 20),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ...details
                                  .map(
                                    (item) => Row(
                                      children: [
                                        Text(
                                          item['label']!,
                                          style: TextStyle(fontSize: 15, color: Colors.white),
                                        ),
                                        SizedBox(width: 4),
                                        Text(
                                          item['value']!,
                                          style: TextStyle(fontSize: 15, color: Colors.white),
                                        ),
                                      ],
                                    ),
                                  )
                                  .toList(),

                              const SizedBox(height: 10),
                              Flexible(
                                child: TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    minimumSize: Size(100, 50),
                                  ),
                                  child: Text(
                                    'Continue',
                                    style: TextStyle(fontSize: 15, color: Colors.white),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Flexible(
                                child: TextButton(
                                  onPressed: () {},
                                  style: TextButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    minimumSize: Size(100, 50),
                                  ),

                                  child: Text(
                                    'Reading',
                                    style: TextStyle(fontSize: 15, color: Colors.white),
                                  ),
                                ),
                              ),
                              //IconButton(onPressed: () {}, icon: Icon(Icons.download_for_offline)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Text('Description', style: TextStyle(color: Colors.white, fontSize: 20)),
                Text(
                  'Description DescriptionDescriptionDescription',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
