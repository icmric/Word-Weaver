import 'package:communication_assistant/data/import_data_csv.dart';
import 'package:communication_assistant/pages/home_page.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<CSVDataLoader> loadData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.getString('url') == null) {
      await prefs.setString('url', "https://docs.google.com/spreadsheets/d/e/2PACX-1vT-6HQ1PfiuXMQehZeOOVjf7ZNqc4a92Yl0uD5Ad-NiskmucLqD2BSZ9EQlZtvOC8SKngyZaL3RcQZD/pub?gid=0&single=true&output=csv");
    }
    return await CSVDataLoader.create();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Communication Assistant',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.black),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: FutureBuilder<CSVDataLoader>(
        future: loadData(),
        builder: (BuildContext context, AsyncSnapshot<CSVDataLoader> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator()); // Loading screen
          } else if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}'); // Error screen
          } else {
            return HomePage(
              options: snapshot.data!.wordsAsMap,
            ); // Home screen
          }
        },
      ),
    );
  }
}
