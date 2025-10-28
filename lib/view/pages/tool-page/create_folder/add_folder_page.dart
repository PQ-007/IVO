import 'package:flutter/material.dart';

class AddFolderPage extends StatefulWidget {
  const AddFolderPage({super.key});

  @override
  State<AddFolderPage> createState() => _AddFolderPageState();
}

class _AddFolderPageState extends State<AddFolderPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("New Folder"),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: () {
              // Handle folder creation logic here
              // For example, you can show a SnackBar or navigate to another page
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Folder created')));
              Navigator.pop(context);
            },
          ),
        ],
      ),
    );
  }
}


// ScaffoldMessenger.of(
//                     context,
//                   ).showSnackBar(SnackBar(content: Text('Folder created')));