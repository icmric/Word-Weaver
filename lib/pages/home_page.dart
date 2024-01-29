import 'package:flutter/material.dart';
import 'package:text_to_speech/text_to_speech.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key, required this.title});
  final String title;

  @override
  State<StatefulWidget> createState() {
    return HomePageState();
  }
}

class HomePageState extends State<HomePage> {
  int selectedWordIndex = -1;
  List<List<String>> selectedWords = [];
  List<String> currentOptions = [];
  List<dynamic> mapStack = [];
  Map<String, dynamic> options = {
    "People": {
      "Family": ["Mom", "Dad", "Brother", "Sister"],
      "Friends": ["Friend1", "Friend2", "Friend3"],
      "Teachers": ["Teacher1", "Teacher2", "Teacher3"],
      "Classmates": ["Classmate1", "Classmate2", "Classmate3"],
    },
    "Activities": ["Activity1", "Activity2", "Activity3"],
    "Places": ["Place1", "Place2", "Place3"],
    "Time": ["Time1", "Time2", "Time3"],
    "Feelings": ["Feeling1", "Feeling2", "Feeling3"],
    "Objects": ["Object1", "Object2", "Object3"],
  };

  @override
  void initState() {
    super.initState();
    currentOptions = options.keys.toList();
  }

  @override
  Widget build(BuildContext context) {
    if (selectedWordIndex == -1 && selectedWords.isNotEmpty) {
      selectedWordIndex = selectedWords.length - 1;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Center(child: Text(widget.title)),
      ),
      body: Center(
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
                                if (selectedWords.isNotEmpty)
                                  IconButton(
                                    icon: const Icon(
                                      Icons.volume_up_sharp,
                                      size: 20,
                                    ),
                                    onPressed: () {
                                      List<String> wordsToSpeak = [];
                                      for (i = 0; i < selectedWords.length; i++) {
                                        wordsToSpeak.add(selectedWords[i].last);
                                      }
                                      textToSpeechFunction(wordsToSpeak.toString());
                                    },
                                  ),
                              ],
                            ),
                          ),
                        ),
                      ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Wrap(
                  direction: Axis.horizontal, // this will ensure wrapping in row direction
                  children: currentOptions.map((key) => createTile(title: key)).toList(),
                ),
              ),
            ),
          ],
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
            if (options[title] is List<String>) {
              currentOptions = options[title];
            } else if (options[title] is Map<String, dynamic>) {
              mapStack.add(options); // push the current map to the stack
              options = options[title]; // update the options map with the new map
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
          width: 150,
          height: 200,
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
    TextToSpeech tts = TextToSpeech();
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
      currentOptions = options.keys.toList(); // reset currentOptions to the keys of the original options map
    });
  }
}
