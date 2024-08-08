import 'dart:io';
import 'package:cancer/utilities/markdown_regex.dart';
import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:typed_data';
import 'package:cancer/constants.dart';
import 'package:clipboard/clipboard.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:share_plus/share_plus.dart';

class CustomChatCard extends StatelessWidget {
  CustomChatCard({
    super.key,
    required String text,
    required double textScaling,
    required this.user,
    this.imageBytes,
    this.image,
  })  : _text = text,
        _textScaling = textScaling;

  final String _text;
  final double _textScaling;
  final XFile? image;
  final Uint8List? imageBytes;
  final bool user;
  MarkdownRegex mr = MarkdownRegex();
  @override
  Widget build(BuildContext context) {
    if (_text != '+++---1') {
      return Container(
        margin: EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          borderRadius: (BorderRadius.circular(12)),
          color: user ? kUserCardColor : kModelCardColor,
        ),
        child: Column(
          children: [
            if (_text != '-1231-=')
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Text(
                  //   user ? "   User" : "   Model",
                  //
                  //   // i know, can be solved using padding, but why work harder
                  //   style: TextStyle(fontSize: 14, color: kButtonColor),
                  // ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Icon(
                      user ? Icons.account_circle_rounded : Icons.ac_unit,
                      color: kIconColor,
                    ),
                    // child: Container(
                    //   height: 20,
                    //   width: 30,
                    //   child: Lottie.asset(
                    //     'assets/loading.json',
                    //     fit: BoxFit.fill,
                    //   ),
                    // ),
                  ),

                  Row(
                    children: [
                      IconButton(
                          icon: Icon(
                            user ? null : Icons.share,
                            color: kButtonColor,
                          ),
                          onPressed: () async {
                            // removing markdown
                            String markdown = _text;

                            await Share.share(mr.convertToPlainText(markdown));
                          }),
                      IconButton(
                        onPressed: () {
                          FlutterClipboard.copy(_text);
                          ScaffoldMessenger.of(context)
                              .showSnackBar(const SnackBar(
                            duration: Duration(milliseconds: 1500),
                            content: Text(
                              textAlign: TextAlign.center,
                              "Text copied to Clipboard",
                              style: TextStyle(color: Colors.white70),
                            ),
                            backgroundColor: Colors.black87,
                          ));
                        },
                        icon: Icon(
                          Icons.copy,
                          size: 20,
                          color: kButtonColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            if (image != null)
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black12),
                ),
                child: Image.file(File(image!.path)),
              ),
            if (imageBytes != null)
              Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.black12),
                  ),
                  child: Image.memory(imageBytes!)),
            _text != '-1231-='
                ? Markdown(
                    padding: EdgeInsets.only(
                        top: 0, left: 16, right: 16, bottom: 16),
                    shrinkWrap: true,
                    data: _text,
                    selectable: true,
                    physics: const ScrollPhysics(),
                    styleSheet: MarkdownStyleSheet(
                      textScaler: TextScaler.linear(_textScaling),
                    ),
                  )
                : Lottie.asset('assets/humanThinkingGears.json', repeat: true),
          ],
        ),
      );
    }
    return SizedBox(
      height: 1,
    );
  }
}
