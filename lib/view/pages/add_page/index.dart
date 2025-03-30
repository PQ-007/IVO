import 'package:flutter/material.dart';

import 'package:test_project/data/notifiers.dart';
import 'package:test_project/view/pages/add_page/add_deck_page.dart';
import 'package:test_project/view/pages/add_page/add_folder_page.dart';
import 'package:test_project/view/pages/add_page/add_playlist_page.dart';

class AddPage extends StatelessWidget {
  const AddPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: ValueListenableBuilder(
        valueListenable: selectedAddPageNotifier,
        builder: (context, value, child) {
          if (value == null) {
            return const Center(child: Text('Select to Create'));
          } else if (value == 'Folder') {
            return AddFolderPage();
          } else if (value == 'Deck') {
            return AddDeckPage();
          } else if (value == 'Playlist') {
            return AddPlaylistPage();
          }
          return const Center(child: Text('Unknown State'));
        },
      ),
    );
  }
}
