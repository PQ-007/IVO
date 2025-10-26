import 'package:flutter/material.dart';
import 'package:ivo/components/my_appbar.dart';
import 'package:ivo/components/my_recent.dart';
import 'package:ivo/components/my_searchbar.dart';


class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

void onSearch(String query) {
  print("Searching for: $query");
}

class _HomePageState extends State<HomePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(titleText: "Home"),
      body: SingleChildScrollView(
        child: Column(
          children: [
            MySearchbar(
              hintText: "Flashcard, Folder, Deck, Playlist...",
              onSearch: onSearch,
            ),
            const SizedBox(height: 20),
            
            const SizedBox(height: 20),
            MyRecent(recentItems: ['a', 'ok', 'l'], type: 'flashcard'),
          ],
        ),
      ),
    );
  }
}
