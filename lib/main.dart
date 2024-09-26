// ignore_for_file: library_private_types_in_public_api, avoid_print

import 'dart:io';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  Gemini.init(apiKey: 'AIzaSyC4oVA9vNop5N159BnKfptf3W1Ib_SdyEY');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: Scaffold(
        body: MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final inputCtrl = TextEditingController();
  final List<String> _outputs = [];
  final gemini = Gemini.instance;
  File? _image;
  final ImagePicker picker = ImagePicker();

  void textInput(String text) {
    setState(() {
      _outputs.add('You : $text');
      inputCtrl.clear();
    });
    gemini
        .text(text)
        .then((value) => setState(() {
              _outputs.add('NGC BOX : ${value?.output ?? ''}');
            }))
        .catchError((e) => print(e));
  }

  void imageInput(String text, File image) {
    setState(() {
      _outputs.add('You : $text');
      inputCtrl.clear();
    });
    gemini
        .textAndImage(text: text, images: [image.readAsBytesSync()])
        .then((value) => setState(() {
              _outputs.add('NGC BOX : ${value?.output ?? ''}');
              _image?.delete();
              _image = null;
            }))
        .catchError((e) => print(e));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      appBar: AppBar(
          title: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: Text('NGC BOX',
            style: GoogleFonts.abyssinicaSil(
                fontSize: 20, fontWeight: FontWeight.bold)),
      )),
      body: SingleChildScrollView(
        clipBehavior: Clip.antiAlias,
        primary: false,
        child: Column(
          children: [
            ..._outputs.map((output) => Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: ClipRRect(
                    clipBehavior: Clip.antiAliasWithSaveLayer,
                    borderRadius: BorderRadiusDirectional.circular(12),
                    child: Align(
                      alignment: AlignmentDirectional.centerStart,
                      child: Card(
                        elevation: 20,
                        child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: Text(output,
                              style: GoogleFonts.actor(
                                  fontWeight: FontWeight.w500, fontSize: 15)),
                        ),
                      ),
                    ),
                  ),
                )),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Container(
          height: 60,
          decoration: BoxDecoration(
              border: Border.all(width: 3, color: Colors.black),
              borderRadius: BorderRadiusDirectional.circular(15)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0, horizontal: 10),
            child: TextField(
              controller: inputCtrl,
              decoration: InputDecoration(
                  disabledBorder: InputBorder.none,
                  border: InputBorder.none,
                  hintText: '  Search Something...',
                  hintStyle: GoogleFonts.adamina(
                      fontSize: 16, fontWeight: FontWeight.w500),
                  prefixIcon: IconButton(
                      onPressed: () => selectImage(),
                      icon: const Icon(CupertinoIcons.photo, size: 25)),
                  suffixIcon: IconButton(
                      onPressed: () {
                        if (_image != null) {
                          imageInput(inputCtrl.text, _image!);
                        } else {
                          textInput(inputCtrl.text);
                        }
                      },
                      icon: const Icon(Icons.send, size: 25))),
            ),
          ),
        ),
      ),
    );
  }

  Future<File?> selectImage() async {
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    _image = File(image!.path);
    return _image;
  }
}
