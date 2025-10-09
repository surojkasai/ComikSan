// import 'package:comiksan/pages/comick_details.dart';
// import 'package:comiksan/providers/comic_providers.dart';
// import 'package:comiksan/section/comiccard.dart';
// import 'package:flutter/material.dart';
// import 'package:provider/provider.dart';

// class Trendingsection extends StatelessWidget {
//   const Trendingsection({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Consumer<ComicProvider>(
//       builder: (context, comicProvider, child) {
//         print('🔴 ComicProvider consumer rebuilding');

//         final comics = comicProvider.comics;
//         print('🔴 Comics count: ${comics.length}');
//         // Handle loading state
//         // if (comicProvider.isLoading) {
//         //   return const Center(child: CircularProgressIndicator());
//         // }

//         // Handle error state
//         if (comicProvider.error.isNotEmpty) {
//           return Center(
//             child: Text(
//               "Error loading comics: ${comicProvider.error}",
//               style: const TextStyle(color: Colors.white),
//             ),
//           );
//         }

//         // Handle empty state
//         if (comics.isEmpty) {
//           return const Center(
//             child: Text("No comics in your following list", style: TextStyle(color: Colors.white)),
//           );
//         }

//         // Show comics when data is available
//         return Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text("Trending", style: TextStyle(fontSize: 18, color: Colors.amber)),
//             const SizedBox(height: 8),
//             SingleChildScrollView(
//               scrollDirection: Axis.horizontal,
//               child: Row(
//                 children:
//                     comics.map((comic) {
//                       return GestureDetector(
//                         onTap: () {
//                           // print('Comic chapters count: ${comic.chapters.length}');

//                           // If chapters are too many, process them asynchronously
//                           // if (comic.chapters.length > 50) {
//                           //   print('WARNING: Large comic data - ${comic.chapters.length} chapters');
//                           // }
//                           Navigator.push(
//                             context,
//                             MaterialPageRoute(builder: (context) => ComickDetails(comic: comic)),
//                           );
//                         },
//                         child: Padding(
//                           padding: const EdgeInsets.all(0),
//                           child: ComicCard(
//                             downloadIcon: Icons.download,
//                             comic: comic,
//                             chapter: "Latest",
//                             time: "Recently",
//                             translator: comic.author,
//                           ),
//                         ),
//                       );
//                     }).toList(),
//               ),
//             ),
//           ],
//         );
//       },
//     );
//   }
// }
