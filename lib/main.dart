import 'package:flutter/material.dart';
import 'ui/pages/explore_page.dart';
import 'ui/theme/ui_theme.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TMDB Movies',
      debugShowCheckedModeBanner: false,
      theme: buildUiTheme(),
      home: const ExplorePage(),
    );
  }
}
