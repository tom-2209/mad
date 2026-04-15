import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';

void main() {
  runApp(MemeApp());
}

class MemeApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MemeHome(),
    );
  }
}

class MemeHome extends StatefulWidget {
  @override
  _MemeHomeState createState() => _MemeHomeState();
}

class _MemeHomeState extends State<MemeHome> {
  List memes = [];
  String imageUrl = "";

  TextEditingController topText = TextEditingController();
  TextEditingController bottomText = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchMemes();
  }

  Future<void> fetchMemes() async {
    var response =
    await http.get(Uri.parse("https://api.imgflip.com/get_memes"));

    var data = jsonDecode(response.body);

    setState(() {
      memes = data["data"]["memes"];
      imageUrl = memes[0]["url"];
    });
  }

  void generateMeme() {
    memes.shuffle();

    setState(() {
      imageUrl = memes[0]["url"];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Meme Generator"),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            /// IMAGE + TEXT OVERLAY
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  imageUrl.isEmpty
                      ? CircularProgressIndicator()
                      : Image.network(imageUrl),

                  /// TOP TEXT
                  Positioned(
                    top: 20,
                    child: Text(
                      topText.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 5,
                            color: Colors.black,
                            offset: Offset(2, 2),
                          )
                        ],
                      ),
                    ),
                  ),

                  /// BOTTOM TEXT
                  Positioned(
                    bottom: 20,
                    child: Text(
                      bottomText.text,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        shadows: [
                          Shadow(
                            blurRadius: 5,
                            color: Colors.black,
                            offset: Offset(2, 2),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: 10),

            /// INPUT FIELDS
            TextField(
              controller: topText,
              decoration: InputDecoration(labelText: "Top Text"),
              onChanged: (_) => setState(() {}),
            ),

            TextField(
              controller: bottomText,
              decoration: InputDecoration(labelText: "Bottom Text"),
              onChanged: (_) => setState(() {}),
            ),

            SizedBox(height: 10),

            /// BUTTON
            ElevatedButton(
              onPressed: generateMeme,
              child: Text("Generate Meme"),
            ),
          ],
        ),
      ),
    );
  }
}

/*
pubspec.yaml
name: meme_generate_through_api
description: A meme generator app using API

publish_to: 'none'

version: 1.0.0+1

environment:
  sdk: '^3.11.0'

dependencies:
  flutter:
    sdk: flutter

  http: ^1.2.0
  google_fonts: ^6.1.0

  cupertino_icons: ^1.0.8

dev_dependencies:
  flutter_test:
    sdk: flutter

  flutter_lints: ^4.0.0

flutter:
  uses-material-design: true
 */