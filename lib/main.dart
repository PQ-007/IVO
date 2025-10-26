import 'package:flutter/material.dart';
import 'package:forui/theme.dart';
import 'package:ivo/view/widget_tree.dart';
import 'package:ivo/data/notifiers.dart';
import 'theme/dark-theme.dart';
import 'theme/light-theme.dart';

void main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap with ValueListenableBuilder to listen for theme changes
    return ValueListenableBuilder<bool>(
      valueListenable: isDarkThemeNotifier,
      builder: (context, isDark, _) {
        // Select theme based on isDark value
        final theme = isDark ? blueDark : blueLight;

        return MaterialApp(
          debugShowCheckedModeBanner: false,
          builder: (_, child) => FAnimatedTheme(data: theme, child: child!),
          home: const WidgetTree(),
          theme: theme.toApproximateMaterialTheme(),
        );
      },
    );
  }
}
