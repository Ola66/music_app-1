import 'package:flutter/material.dart';
import 'package:ologee_music_app/pages/online.dart';
import 'package:ologee_music_app/pages/root_file.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.teal,
        appBar: AppBar(
          backgroundColor: Colors.teal,
          elevation: 0.0,
          title: Text('Shem Music'),
          bottom: TabBar(
            indicatorWeight: 0.1,
            tabs: [
              Tab(text: "Music"),
              Tab(text: "Library"),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            OnlineStore(),
            RootPage(),
          ],
        ),
      ),
    );
  }
}
