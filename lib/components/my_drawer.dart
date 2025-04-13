import 'package:flutter/material.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          DrawerHeader(
            child: Center(
              child: Icon(
                Icons.music_note,
                size: 40,
                color: Theme.of(context).colorScheme.inversePrimary,
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.only(left: 25.0, top: 25.0),
            child: ListTile(
              title: const Text("H O M E"),
              leading: Icon(Icons.home),
              onTap: () {},
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 25.0, top: 10.0),
            child: ListTile(
              title: const Text(" S E T T I N G S"),
              leading: Icon(Icons.settings),
              onTap: () {},
            ),
          ),
        ],
      ),
    );
  }
}
