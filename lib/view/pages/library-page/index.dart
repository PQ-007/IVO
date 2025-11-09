import 'package:flutter/material.dart';
import 'package:forui/forui.dart';

class LibraryPage extends StatelessWidget {
  const LibraryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            FTabs(
              initialIndex: 0,
              onPress: (index) {},
              children: const [
                FTabEntry(label: Text('Нийтлэл'), child: Text("ok")),
                FTabEntry(label: Text('Флаш карт'), child: Placeholder()),
                FTabEntry(label: Text('Аудио карт'), child: Placeholder()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
