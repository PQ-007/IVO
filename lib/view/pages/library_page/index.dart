import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Library'),
          bottom: const TabBar(
            tabs: [
              Tab(text: 'Folders'),
              Tab(text: 'Decks'),
              Tab(text: 'Playlists'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [FoldersTab(), DecksTab(), PlaylistsTab()],
        ),
      ),
    );
  }
}

class DecksTab extends StatelessWidget {
  const DecksTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('decks').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final decks = snapshot.data!.docs;
        print(decks.length);
        return ListView.builder(
          itemCount: decks.length,
          itemBuilder: (context, index) {
            var deck = decks[index];
            return ListTile(
              title: Text(deck['title'] ?? 'Untitled Deck'),
              subtitle: Text('Cards: ${deck['cardCount'] ?? 0}'),
            );
          },
        );
      },
    );
  }
}

class FoldersTab extends StatelessWidget {
  const FoldersTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('folders').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final folders = snapshot.data!.docs;

        return ListView.builder(
          itemCount: folders.length,
          itemBuilder: (context, index) {
            var folder = folders[index];
            return ListTile(
              title: Text(folder['name'] ?? 'No Name'),
              subtitle: Text(
                'Created at: ${folder['createdAt']?.toDate().toString() ?? 'Unknown'}',
              ),
            );
          },
        );
      },
    );
  }
}

class PlaylistsTab extends StatelessWidget {
  const PlaylistsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('playlists').snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData)
          return const Center(child: CircularProgressIndicator());

        final playlists = snapshot.data!.docs;

        return ListView.builder(
          itemCount: playlists.length,
          itemBuilder: (context, index) {
            var playlist = playlists[index];
            return ListTile(
              leading: const Icon(Icons.playlist_play),
              title: Text(playlist['title'] ?? 'Untitled Playlist'),
              subtitle: Text(playlist['description'] ?? 'No description'),
            );
          },
        );
      },
    );
  }
}
