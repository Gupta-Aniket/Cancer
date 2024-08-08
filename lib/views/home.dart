// triggered on "🐍"
import 'dart:io';
import 'dart:typed_data';
import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:cancer/model/storage_model.dart';
import 'package:cancer/views/drawer.dart';
import 'package:cancer/model/custom_gemini_model.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:cancer/utilities/custom%20widgets/custom_chat_card.dart';
import 'package:cancer/constants.dart';
import 'package:cancer/utilities/emoji/emoji_provider.dart';

import '../utilities/emoji/custom_model_emoji_icon.dart';

class Home extends StatefulWidget {
  Home(
      {super.key,
      this.request = '+++---1',
      this.response = '+++---1',
      this.displayImage});
  final String request, response;
  String? displayImage;
  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late String _request;
  late String _response;
  late XFile? _selectedImage;
  XFile? _displayImage;
  late bool _imageSelected;
  void initState() {
    super.initState();
    // Initialize _request and _response with the values passed from the Home widget
    _request = widget.request;
    _response = widget.response;
    _selectedImage =
        widget.displayImage != null ? XFile(widget.displayImage!) : null;
    _displayImage = _selectedImage;
    _imageSelected = widget.displayImage != null ? true : false;
  }

  int _modelNumber = 2;
  double _textScaling = 1.25;
  double _baseScaleFactor = 1.0;

  CustomGeminiModel gm = CustomGeminiModel();
  final TextEditingController _controller = TextEditingController();
  HiveStorage hiveStorage = HiveStorage();

  Future<void> _sendMessage(BuildContext context) async {
    _request = _controller.text;
    setState(() {});
    _controller.clear();

    if (_imageSelected && _request.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        margin: const EdgeInsets.symmetric(horizontal: 50, vertical: 12),
        behavior: SnackBarBehavior.floating,
        duration: const Duration(milliseconds: 1500),
        content: Text(
          textAlign: TextAlign.center,
          "Prompt can't be empty!!",
          style: TextStyle(color: kButtonColor),
        ),
        backgroundColor: Colors.black87,
      ));
      return;
    }
    if (_request.isNotEmpty) {
      setState(() {
        _response = "-1231-=";
        _request = _request;
        _displayImage = _selectedImage;
        _selectedImage = null;
      });
      final geminiModel =
          Provider.of<CustomGeminiModel>(context, listen: false);
      // _response = " ${(await geminiModel.geminiText(_request, _displayImage))}";
      if (_displayImage != null) {
        print('with image');
        _response =
            (await geminiModel.genAiImageAndText(_request, _displayImage!))!;
        hiveStorage.addEntry(
            request: _request,
            modelNumber: _modelNumber,
            response: _response,
            requestImage: _displayImage!.path.toString());
      } else {
        print("without image");
        _response = (await geminiModel.genAiText(_request))!;
        hiveStorage.addEntry(
          request: _request,
          modelNumber: _modelNumber,
          response: _response,
        );
      }
    }
    setState(() {
      _response = _response;
    });
  }

  void _pickImage(BuildContext context) async {
    ImagePicker _picker = ImagePicker();
    XFile? _image = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (_image != null) {
      setState(() {
        _selectedImage = _image;
        _imageSelected = true;
      });
    }

    // XFile? img = image.scaleD
    // TODO: Resize images got from camera, as they are too good and we dont need that kind of image data, the app will work on less good images as well
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final String _greetMessage = DateTime.now().hour < 12
      ? "Good Morning,"
      : DateTime.now().hour < 16
          ? "Good Afternoon,"
          : "Good Evening,";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: Center(
                child: AnimatedTextKit(
                  animatedTexts: [
                    ColorizeAnimatedText(
                      _greetMessage,
                      textStyle: TextStyle(
                        fontSize: 30,
                      ),
                      colors: [Colors.red, Color(0Xff007bff)],
                      speed: Duration(milliseconds: 200),
                    ),
                    ColorizeAnimatedText(
                      'Aniket Gupta',
                      textStyle: TextStyle(fontSize: 30),
                      colors: [Color(0Xff007bff), Colors.red],
                      speed: Duration(milliseconds: 200),
                    ),
                  ],
                  repeatForever: false,
                  totalRepeatCount: 1,
                ),
              ),
            ),
          ],
        ),
        leading: GestureDetector(
          child: const Icon(
            Icons.menu_rounded,
            size: 30,
          ),
          onTap: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        centerTitle: true,
        actions: [
          CusomModelIcon(
            emojiIdx: _modelNumber,
          ),
        ],
      ),
      drawerEnableOpenDragGesture: true,
      drawer: DrawerPage(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Expanded(
                child: SingleChildScrollView(
                  // reverse: true,
                  // reverse works but always put it at the end, other things work as expected. keeping it on for now
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomChatCard(
                        text: _request,
                        textScaling: _textScaling,
                        user: true,
                        image: _imageSelected ? _displayImage : null,
                      ),

                      GestureDetector(
                        onScaleStart: (details) {
                          _baseScaleFactor = _textScaling;
                        },
                        onScaleUpdate: (details) {
                          setState(() {
                            _textScaling = (_baseScaleFactor * details.scale)
                                .clamp(0.5, 3.0);
                          });
                        },
                        child: CustomChatCard(
                          text: _response,
                          textScaling: _textScaling,
                          user: false,
                        ),
                      ),
                      // SizedBox(
                      //   height: 30,
                      // )
                    ],
                  ),
                ),
              ),
              // Text Box below this ------------------------------
              Consumer<CustomGeminiModel>(builder: (context, gm, child) {
                child:
                return Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    const SizedBox(
                      height: 5,
                    ),
                    if (_selectedImage != null)
                      Stack(
                        children: [
                          Container(
                            width: double.infinity,
                            child: Image.file(
                              height: 70,
                              // color: Colors.transparent,
                              File(_selectedImage!.path),
                            ),
                            decoration:
                                BoxDecoration(color: Colors.transparent),
                          ),
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _selectedImage = null;
                              });
                            },
                            icon: const Icon(
                              Icons.cancel,
                              // color: Colors.black,
                            ),
                          ),
                        ],
                      ),
                    const SizedBox(
                      height: 5,
                    ),
                    TextField(
                      autofocus: false,
                      maxLines: 10,
                      minLines: 1,
                      readOnly: gm.isLoading ? true : false,
                      controller: _controller,
                      decoration: InputDecoration(
                        prefixIcon: IconButton(
                          icon: Icon(
                            Icons.image_search_outlined,
                            color: kButtonColor,
                          ),
                          onPressed: () {
                            _pickImage(context);
                          },
                        ),
                        suffixIcon: IconButton(
                          icon: gm.isLoading
                              ? Icon(
                                  Icons.timer,
                                  color: kButtonColor,
                                )
                              : Icon(
                                  Icons.send,
                                  color: kButtonColor,
                                ),
                          onPressed: () async {
                            await _sendMessage(context);
                          },
                        ),
                        hintText: gm.isLoading
                            ? "Loading..."
                            : "Type your message...",
                        filled: true,
                        border: const OutlineInputBorder(
                          borderRadius: BorderRadius.vertical(
                              top: Radius.circular(12),
                              bottom: Radius.circular(19)),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            vertical: 15, horizontal: 20),
                      ),
                    ),
                  ],
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
