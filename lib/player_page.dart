import 'package:flutter/material.dart';

class PlayerPage extends StatelessWidget {
  final String youtubeId;

  const PlayerPage({super.key, required this.youtubeId });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Player for video $youtubeId"),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.pop(context);
          },
          child: const Text('Go back!'),
        ),
      ),
    );
  }
}