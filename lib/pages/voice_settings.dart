import 'package:communication_assistant/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:text_to_speech/text_to_speech.dart';
import 'package:shared_preferences/shared_preferences.dart';

class VoiceSettingsPage extends StatefulWidget {
  final Map<String, dynamic>? options;
  // NOTE this is a dodgy fix, it preserves the words when moving between screens, would be better to save to a database insted
  final Map<String, List<Map<String, String>>> wordOptions;
  final List<List<String>> selectedWords;

  const VoiceSettingsPage({Key? key, this.options, required this.wordOptions, required this.selectedWords}) : super(key: key);

  @override
  _VoiceSettingsPageState createState() => _VoiceSettingsPageState();
}

class _VoiceSettingsPageState extends State<VoiceSettingsPage> {
  TextEditingController controller = TextEditingController();
  bool set = false;
  double volumeValue = 0.5;
  double rateValue = 0.5;
  String selectedvoice = 'en-US';
  String url = "https://docs.google.com/spreadsheets/d/e/2PACX-1vT-6HQ1PfiuXMQehZeOOVjf7ZNqc4a92Yl0uD5Ad-NiskmucLqD2BSZ9EQlZtvOC8SKngyZaL3RcQZD/pub?gid=0&single=true&output=csv";

  final List<String> _voices = [
    'en-AU',
    'en-US',
    'en-GB',
  ];

  TextToSpeech tts = TextToSpeech();

  @override
  void initState() {
    super.initState();
  }

  setPrefrences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setDouble('volume', volumeValue);
    await prefs.setDouble('rate', rateValue);
    await prefs.setString('voice', selectedvoice);
    await prefs.setString('url', url);
  }

  getPrefrences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (set == false) {
      volumeValue = prefs.getDouble('volume') ?? 1;
      rateValue = prefs.getDouble('rate') ?? 1;
      selectedvoice = prefs.getString('voice') ?? 'en-AU';
      url =
          prefs.getString('url') ?? "https://docs.google.com/spreadsheets/d/e/2PACX-1vT-6HQ1PfiuXMQehZeOOVjf7ZNqc4a92Yl0uD5Ad-NiskmucLqD2BSZ9EQlZtvOC8SKngyZaL3RcQZD/pub?gid=0&single=true&output=csv";
      controller.text = url;
      set = true;
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: getPrefrences(),
      builder: (context, snapshot) => Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.grey.shade900,
          leading: IconButton(
            color: Colors.white,
            onPressed: () {
              setPrefrences();
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (BuildContext context) => HomePage(
                    voiceOptions: {'volume': volumeValue, 'rate': rateValue, 'voice': selectedvoice},
                    options: widget.wordOptions,
                    selectedWords: widget.selectedWords,
                  ),
                ),
              );
            },
            icon: const Icon(Icons.arrow_back),
          ),
          title: const Text(
            'Settings',
            style: TextStyle(
              color: Colors.white,
            ),
          ),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("URL", style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold, color: Colors.white)),
              TextField(
                controller: controller,
                onChanged: (newValue) {
                  url = newValue;
                },
                style: const TextStyle(color: Colors.white),
              ),
              const Text(
                'Volume',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Slider(
                value: volumeValue,
                min: 0.0,
                max: 2.0,
                onChanged: (newValue) {
                  setState(
                    () {
                      volumeValue = newValue;
                    },
                  );
                },
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Rate',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Slider(
                value: rateValue,
                min: 0.0,
                max: 2.0,
                onChanged: (newValue) {
                  setState(() {
                    rateValue = newValue;
                  });
                },
              ),
              const SizedBox(height: 16.0),
              const Text(
                'Voice',
                style: TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              DropdownButton<String>(
                dropdownColor: Colors.grey.shade900,
                value: selectedvoice,
                onChanged: (newValue) {
                  setState(() {
                    selectedvoice = newValue!;
                  });
                },
                items: _voices.map(
                  (voice) {
                    return DropdownMenuItem<String>(
                      value: voice,
                      child: Text(
                        voice,
                        style: const TextStyle(color: Colors.white),
                      ),
                    );
                  },
                ).toList(),
              ),
              TextButton(
                  onPressed: () {
                    selectedvoice = "en-AU";
                    rateValue = 1;
                    volumeValue = 1;
                    url = "https://docs.google.com/spreadsheets/d/e/2PACX-1vT-6HQ1PfiuXMQehZeOOVjf7ZNqc4a92Yl0uD5Ad-NiskmucLqD2BSZ9EQlZtvOC8SKngyZaL3RcQZD/pub?gid=0&single=true&output=csv";
                    controller.text = url;
                    setPrefrences();
                    setState(() {});
                  },
                  child: const Text("Reset"))
            ],
          ),
        ),
      ),
    );
  }
}
