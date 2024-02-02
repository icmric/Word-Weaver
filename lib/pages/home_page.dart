import 'package:communication_assistant/pages/voice_settings.dart';
import 'package:flutter/material.dart';
import 'package:text_to_speech/text_to_speech.dart';

class HomePage extends StatefulWidget {
  Map<String, dynamic> voiceOptions;
  final String title = "Communication Assistant";
  Map<String, List<Map<String, String>>>? options;
  List<List<String>>? selectedWords;
  HomePage({
    Key? key,
    this.voiceOptions = const {
      "volume": 1,
      "rate": 1,
      "pitch": 1,
      "language": "en-US",
      "voice": "en-AU",
    },
    this.options,
    this.selectedWords,
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
  List<List<String>> navigationKeys = [[]];

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
    if (widget.selectedWords != null) {
      selectedWords = widget.selectedWords!;
    }

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
      backgroundColor: Colors.black,
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.grey.shade900,
        title: Center(
            child: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        )),
      ),
      drawer: Drawer(
          backgroundColor: Colors.black,
          child: ListView(
            padding: EdgeInsets.zero,
            children: <Widget>[
              DrawerHeader(
                decoration: BoxDecoration(
                  color: Colors.grey.shade900,
                ),
                child: const Text(
                  'Settings',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
              ListTile(
                title: const Text(
                  'Settings',
                  style: TextStyle(color: Colors.white),
                ),
                onTap: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VoiceSettingsPage(options: voiceOptions, wordOptions: options, selectedWords: selectedWords)));
                },
              ),
              ListTile(
                title: const Text(
                  'About',
                  style: TextStyle(color: Colors.white),
                ),
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
                              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 0),
                              child: Row(
                                children: [
                                  if (i == selectedWordIndex && selectedWords[i].last != "")
                                    RichText(
                                      text: TextSpan(
                                        children: [
                                          ...selectedWords[i].sublist(0, selectedWords[i].length - 1).map(
                                                (item) => TextSpan(
                                                  text: selectedWords[i].sublist(0, selectedWords[i].length - 1).isNotEmpty ? '$item --> ' : ' $item',
                                                  style: const TextStyle(fontSize: 20),
                                                ),
                                              ),
                                          TextSpan(
                                            text: selectedWords[i].last,
                                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
                                          ),
                                        ],
                                      ),
                                    ), // shows the full path and options for the selected word
                                  if (i != selectedWordIndex)
                                    Text(
                                      selectedWords[i].last,
                                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
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
                          color: Colors.white,
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
              createTiles(),
            ],
          ),
        ),
      ),
    );
  }

  dynamic navigateNestedMap(dynamic options, List<List<String>> keys) {
    List currectKeys = keys.last; // create a copy of keys

    //if the start of the list
    if (currectKeys.isEmpty) {
      if (options is Map) {
        return options["A"];
      } else {
        return options;
      }
    }

    //test if options[keys.last] exists
    if (options[currectKeys.last] != null) {
      return options[currectKeys.last];
    } else {
      return [];
    }
  }

  String listOfNextWords(Map options, String key) {
    String words = "";
    List childOptions = navigateNestedMap(options, [
      [key]
    ]);

    childOptions.forEach((element) {
      words += element["title"] + " ";
    });

    return words;
  }

  Widget createTiles() {
    var items = navigateNestedMap(options, navigationKeys);
    return Expanded(
      child: SingleChildScrollView(
        child: Wrap(
            direction: Axis.horizontal, // this will ensure wrapping in row direction
            children: [
              for (int i = 0; i < items.length; i++)
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: GestureDetector(
                    onTap: () {
                      //selectedWordIndex = selectedWords.length - 1;
                      //print("Tapped Tile");
                      //print(items[i]["title"]);
                      addToWordPath(wordToAdd: items[i]["title"]);
                      navigationKeys.last.add(items[i]["child_key"]);

                      if (listOfNextWords(options, items[i]["child_key"]) == "") {
                        confirmWordInWordPath();
                      }

                      setState(() {});
                    },
                    onLongPress: () {
                      textToSpeechFunction(items[i]["title"]);
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.grey.shade900,
                        border: Border.all(width: 1),
                      ),
                      width: optionsBoxWidth,
                      height: optionsBoxHeight,
                      child: Column(
                        children: [
                          Center(
                              child: Text(
                            items[i]["emoji"],
                            style: const TextStyle(
                              color: Colors.white,
                            ),
                          )),
                          const Spacer(),
                          Center(
                            child: Text(
                              items[i]["title"],
                              style: const TextStyle(
                                fontSize: 35,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          const Spacer(),
                          Center(
                            child: Text(
                              listOfNextWords(options, items[i]["child_key"]) == "" ? "[END]" : listOfNextWords(options, items[i]["child_key"]),
                              style: const TextStyle(
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
            ]),
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
    } else if (selectedWords.last.last != wordToAdd) {
      selectedWords.last.add(wordToAdd);
    }

    setState(() {});
  }

  void deleteLastWordInPath() {
    selectedWords.removeLast();
    selectedWords.removeLast();

    if (selectedWords.isNotEmpty) {
      // if there are still words left, add a blank word to preserve the delete button, if it is empty make delete button disapear
      selectedWords.add([""]);
    }

    selectedWordIndex = selectedWords.length - 1;
    setState(() {});
  }

  void confirmWordInWordPath() {
    setState(() {
      selectedWords.add([""]);
      selectedWordIndex = selectedWords.length - 1;
      currentOptions = startingOptions; // reset currentOptions to the keys of the original options map
      navigationKeys.add([]);
    });
  }
}
