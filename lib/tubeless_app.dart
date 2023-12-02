import 'package:flutter/material.dart';
import 'home_page.dart';

class TubeLessApp extends StatelessWidget {
  const TubeLessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TubeLess',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)
            .copyWith(background: Colors.black),
      ),
      home: const HomePage(title: 'Home'),
    );
  }
}
