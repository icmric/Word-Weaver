import 'package:dio/dio.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'dart:html';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CSVDataLoader {
  late Map<String, List<Map<String, String>>> wordsAsMap;

  CSVDataLoader._(); // Private constructor

  static Future<CSVDataLoader> create() async {
    var loader = CSVDataLoader._();
    await loader.loadData();
    return loader;
  }

  Future<void> loadData({bool? updateData}) async {
    if (loadFromLocalStorage().toString() == "{}" || updateData == true) {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      final dio = Dio();
      String url = prefs.getString('url') ?? "https://docs.google.com/spreadsheets/d/e/2PACX-1vT-6HQ1PfiuXMQehZeOOVjf7ZNqc4a92Yl0uD5Ad-NiskmucLqD2BSZ9EQlZtvOC8SKngyZaL3RcQZD/pub?gid=0&single=true&output=csv";
      final rawData = await dio.get(url);
      final data = rawData.data.toString();
      final fields = const CsvToListConverter().convert(data);
      wordsAsMap = {};

      for (var row in fields) {
        String key;
        if (row[0] == 0) {
          key = "A";
        } else {
          key = row[0];
        }
        String childKey = row[1];
        String title = row[2];
        String emoji = row[3];

        if (!wordsAsMap.containsKey(key)) {
          wordsAsMap[key] = [];
        }

        wordsAsMap[key]!.add(
          {
            'child_key': childKey,
            'emoji': emoji,
            'title': title,
          },
        );
      }
      saveToLocalStorage();
    } else {
      wordsAsMap = loadFromLocalStorage();
    }
  }

  void saveToLocalStorage() {
    window.localStorage['words'] = jsonEncode(wordsAsMap);
  }

  Map<String, List<Map<String, String>>> loadFromLocalStorage() {
    String? data = window.localStorage['words'];
    if (data != null) {
      Map<String, dynamic> jsonMap = jsonDecode(data);
      return jsonMap.map((key, value) {
        var listMap = value as List;
        return MapEntry(key, listMap.map((item) => Map<String, String>.from(item)).toList());
      });
    } else {
      return {};
    }
  }
}
