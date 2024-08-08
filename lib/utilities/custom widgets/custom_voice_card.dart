import 'dart:io';
import 'package:cancer/model/custom_gemini_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'dart:typed_data';
import 'package:cancer/constants.dart';
import 'package:clipboard/clipboard.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';

class CustomVoiceCard extends StatelessWidget {
  CustomVoiceCard({
    super.key,
    String? text,
    required this.user,
    this.showAnimation = false,
    this.child,
    this.onShareClick,
    this.onStopClick,
  }) : _text = text;

  final String? _text;
  final bool user, showAnimation;
  final Widget? child;
  VoidCallback? onStopClick;
  VoidCallback? onShareClick;
  CustomGeminiModel gm = CustomGeminiModel();

  @override
  Widget build(BuildContext context) {
    return Consumer<CustomGeminiModel>(
      builder: (context, gm, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(
            borderRadius: (BorderRadius.circular(12)),
            color: user ? kUserCardColor : kModelCardColor,
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    child: Icon(
                      user ? Icons.account_circle_rounded : Icons.ac_unit,
                      color: kIconColor,
                    ),
                  ),
                  Row(
                    children: [
                      !user
                          ? IconButton(
                              icon: Icon(
                                Icons.stop_circle_outlined,
                                color: kButtonColor,
                              ),
                              onPressed: onStopClick,
                            )
                          : const SizedBox(
                              height: 1,
                            ),
                      !user
                          ? IconButton(
                              icon: Icon(
                                Icons.share,
                                color: kButtonColor,
                              ),
                              onPressed: onShareClick,
                            )
                          : SizedBox(
                              height: 1,
                            ),
                      !user
                          ? IconButton(
                              onPressed: () {
                                FlutterClipboard.copy(_text!);
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
                            )
                          : SizedBox(
                              height: 1,
                            ),
                    ],
                  ),
                ],
              ),
              Flexible(child: Markdown(data: _text!)),
              showAnimation
                  ? Lottie.asset('assets/humanThinkingGears.json',
                      height: 300, repeat: true)
                  : Container(),
            ],
          ),
        );
      },
    );
  }
}
