import 'package:flutter/material.dart';

class AddPlaylistPage extends StatefulWidget {
  const AddPlaylistPage({super.key});

  @override
  State<AddPlaylistPage> createState() => _AddPlaylistPageState();
}

class _AddPlaylistPageState extends State<AddPlaylistPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Playlist"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // Handle folder creation logic here
              // For example, you can show a SnackBar or navigate to another page
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Deck created')));
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}
