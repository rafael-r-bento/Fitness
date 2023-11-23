/*
 * FitnessBAM - a fitness app with 3 pre-defined exercises
 * Copyright (C) 2023  Rafael Bento
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:async';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:flutter/services.dart' show rootBundle;
import 'package:sqflite/sqflite.dart';

import './activity.dart';
import './activity_circle.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FitnessBAM',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const MyHomePage(title: 'FitnessBAM'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  Database? database;
  Activity? activityNow;
  ui.Image? image1, image2, image3;
  bool isImage1Loaded = false, isImage2Loaded = false, isImage3Loaded = false;
  String fileData = '';

  MyHomePageState() {
    activityNow = Activity(
      date: DateTime.now().toIso8601String().substring(0, 10),
      ab: 0,
      burpee: 0,
      mountainClimber: 0,
    );
    setupDatabase().then((_) {
      verifyDatabase();
    });
  }

  @override
  void initState() {
    getTextFromFile();
    LicenseRegistry.addLicense(() async* {
      yield LicenseEntryWithLineBreaks(
        ["FitnessBAM"],
        fileData,
      );
    });
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    initImages();
  }

  @override
  void dispose() {
    super.dispose();
    WidgetsBinding.instance.removeObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        activityNow?.date !=
            DateTime.now().toIso8601String().substring(0, 10)) {
      setState(() {
        activityNow = Activity(
          date: DateTime.now().toIso8601String().substring(0, 10),
          ab: 0,
          burpee: 0,
          mountainClimber: 0,
        );
      });
      insertActivity(activityNow);
    }
  }

  Future<void> initImages() async {
    final ByteData data1 =
        await rootBundle.load('images/exercise_abcrunch.webp');
    final ByteData data2 =
        await rootBundle.load('images/exercise_4countburpee.webp');
    final ByteData data3 =
        await rootBundle.load('images/exercise_mountainclimber.webp');
    image1 = await loadImage(Uint8List.view(data1.buffer), 1);
    image2 = await loadImage(Uint8List.view(data2.buffer), 2);
    image3 = await loadImage(Uint8List.view(data3.buffer), 3);
  }

  Future<ui.Image> loadImage(List<int> img, int imageNumber) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(Uint8List.fromList(img), (ui.Image img) {
      setState(() {
        if (imageNumber == 1) {
          isImage1Loaded = true;
        } else if (imageNumber == 2) {
          isImage2Loaded = true;
        } else if (imageNumber == 3) {
          isImage3Loaded = true;
        }
      });
      return completer.complete(img);
    });
    return completer.future;
  }

  Future<void> setupDatabase() async {
    database = await openDatabase(
      path.join(await getDatabasesPath(), 'fitness_database.db'),
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE Activities (
          date TEXT PRIMARY KEY,
          ab INTEGER,
          burpee INTEGER,
          mountainClimber INTEGER
        )''');
      },
      version: 1,
    );
  }

  Future<void> verifyDatabase() async {
    Database? db = database;

    List<Map<String, dynamic>>? maps = await db?.query('Activities',
        columns: ['date', 'ab', 'burpee', 'mountainClimber'],
        where: 'date = ?',
        whereArgs: [activityNow?.date]);

    if (maps?.length != null) {
      if (maps!.isNotEmpty) {
        setState(() {
          activityNow?.ab = maps.first['ab'];
          activityNow?.burpee = maps.first['burpee'];
          activityNow?.mountainClimber = maps.first['mountainClimber'];
        });
      } else if (maps.isEmpty) {
        await insertActivity(activityNow);
      }
    }
  }

  Future<void> insertActivity(Activity? activity) async {
    Database? db = database;

    await db?.insert(
      'Activities',
      activity!.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateActivity(
      int iAb, int iBurpee, int iMountainClimber) async {
    final db = database;
    setState(() {
      activityNow?.ab += iAb;
      activityNow?.burpee += iBurpee;
      activityNow?.mountainClimber += iMountainClimber;
    });

    await db?.update(
      'Activities',
      activityNow!.toMap(),
      where: "date = ?",
      whereArgs: [activityNow?.date],
    );
  }

  Future<String> getFileData(String path) async {
    return await rootBundle.loadString(path);
  }

  void getTextFromFile() async {
    try {
      String data = await getFileData("COPYING");
      setState(() {
        fileData = data;
      });
    } catch (ex) {
      if (kDebugMode) {
        print(ex);
      }
    }
  }

  void _showAboutDialog() async {
    showAboutDialog(
        context: context,
        applicationName: "FitnessBAM",
        applicationVersion: "0.1.0",
        applicationIcon: const SizedBox(
          width: 48,
          height: 48,
          child: Image(
            image: AssetImage('images/burpees_in_room.png'),
          ),
        ),
        applicationLegalese: "Copyright (C) 2023  Rafael Bento\n\n"
            "This program comes with ABSOLUTELY NO WARRANTY. This is "
            "free software, and you are welcome to redistribute it under "
            "certain conditions; press the 'View licenses' button for details.");
  }

  void _deleteAllActivities() async {
    final Database? db = database;
    await db?.delete('Activities');
    activityNow?.ab = 0;
    activityNow?.burpee = 0;
    activityNow?.mountainClimber = 0;
    await verifyDatabase();
  }

  void openPage(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
      builder: (BuildContext context) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Settings'),
          ),
          body: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              ListView(
                shrinkWrap: true,
                children: [
                  ListTile(
                    leading: const Icon(Icons.delete),
                    title: const Text('Delete all activities'),
                    onTap: _deleteAllActivities,
                  ),
                  Divider(),
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('About FitnessBAM'),
                    onTap: _showAboutDialog,
                  ),
                  Divider(),
                ],
              ),
            ],
          ),
        );
      },
    ));
  }

  Widget _buildActivityCircle1(double sizeCustomPaint) {
    if (isImage1Loaded) {
      return CustomPaint(
        size: Size(
          sizeCustomPaint,
          sizeCustomPaint,
        ),
        painter:
            ActivityCircle(value: activityNow!.ab, limit: 50, image: image1!),
      );
    } else {
      return const Center(child: Text('loading'));
    }
  }

  Widget _buildActivityCircle2(double sizeCustomPaint) {
    if (isImage2Loaded) {
      return CustomPaint(
        size: Size(
          sizeCustomPaint,
          sizeCustomPaint,
        ),
        painter: ActivityCircle(
            value: activityNow!.burpee, limit: 50, image: image2!),
      );
    } else {
      return const Center(child: Text('loading'));
    }
  }

  Widget _buildActivityCircle3(double sizeCustomPaint) {
    if (isImage3Loaded) {
      return CustomPaint(
        size: Size(
          sizeCustomPaint,
          sizeCustomPaint,
        ),
        painter: ActivityCircle(
            value: activityNow!.mountainClimber, limit: 50, image: image3!),
      );
    } else {
      return const Center(child: Text('loading'));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              openPage(context);
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      updateActivity(0, 10, 0);
                    },
                    child: _buildActivityCircle2(
                        MediaQuery.of(context).size.width * 0.25),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text('${activityNow?.burpee}/50',
                        style: const TextStyle(fontSize: 32.0)),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text('Burpee'),
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      updateActivity(10, 0, 0);
                    },
                    child: _buildActivityCircle1(
                        MediaQuery.of(context).size.width * 0.25),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text("${activityNow?.ab}/50",
                        style: const TextStyle(fontSize: 32.0)),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text('Ab'),
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      updateActivity(0, 0, 10);
                    },
                    child: _buildActivityCircle3(
                        MediaQuery.of(context).size.width * 0.25),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text('${activityNow?.mountainClimber}/50',
                        style: const TextStyle(fontSize: 32.0)),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text('Mountain Climber'),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
