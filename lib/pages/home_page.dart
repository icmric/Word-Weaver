import 'dart:developer';

import 'package:communication_assistant/data/import_data_csv.dart';
import 'package:communication_assistant/pages/voice_settings.dart';
import 'package:flutter/material.dart';
import 'package:text_to_speech/text_to_speech.dart';

class HomePage extends StatefulWidget {
  Map<String, dynamic> voiceOptions;
  final String title = "Communication Assistant";
  Map<String, List<Map<String, String>>>? options;
  HomePage({
    Key? key,
    this.voiceOptions = const {
      "volume": 1,
      "rate": 1,
      "pitch": 1,
      "language": "en-US",
      "voice": "en-US",
    },
    this.options,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  TextToSpeech tts = TextToSpeech();
  late Map<String, dynamic> voiceOptions;
  int selectedWordIndex = -1;
  List<List<String>> selectedWords = [];
  List<String> currentOptions = [];
  List<String> startingOptions = [];
  List<dynamic> mapStack = [];
  late Map<String, List<Map<String, String>>> options;
  late double optionsWidth;
  late double deviceHeight;
  late double optionsBoxWidth;
  late double optionsBoxHeight;

  @override
  void initState() {
    super.initState();
    options = widget.options!;
    currentOptions = options.values.first.map((e) => e.values.first.toString()).toList();
    startingOptions = currentOptions;
    voiceOptions = widget.voiceOptions;
    tts.setVolume(voiceOptions['volume']);
    tts.setRate(voiceOptions['rate']);
    tts.setLanguage(voiceOptions['voice']);
  }

  @override
  Widget build(BuildContext context) {
    if (selectedWordIndex == -1 && selectedWords.isNotEmpty) {
      selectedWordIndex = selectedWords.length - 1;
    }
    optionsWidth = MediaQuery.of(context).size.width;
    deviceHeight = MediaQuery.of(context).size.height;
    if (optionsWidth > 800) {
      optionsWidth = 800;
    }
    optionsBoxWidth = optionsWidth * 0.35;
    optionsBoxHeight = deviceHeight * 0.3;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Center(child: Text(widget.title)),
      ),
      drawer: Drawer(
          child: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          DrawerHeader(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary,
            ),
            child: Text(
              'Settings',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onPrimary,
                fontSize: 24,
              ),
            ),
          ),
          ListTile(
            title: const Text('Voice Settings'),
            onTap: () {
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VoiceSettingsPage(options: voiceOptions)));
            },
          ),
          ListTile(
            title: Text('About'),
            onTap: () {},
          ),
        ],
      )),
      body: Center(
        child: SizedBox(
          width: optionsWidth,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                reverse: true,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    for (int i = 0; i < selectedWords.length; i++)
                      if (selectedWords[i].isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: GestureDetector(
                            onTap: () {
                              setState(() {
                                selectedWordIndex = i;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: i == selectedWordIndex ? Colors.blue : Colors.grey,
                                shape: BoxShape.rectangle,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: Row(
                                children: [
                                  if (i == selectedWordIndex && selectedWords[i].last != "")
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          ...selectedWords[i].sublist(0, selectedWords[i].length - 1).map(
                                                (item) => TextSpan(
                                                  text: selectedWords[i].sublist(0, selectedWords[i].length - 1).isNotEmpty ? '$item --> ' : ' $item',
                                                ),
                                              ),
                                          TextSpan(
                                            text: selectedWords[i].last,
                                            style: const TextStyle(fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ), // shows the full path and options for the selected word
                                  if (i != selectedWordIndex)
                                    Text(
                                      selectedWords[i].last,
                                      style: const TextStyle(fontWeight: FontWeight.bold),
                                    ), // shows only the final word for all other words
                                  if (i == selectedWords.length - 1 && selectedWordIndex == selectedWords.length - 1 && selectedWords[i].last != "")
                                    IconButton(
                                      icon: const Icon(
                                        Icons.check,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        confirmWordInWordPath();
                                      },
                                    ),
                                  if (i == selectedWords.length - 1 && selectedWordIndex == selectedWords.length - 1 && selectedWords[i].last == "")
                                    IconButton(
                                      icon: const Icon(
                                        Icons.backspace,
                                        size: 20,
                                      ),
                                      onPressed: () {
                                        deleteLastWordInPath();
                                      },
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    if (selectedWords.isNotEmpty)
                      IconButton(
                        icon: const Icon(
                          Icons.volume_up_sharp,
                          size: 20,
                        ),
                        onPressed: () {
                          List<String> wordsToSpeak = [];
                          for (int i = 0; i < selectedWords.length; i++) {
                            wordsToSpeak.add(selectedWords[i].last);
                          }
                          textToSpeechFunction(wordsToSpeak.toString());
                        },
                      ),
                  ],
                ),
              ),
              Expanded(
                child: SingleChildScrollView(
                  child: Wrap(
                    direction: Axis.horizontal, // this will ensure wrapping in row direction
                    children: currentOptions.map((e) => createTile(title: e)).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget createTile({
    required String title,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: () {
          selectedWordIndex = selectedWords.length - 1;
          addToWordPath(wordToAdd: title);
          setState(() {
            if (options[title] is List<Map<String, String>>) {
              currentOptions = options[title]!.map((e) => e.values.first.toString()).toList();
            } else if (options[title] is Map<String, List<Map<String, String>>>) {
              mapStack.add(options); // push the current map to the stack
              //options = options[title];
              currentOptions = options.keys.toList();
            }
          });
        },
        onDoubleTap: () {
          textToSpeechFunction(title);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            border: Border.all(width: 1),
          ),
          width: optionsBoxWidth,
          height: optionsBoxHeight,
          child: Center(
            child: Text(
              title,
              style: const TextStyle(fontSize: 20),
            ),
          ),
        ),
      ),
    );
  }

  textToSpeechFunction(String text) {
    tts.speak(text);
  }

  void addToWordPath({required String wordToAdd}) {
    if (selectedWords.isEmpty) {
      selectedWords.add([wordToAdd]);
    } else if (selectedWords.last.first == "") {
      selectedWords.last.first = wordToAdd;
    } else {
      selectedWords.last.add(wordToAdd);
    }
    setState(() {});
  }

  void deleteLastWordInPath() {
    selectedWords.removeLast();
    selectedWords.removeLast();
    selectedWords.add([""]);
    selectedWordIndex = selectedWords.length - 1;
    setState(() {});
  }

  void confirmWordInWordPath() {
    setState(() {
      selectedWords.add([""]);
      selectedWordIndex = selectedWords.length - 1;
      while (mapStack.isNotEmpty) {
        options = mapStack.removeLast();
      }
      currentOptions = startingOptions; // reset currentOptions to the keys of the original options map
    });
  }
}
