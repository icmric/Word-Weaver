import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

class CSVDataLoader {
  late Map<String, List<Map<String, String>>> wordsAsMap;

  CSVDataLoader._(); // Private constructor

  static Future<CSVDataLoader> create() async {
    var loader = CSVDataLoader._();
    await loader.loadData();
    return loader;
  }

  Future<void> loadData() async {
    const filePath = 'assets/words.csv';
    final data = await rootBundle.loadString(filePath);
    final fields = const CsvToListConverter().convert(data);
    wordsAsMap = {};

    for (var row in fields) {
      String key = row[0];
      String childKey = row[1];
      String title = row[2];
      String emoji = row[3];

      if (!wordsAsMap.containsKey(key)) {
        wordsAsMap[key] = [];
      }

      wordsAsMap[key]!.add({
        'child_key': childKey,
        'emoji': emoji,
        'title': title,
      });
    }
  }
}
