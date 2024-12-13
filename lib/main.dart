/*
 * FitnessAMP - a fitness app with 3 predefined exercises
 * Copyright (C) 2023-2024  Rafael Bento
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
import 'dart:developer';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:flutter_charts/flutter_charts.dart';
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
      title: 'FitnessAMP',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const MyHomePage(title: 'FitnessAMP'),
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
  int _selectedIndex = 0;
  List<Map<String, dynamic?>>? expectedList;
  static var countdownDuration = Duration(minutes: 10);
  Duration duration = Duration();
  Timer? timer;
  bool countDown = true;

  MyHomePageState() {
    activityNow = Activity(
      date: DateTime.now().toIso8601String().substring(0, 10),
      ab: 0,
      mountainClimber: 0,
      pushUps: 0,
    );
    setupDatabase().then((_) {
      verifyDatabase();
    });
  }

  @override
  void initState() {
    var hours;
    var mints;
    var secs;
    hours = int.parse("00");
    mints = int.parse("00");
    secs = int.parse("00");
    countdownDuration = Duration(hours: hours, minutes: mints, seconds: secs);
    startTimer();
    reset();
    getTextFromFile();
    LicenseRegistry.addLicense(() async* {
      yield LicenseEntryWithLineBreaks(
        ["FitnessAMP"],
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
          mountainClimber: 0,
	  pushUps: 0,
        );
      });
      insertActivity(activityNow);
      reset();
    }
  }

  Future<void> initImages() async {
    final ByteData data1 =
        await rootBundle.load('images/exercise_abcrunch.webp');
    final ByteData data2 =
        await rootBundle.load('images/exercise_mountainclimber.webp');
    final ByteData data3 =
        await rootBundle.load('images/exercise_pushups.webp');
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

  bool isImageLoaded(ui.Image? imgFile) {
    if (imgFile != null) {
      if (imgFile == image1 || imgFile == image2 || imgFile == image3) {
        return true;
      }
    }
    
    return false;
  }

  Future<void> setupDatabase() async {
    database = await openDatabase(
      path.join(await getDatabasesPath(), 'fitness_database.db'),
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE Activities (
          date TEXT PRIMARY KEY,
          ab INTEGER,
          mountainClimber INTEGER,
	  pushUps INTEGER
        )''');
      },
      version: 1,
    );
  }

  Future<void> verifyDatabase() async {
    Database? db = database;

    List<Map<String, dynamic>>? maps = await db?.query('Activities',
        columns: ['date', 'ab', 'mountainClimber', 'pushUps'],
        where: 'date = ?',
        whereArgs: [activityNow?.date]);

    if (maps?.length != null) {
      if (maps!.isNotEmpty) {
        setState(() {
          activityNow?.ab = maps.first['ab'];
          activityNow?.mountainClimber = maps.first['mountainClimber'];
	  activityNow?.pushUps = maps.first['pushUps'];
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
    int iAb, int iMountainClimber, int iPushUps) async {
    final db = database;
    setState(() {
      activityNow?.ab += iAb;
      activityNow?.mountainClimber += iMountainClimber;
      activityNow?.pushUps += iPushUps;
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
        applicationName: "FitnessAMP",
        applicationVersion: "0.3.0",
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
    activityNow?.mountainClimber = 0;
    activityNow?.pushUps = 0;
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
                  ListTile(
                    leading: const Icon(Icons.info),
                    title: const Text('About FitnessAMP'),
                    onTap: _showAboutDialog,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    ));
  }

  Widget _buildActivityCircle(double sizeCustomPaint, int? activityValue, ui.Image? imgFile) {
    if (isImageLoaded(imgFile)) {
      return CustomPaint(
        size: Size(
          sizeCustomPaint,
          sizeCustomPaint,
        ),
        painter:
            ActivityCircle(value: activityValue!, limit: 50, image: imgFile!),
      );
    } else {
      return const Center(child: Text('loading'));
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<List<Map<String, dynamic?>>?> getList() async {
    await verifyDatabase();
    return await database?.rawQuery('SELECT * FROM Activities');
  }

  Widget chartToRun() {
    getList().then((list){
      if (list != null)
        this.expectedList = [...list!];
    });
    List<double> abCounter = [];
    List<double> mountainClimberCounter = [];
    List<double> pushUpsCounter = [];
    if (expectedList != null && expectedList!.length != null) {
      if (expectedList!.length > 30) {
        while (expectedList!.length > 30) {
	  expectedList!.remove(0);
	}
      }
      else if (expectedList!.length < 30) {
        while (expectedList!.length < 30) {
          expectedList!.insert(0, {'date': "", 'ab': 0, 'mountainClimber': 0, 'pushUps': 0});
        }
      }
      expectedList!.forEach((element) => {
        abCounter.add(element["ab"].toDouble()),
        mountainClimberCounter.add(element["mountainClimber"].toDouble()),
	pushUpsCounter.add(element["pushUps"].toDouble()),
      });
    }
    else {
      abCounter = [1.0, 0.0, 0.0, 4.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
	0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
	0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];

      mountainClimberCounter = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
	0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
	0.0, 0.0, 50.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];

      pushUpsCounter = [0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
	0.0, 0.0, 7.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0,
	0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0];
    }
    LabelLayoutStrategy? xContainerLabelLayoutStrategy;
    ChartData chartData;
    ChartOptions chartOptions = const ChartOptions();
    chartData = ChartData(
      dataRows: [
        abCounter,
        mountainClimberCounter,
	pushUpsCounter,
      ],
      xUserLabels: const ['', '', '' ,'', '', '', '', '', '', '',
	'', '', '' ,'', '', '', '', '', '', '',
	'', '', '' ,'', '', '', '', '', '', ''],
      dataRowsLegends: const [
        'Ab',
        'Mountain Climber',
        'Push Ups',
      ],
      chartOptions: chartOptions,
    );
    var verticalBarChartContainer = VerticalBarChartTopContainer(
      chartData: chartData,
      xContainerLabelLayoutStrategy: xContainerLabelLayoutStrategy,
    );

    var verticalBarChart = VerticalBarChart(
      painter: VerticalBarChartPainter(
        verticalBarChartContainer: verticalBarChartContainer,
      ),
    );
    return verticalBarChart;
  }

  void reset() {
    if (countDown) {
      setState(() => duration = countdownDuration);
    } else {
      setState(() => duration = Duration());
    }
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (_) => addTime());
  }

  void addTime() {
    final addSeconds = 1;
    setState(() {
      final seconds = duration.inSeconds + addSeconds;
      if (seconds > 3600) {
        timer?.cancel();
      } else {
        duration = Duration(seconds: seconds);
      }
    });
  }

  Widget buildTime() {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
      buildTimeCard(time: hours, header: 'HOURS'),
      SizedBox(
        width: 8,
      ),
      buildTimeCard(time: minutes, header: 'MINUTES'),
      SizedBox(
        width: 8,
      ),
      buildTimeCard(time: seconds, header: 'SECONDS'),
    ]);
  }

  Widget buildTimeCard({required String time, required String header}) =>
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
                color: Colors.white, borderRadius: BorderRadius.circular(20)),
            child: Text(
              time,
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  fontSize: 50),
            ),
          ),
          SizedBox(
            height: 24,
          ),
          Text(header, style: TextStyle(color: Colors.black45)),
        ],
      );

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
      body: _selectedIndex == 0 ?
        Column(
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
                      updateActivity(10, 0, 0);
                    },
                    child: _buildActivityCircle(
                        MediaQuery.of(context).size.width * 0.25,
			activityNow?.ab,
			image1,
		    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text('${activityNow?.ab}/50',
                        style: const TextStyle(fontSize: 32.0)),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text('Ab'),
                  ),
                ],
              ),
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      updateActivity(0, 10, 0);
                    },
                    child: _buildActivityCircle(
                        MediaQuery.of(context).size.width * 0.25,
                        activityNow?.mountainClimber,
                        image2),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text("${activityNow?.mountainClimber}/50",
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
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(
                children: <Widget>[
                  GestureDetector(
                    onTap: () {
                      updateActivity(0, 0, 10);
                    },
                    child: _buildActivityCircle(
                        MediaQuery.of(context).size.width * 0.25,
                        activityNow?.pushUps,
                        image3),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text('${activityNow?.pushUps}/50',
                        style: const TextStyle(fontSize: 32.0)),
                  ),
                  const Padding(
                    padding: EdgeInsets.only(top: 10),
                    child: Text('Push Ups'),
                  ),
                ],
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    margin: EdgeInsets.only(top: 30, bottom: 30),
                    child: buildTime()
                  ),
                ],
              ),
            ],
          ),
        ],
      ) :
      Column(
        mainAxisAlignment: MainAxisAlignment.center,
	children: <Widget>[
          Expanded(
            child: Row(
	      crossAxisAlignment: CrossAxisAlignment.stretch,
	      children: <Widget>[
	        Expanded(
		  child: chartToRun(),
		),
	      ],
	    ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
	  BottomNavigationBarItem(
	    icon: Icon(Icons.home),
	    label: 'Home',
	  ),
	  BottomNavigationBarItem(
	    icon: Icon(Icons.show_chart),
	    label: 'Chart',
	  ),
	],
	currentIndex: _selectedIndex,
	onTap: _onItemTapped,
      ),
    );
  }
}