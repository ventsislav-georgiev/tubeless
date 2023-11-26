import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const TubeLessApp());
}

class TubeLessApp extends StatelessWidget {
  const TubeLessApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'TubeLess',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const HomePage(title: 'Home'),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});

  final String title;

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  Future<List<Widget>> _loadData() async {
    var client = http.Client();

    try {
      var config = await DefaultAssetBundle.of(context)
          .loadString('assets/appsettings.json');
      var decodedConfig = jsonDecode(config) as Map;

      var queryParams = {
        'part': 'snippet',
        'maxResults': '50',
        'q': 'dotnet',
        'key': decodedConfig['apiKey'] as String,
        'type': 'video'
      };

      var address = Uri.https(
          'content-youtube.googleapis.com', '/youtube/v3/search', queryParams);

      var response = await client.get(address);
      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;

      var list = <Widget>[];

      for (var item in decodedResponse['items'] as List) {
        var snippet = item['snippet'] as Map;
        var title = snippet['title'] as String;
        var channelTitle = snippet['channelTitle'] as String;
        var thumbnails = snippet['thumbnails'] as Map;
        var defaultThumbnail = thumbnails['default'] as Map;
        var thumbnailUrl = defaultThumbnail['url'] as String;

        list.add(ListTile(
          leading: Image.network(thumbnailUrl),
          title: Text(title),
          subtitle: Text(channelTitle),
        ));
      }

      if (kDebugMode) {
        print(decodedResponse);
      }

      return list;
    } finally {
      client.close();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Widget>>(
        future: _loadData(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView(
              children: snapshot.data!,
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }
}
