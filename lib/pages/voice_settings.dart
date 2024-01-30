import 'dart:developer';

import 'package:communication_assistant/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:text_to_speech/text_to_speech.dart';

class VoiceSettingsPage extends StatefulWidget {
  final Map<String, dynamic>? options;

  const VoiceSettingsPage({Key? key, this.options}) : super(key: key);

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
      appBar: AppBar(
        leading: IconButton(
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (BuildContext context) => HomePage(
                  voiceOptions: {'volume': volumeValue, 'rate': rateValue, 'voice': selectedvoice},
                ),
              ),
            );
          },
          icon: const Icon(Icons.arrow_back),
        ),
        title: const Text('Voice Settings'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Volume',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            Slider(
              value: volumeValue,
              min: 0.0,
              max: 2.0,
              onChanged: (newValue) {
                setState(() {
                  volumeValue = newValue;
                });
              },
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Rate',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
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
              'voice',
              style: TextStyle(fontSize: 16.0, fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              value: selectedvoice,
              onChanged: (newValue) {
                setState(() {
                  selectedvoice = newValue!;
                });
              },
              items: _voices.map((voice) {
                return DropdownMenuItem<String>(
                  value: voice,
                  child: Text(voice),
                );
              }).toList(),
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
