import 'dart:developer';

import 'package:communication_assistant/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:text_to_speech/text_to_speech.dart';

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
  double volumeValue = 0.5;
  double rateValue = 0.5;
  String selectedvoice = 'en-US';

  List<String> _voices = [
    'en-AU',
    'en-US',
    'en-GB',
  ];

  TextToSpeech tts = TextToSpeech();

  @override
  void initState() {
    super.initState();
    if (widget.options != null) {
      volumeValue = widget.options!['volume'] ?? 1;
      rateValue = widget.options!['rate'] ?? 1;
      selectedvoice = widget.options!['voice'] ?? 'en-US';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        leading: IconButton(
          color: Colors.white,
          onPressed: () {
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
          'Voice Settings',
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
                  selectedvoice = "en-US";
                  rateValue = 1;
                  volumeValue = 1;
                  setState(() {});
                },
                child: Text("Reset"))
          ],
        ),
      ),
    );
  }
}
