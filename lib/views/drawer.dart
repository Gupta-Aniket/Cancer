import 'package:flutter/material.dart';
import 'package:cancer/constants.dart';
import 'package:cancer/model/custom_gemini_model.dart';
import 'package:cancer/model/storage_model.dart';
import 'package:cancer/views/chat_page.dart';
import 'package:cancer/views/voice_search.dart';
import 'package:url_launcher/url_launcher.dart';
import '../utilities/custom widgets/custom_alert_box.dart';
import '../utilities/emoji/custom_emoji.dart';
import 'package:provider/provider.dart';
import 'package:cancer/utilities/emoji/emoji_provider.dart';

import 'home.dart';

class DrawerPage extends StatefulWidget {
  @override
  State<DrawerPage> createState() => _DrawerPageState();
}

class _DrawerPageState extends State<DrawerPage> {
  HiveStorage hiveStorage = HiveStorage();
  final Uri _url = Uri.parse(
      'https://www.businesstoday.in/technology/news/story/microsofts-water-usage-surges-by-thousands-of-gallons-after-the-launch-of-chatgpt-study-397951-2023-09-11');
  final List<String> emojiList = kEmojiList;

  @override
  Widget build(BuildContext context) {
    int waterGlasses = hiveStorage.getWaterData();
    List<dynamic> modelHistory = hiveStorage.retrieveEntries().toList();
    // final List<dynamic> modelNumber = modelHistory
    //     .where((item) => item['model'] != null)
    //     .map((item) => item['model'])
    //     .toSet()
    //     .toList();
    // print(modelHistory);
    // final List<dynamic> listTitle =
    //     modelHistory.map((item) => item['request']['text']).toSet().toList();
    // print(modelHistory);
    final emojiProvider = Provider.of<EmojiProvider>(context);
    return Container(
      color: Colors.black,
      width: MediaQuery.of(context).size.width * 0.85,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          SizedBox(height: 50),
          ListTile(
            leading: GestureDetector(
              child: Icon(
                Icons.chevron_left,
                size: 40,
              ),
              onTap: () => Navigator.of(context).pop(),
            ),
          ),
          Container(
            padding: EdgeInsets.all(8),
            decoration: kBorderDecoration,
            width: double.infinity,
            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            height: 70,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: emojiList.length,
              itemBuilder: (BuildContext context, int index) {
                return CustomEmoji(
                  emoji: emojiList[index],
                  onTap: () {
                    emojiProvider.selectEmoji(index);
                    switch (index) {
                      // using 2 pops, one for the drawer, and the other for the current screen, do not want to have too much code on the stack
                      case 0:
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => const ChatPage()));
                      case 1:
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.of(context).push(MaterialPageRoute(
                            builder: (context) => VoiceSearch()));
                      case 2:
                        Navigator.pop(context);
                        Navigator.pop(context);
                        Navigator.of(context).push(
                            MaterialPageRoute(builder: (context) => Home()));
                    }
                  },
                  isSelected: index == emojiProvider.selectedIdx,
                );
              },
            ),
          ),
          SizedBox(
            height: 5,
          ),
          Container(
            padding: EdgeInsets.only(top: 8, left: 12, bottom: 8, right: 0),
            decoration: kBorderDecoration,
            width: double.infinity,
            margin: EdgeInsets.symmetric(vertical: 0, horizontal: 12),
            height: 70,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                RichText(
                  text: TextSpan(
                    children: <TextSpan>[
                      TextSpan(
                        text: 'The amount of water consumed :\n',
                      ),
                      TextSpan(
                        text: (waterGlasses * 0.10).toStringAsFixed(2),
                        style: TextStyle(color: kIconColor, fontSize: 18),
                      ),
                      TextSpan(text: ' glass(es) or about '),
                      TextSpan(
                        text: (waterGlasses * 0.05).round().toStringAsFixed(2),
                        style: TextStyle(color: kIconColor, fontSize: 18),
                      ),
                      TextSpan(text: ' litres'),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () async {
                    await launchUrl(_url);
                  },
                  icon: Icon(Icons.info_outline),
                  iconSize: 20,
                  color: kIconColor,
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 8),
              decoration: kBorderDecoration,
              width: double.infinity,
              margin: EdgeInsets.all(12),
              child: Column(
                children: [
                  Row(
                    children: [
                      // const Icon(Icons.restart_alt),
                      Container(
                        width: 240,
                        child: const ListTile(
                          leading: Icon(Icons.refresh),
                          title: Text('Recents'),
                        ),
                      ),
                      IconButton(
                        onPressed: () {
                          showDialog(
                            context: context,
                            builder: (BuildContext context) {
                              return ConfirmationDialog(
                                title: "Delete Forever",
                                content:
                                    "This is going to delete Everything, Do you want to proceed?",
                                onConfirm: () {
                                  hiveStorage.deleteAll();

                                  setState(() {});
                                },
                              );
                            },
                          );
                        },
                        icon: const Icon(Icons.delete_forever),
                        color: Colors.red,
                      ),
                    ],
                  ),
                  Expanded(
                    child: ListView.builder(
                      // shrinkWrap: true,
                      // reverse: true,
                      padding: EdgeInsets.zero,
                      itemCount: modelHistory.length,
                      itemBuilder: (context, index) {
                        // Adjust index for reverse
                        int displayIndex = modelHistory.length - 1 - index;
                        // int displayIndex = index;

                        return ListTile(
                          onTap: () {
                            Navigator.pop(context);
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (context) => Home(
                                      request: modelHistory[displayIndex]
                                          ['request']['text'],
                                      response: modelHistory[displayIndex]
                                          ['response'],
                                      displayImage: modelHistory[displayIndex]
                                          ['request']['image'],
                                    )));
                          },
                          leading: Text(
                            kEmojiList[modelHistory[displayIndex]['model']],
                            style: TextStyle(fontSize: 23),
                          ),
                          title: Text(
                            maxLines: 1,
                            modelHistory[displayIndex]['request']['text'],
                            style: TextStyle(fontSize: 16),
                            overflow: TextOverflow.ellipsis,
                          ),
                          subtitle: Text(
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            modelHistory[displayIndex]['response'],
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              showDialog(
                                context: context,
                                builder: (BuildContext context) {
                                  return ConfirmationDialog(
                                    onConfirm: () {
                                      setState(() {
                                        hiveStorage.deleteEntryByDate(
                                          modelHistory[displayIndex]['date'],
                                        );
                                      });
                                    },
                                  );
                                },
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 25),
        ],
      ),
    );
  }
}
