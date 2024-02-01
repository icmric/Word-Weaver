import 'package:communication_assistant/data/import_data_csv.dart';
import 'package:communication_assistant/pages/home_page.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<CSVDataLoader> loadData() async {
    return await CSVDataLoader.create();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Communication Assistant',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
        fontFamily: 'Roboto',
      ),
      home: FutureBuilder<CSVDataLoader>(
        future: loadData(),
        builder: (BuildContext context, AsyncSnapshot<CSVDataLoader> snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator()); // Loading screen
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
