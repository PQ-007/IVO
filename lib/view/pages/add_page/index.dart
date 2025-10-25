import 'package:flutter/material.dart';
import 'package:ivo/data/notifiers.dart';
import 'package:ivo/view/pages/add_page/create_deck/create_deck_page.dart';
import 'package:ivo/view/pages/add_page/create_folder/add_folder_page.dart';
import 'package:ivo/view/pages/add_page/create_playlistp/add_playlist_page.dart';

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
            return CreateDeckPage();
          } else if (value == 'Playlist') {
            return AddPlaylistPage();
          }
          return const Center(child: Text('Unknown State'));
        },
      ),
    );
  }
}
