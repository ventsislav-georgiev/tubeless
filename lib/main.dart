import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue)
            .copyWith(background: Colors.black),
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
        'part': 'snippet,statistics,contentDetails',
        'maxResults': '50',
        'key': decodedConfig['apiKey'] as String,
        'chart': 'mostPopular',
      };

      var address = Uri.https(
          'content-youtube.googleapis.com', '/youtube/v3/videos', queryParams);

      var response = await client.get(address);
      var decodedResponse = jsonDecode(utf8.decode(response.bodyBytes)) as Map;

      var list = <Widget>[];
      var autofocus = true;

      for (var item in decodedResponse['items'] as List) {
        var snippet = item['snippet'] as Map;
        var title = snippet['title'] as String;
        var channelTitle = snippet['channelTitle'] as String;

        var publishedAtDate = DateTime.parse(snippet['publishedAt'] as String);
        var publishedAtDiff = DateTime.now().difference(publishedAtDate);
        var publishedAt = publishedAtDiff.inDays > 365
            ? '${(publishedAtDiff.inDays / 365).floor()} years ago'
            : publishedAtDiff.inDays > 30
                ? '${(publishedAtDiff.inDays / 30).floor()} months ago'
                : publishedAtDiff.inDays > 1
                    ? '${publishedAtDiff.inDays} days ago'
                    : publishedAtDiff.inDays == 1
                        ? '1 day ago'
                        : publishedAtDiff.inHours > 1
                            ? '${publishedAtDiff.inHours} hours ago'
                            : publishedAtDiff.inHours == 1
                                ? '1 hour ago'
                                : publishedAtDiff.inMinutes > 1
                                    ? '${publishedAtDiff.inMinutes} minutes ago'
                                    : publishedAtDiff.inMinutes == 1
                                        ? '1 minute ago'
                                        : 'just now';

        var thumbnails = snippet['thumbnails'] as Map;
        var defaultThumbnail = thumbnails['default'] as Map;
        if (thumbnails['standard'] != null) {
          defaultThumbnail = thumbnails['standard'] as Map;
        } else if (thumbnails['high'] != null) {
          defaultThumbnail = thumbnails['high'] as Map;
        } else if (thumbnails['maxres'] != null) {
          defaultThumbnail = thumbnails['maxres'] as Map;
        } else if (thumbnails['medium'] != null) {
          defaultThumbnail = thumbnails['medium'] as Map;
        }
        var thumbnailUrl = defaultThumbnail['url'] as String;

        var statistics = item['statistics'] as Map;
        var viewCountRaw = int.parse(statistics['viewCount'] as String);
        var viewCount = viewCountRaw > 1000000
            ? '${(viewCountRaw / 1000000).toStringAsFixed(1)}M'
            : viewCountRaw > 1000
                ? '${(viewCountRaw / 1000).toStringAsFixed(1)}K'
                : viewCountRaw.toString();

        var contentDetails = item['contentDetails'] as Map;
        var durationRaw = contentDetails['duration'] as String;
        var duration = durationRaw
            .replaceAll('PT', '')
            .replaceAll('H', ':')
            .replaceAll('M', ':')
            .replaceAll('S', '');

        var durationSplit = duration.split(':');
        if (durationSplit.length == 3) {
          var durationHour = durationSplit[0];
          if (durationHour.length == 1) {
            durationHour = '0$durationHour';
          }
          var durationMin = durationSplit[1];
          if (durationHour.isNotEmpty && durationMin.length == 1) {
            durationMin = '0$durationMin';
          } else if (durationHour.isEmpty && durationMin.isEmpty) {
            durationMin = '00';
          }
          var durationSec = durationSplit[2];
          if (durationSec.length == 1) {
            durationSec = '0$durationSec';
          }
          duration = '$durationHour:$durationMin:$durationSec';
        } else if (durationSplit.length == 2) {
          var durationMin = durationSplit[0];
          var durationSec = durationSplit[1];
          if (durationSec.length == 1) {
            durationSec = '0$durationSec';
          } else if (durationSec.isEmpty) {
            durationSec = '00';
          }
          duration = '$durationMin:$durationSec';
        } else if (durationSplit.length == 1) {
          var durationSec = durationSplit[0];
          if (durationSec.length == 1) {
            durationSec = '0$durationSec';
          }
          duration = '00:$durationSec';
        }

        Focus? node;
        node = Focus(
            autofocus: autofocus,
            onKey: (focusNode, event) {
              if (event.runtimeType != RawKeyDownEvent) {
                return KeyEventResult.ignored;
              }

              if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
                if (list.first == node) {
                  return KeyEventResult.handled;
                }

                focusNode.previousFocus();
                return KeyEventResult.handled;
              }

              if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
                if (list.last == node) {
                  return KeyEventResult.handled;
                }

                focusNode.nextFocus();
                return KeyEventResult.handled;
              }

              return KeyEventResult.ignored;
            },
            child: Builder(builder: (context) {
              var hasFocus = Focus.of(context).hasFocus;
              var width = 350.0;
              var height = 180.0;

              return Container(
                width: width,
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Stack(
                      children: [
                        Image.network(
                          thumbnailUrl,
                          fit: BoxFit.fill,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) {
                              return SizedBox(
                                width: width,
                                height: height,
                                child: OverflowBox(
                                  minWidth: 318,
                                  maxWidth: 318,
                                  minHeight: 180,
                                  maxHeight: 240,
                                  child: child,
                                ),
                              );
                            } else {
                              return SizedBox(
                                width: width,
                                height: height,
                                child: const Center(
                                  child: CircularProgressIndicator(),
                                ),
                              );
                            }
                          },
                        ),
                        Positioned(
                          bottom: 10,
                          right: 10,
                          child: Container(
                            padding: const EdgeInsets.all(4),
                            color: Colors.black,
                            child: Text(
                              duration,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Container(
                      padding: const EdgeInsets.all(6),
                      color: hasFocus ? Colors.white : Colors.black,
                      constraints: const BoxConstraints(maxHeight: 70),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(title,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: hasFocus ? 14 : 12,
                                color: hasFocus ? Colors.black : Colors.white,
                              )),
                          Text(
                              '@$channelTitle • $viewCount views • $publishedAt',
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: hasFocus ? 12 : 10,
                                color: hasFocus
                                    ? Colors.grey[900]
                                    : Colors.white70,
                              )),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }));

        list.add(node);

        autofocus = false;
      }

      if (kDebugMode) {
        // print(decodedResponse);
      }

      return list;
    } catch (e) {
      if (kDebugMode) {
        print(e);
      }
      rethrow;
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
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.all(16),
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
