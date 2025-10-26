import 'package:flutter/material.dart';
import 'package:forui/forui.dart';
import 'package:ivo/components/MyAppbarr.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppBar(titleText: "Library"),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          FTabs(
            initialIndex: 0,
            onPress: (index) {},
            children: const [
              FTabEntry(label: Text('Folders'), child: Placeholder()),
              FTabEntry(label: Text('Decks'), child: Placeholder()),
              FTabEntry(label: Text('Playlist'), child: Placeholder()),
            ],
          ),
        ],
      ),
    );
  }
}
