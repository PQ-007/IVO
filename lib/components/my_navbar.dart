import 'package:flutter/material.dart';
import 'package:ivo/data/notifiers.dart';

class MyNavbar extends StatelessWidget {
  const MyNavbar({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: selectedPageNotifier,
      builder: (context, selectedPage, child) {
        return NavigationBar(
          height: 70,
          destinations: [
            NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
            NavigationDestination(icon: Icon(Icons.bar_chart), label: 'Stats'),
            NavigationDestination(icon: Icon(Icons.add), label: 'Add'),

            NavigationDestination(
              icon: Icon(Icons.library_books),
              label: 'Library',
            ),
            NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
          ],
          onDestinationSelected: (int value) {
            selectedPageNotifier.value = value;
            if (value == 2) {
              _showAddSelectionBottomSheet(context);
            }
          },
          selectedIndex: selectedPage,
        );
      },
    );
  }

  void _showAddSelectionBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Container(
          padding: EdgeInsets.all(20),
          height: 240,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                'Select to Create',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              ListTile(
                title: Text('Create Deck'),
                onTap: () {
                  Navigator.pop(context);
                  selectedAddPageNotifier.value = 'Deck';
                },
              ),

              ListTile(
                title: Text('Create Folder'),
                onTap: () {
                  Navigator.pop(context);
                  selectedAddPageNotifier.value = 'Folder';
                },
              ),

              ListTile(
                title: Text('Create Playlist'),
                onTap: () {
                  Navigator.pop(context);
                  selectedAddPageNotifier.value = 'Playlist';
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
