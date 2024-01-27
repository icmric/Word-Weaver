import 'package:flutter/material.dart';

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
  @override
  Widget build(BuildContext context) {
    double deviceWidth = MediaQuery.of(context).size.width;
    double deviceHeight = MediaQuery.of(context).size.height;
    List<String> Headings = ["People", "Activities", "Places", "Time", "Feelings", "Objects"];
    List<List<String>> selectedWords = [
      ["Word1", "Sub1", "Sub 2"],
      ["Word2", "Sub1", "Sub 2"],
      ["Word3", "Sub1", "Sub 2"],
      ["Word4", "Sub1"]
    ];
    if (selectedWordIndex == -1 && selectedWords.isNotEmpty) {
      selectedWordIndex = selectedWords.length - 1;
    }
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Center(child: Text(widget.title)),
      ),
      body: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              for (int i = 0; i < selectedWords.length; i++)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedWordIndex = i;
                    });
                  },
                  child: Column(
                    children: [
                      if (i == selectedWordIndex)
                        RichText(
                          text: TextSpan(
                            children: [
                              ...selectedWords[i].sublist(1).map((item) => TextSpan(
                                    text: selectedWords[i].sublist(1).isNotEmpty ? ' $item --> ' : ' $item',
                                  )),
                              TextSpan(
                                text: selectedWords[i][0],
                                style: const TextStyle(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ), // shows the full path and options for the selected word
                      if (i != selectedWordIndex)
                        Text(
                          selectedWords[i][0],
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ), // shows only the final word for all other words
                    ],
                  ),
                ),
            ],
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Wrap(
                direction: Axis.horizontal, // this will ensure wrapping in row direction
                children: Headings.map((name) => createTile(title: name, deviceWidth: deviceWidth, deviceHeight: deviceHeight)).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget createTile({required String title, required double deviceWidth, required double deviceHeight}) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
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
    );
  }
}
