import 'package:flutter/material.dart';

class MyRecent extends StatelessWidget {
  const MyRecent({super.key, required this.recentItems, required this.type});
  final List<String> recentItems;
  final String type; // "flashcard", "folder", etc.

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 120,
      child: PageView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: null,
        controller: PageController(initialPage: 0),
        itemBuilder: (context, index) {
          int actualIndex = index % recentItems.length;
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Dismissible(
              key: Key(recentItems[actualIndex]),
              direction: DismissDirection.endToStart,
              onDismissed: (direction) {
                recentItems.removeAt(actualIndex);
              },
              child: SizedBox(
                child: Card(
                  elevation: 5,
                  child: Container(
                    width: 100,
                    height: 100,
                    alignment: Alignment.center,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.folder,
                          size: 40,
                          color: Colors.white,
                        ), // Your icon
                        SizedBox(height: 8),
                        Text(
                          recentItems[actualIndex],
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
