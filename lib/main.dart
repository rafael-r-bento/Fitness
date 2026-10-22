/*
 * Fitness - a fitness app
 * Copyright (C) 2023-2025  Rafael Bento
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

import './activities.dart';
import './activity_circle.dart';
import './weight.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Fitness',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: const MyHomePage(title: 'Fitness'),
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
  Activities? activitiesNow;
  List<ui.Image?> imageList = List<ui.Image?>.filled(16, null);
  List<bool> isImageLoadedList = List<bool>.filled(16, false);
  String fileData = '';
  int _selectedIndex = 0;
  List<Map<String, dynamic?>>? expectedList;
  List<Weight?> weights = List<Weight?>.filled(16, null);
  final List<String> bicepsOptions = [
    '1 kg',
    '2 kg',
    '3 kg',
    '4 kg',
    '5 kg',
    '6 kg',
    '7 kg',
    '8 kg',
    '9 kg',
    '10 kg'
  ];
  final List<String> elevacaoLateralOptions = [
    '1 kg',
    '2 kg',
    '3 kg',
    '4 kg',
    '5 kg',
    '6 kg',
    '7 kg',
    '8 kg',
    '9 kg',
    '10 kg'
  ];
  final List<String> abdominalSupraSoloOptions = ['0 kg'];
  final List<String> flexaoOptions = ['0 kg'];
  final List<String> escaladorOptions = ['0 kg'];
  final List<String> agachamentoOptions = ['0 kg'];

  MyHomePageState() {
    activitiesNow = Activities(
        date: DateTime.now().toIso8601String().substring(0, 10),
        biceps: 0,
        elevacaoLateral: 0,
        abdominalSupraSolo: 0,
        flexao: 0,
        escalador: 0,
        agachamento: 0);
    setupDatabase().then((_) {
      verifyDatabase();
    });
  }

  @override
  void initState() {
    getTextFromFile();
    LicenseRegistry.addLicense(() async* {
      yield LicenseEntryWithLineBreaks(
        ["Fitness"],
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
        activitiesNow?.date !=
            DateTime.now().toIso8601String().substring(0, 10)) {
      setState(() {
        activitiesNow = Activities(
            date: DateTime.now().toIso8601String().substring(0, 10),
            biceps: 0,
            elevacaoLateral: 0,
            abdominalSupraSolo: 0,
            flexao: 0,
            escalador: 0,
            agachamento: 0);
      });
      insertActivities(activitiesNow);
    }
  }

  Future<void> initImages() async {
    List<ByteData> dataList = List<ByteData>.filled(6, ByteData(0));

    dataList[0] = await rootBundle.load('images/biceps.png');
    dataList[1] = await rootBundle.load('images/elevacao_lateral.png');
    dataList[2] = await rootBundle.load('images/abdominal_supra_solo.png');
    dataList[3] = await rootBundle.load('images/flexao.png');
    dataList[4] = await rootBundle.load('images/escalador.png');
    dataList[5] = await rootBundle.load('images/agachamento.png');

    for (int i = 0; i < 6; i++) {
      imageList[i] = await loadImage(Uint8List.view(dataList[i].buffer), i);
    }
  }

  Future<ui.Image> loadImage(List<int> img, int imageNumber) async {
    final Completer<ui.Image> completer = Completer();
    ui.decodeImageFromList(Uint8List.fromList(img), (ui.Image img) {
      setState(() {
        isImageLoadedList[imageNumber] = true;
      });
      return completer.complete(img);
    });
    return completer.future;
  }

  bool isImageLoaded(ui.Image? imgFile) {
    return imgFile != null && imageList.contains(imgFile);
  }

  Future<void> setupDatabase() async {
    database = await openDatabase(
      path.join(await getDatabasesPath(), 'fitness_database.db'),
      onCreate: (db, version) async {
        await db.execute('''CREATE TABLE Activities (
          date TEXT PRIMARY KEY,
          biceps INTEGER,
          elevacaoLateral INTEGER,
          abdominalSupraSolo INTEGER,
          flexao INTEGER,
          escalador INTEGER,
          agachamento INTEGER
        )''');
        await db.execute('''CREATE TABLE Weight (
          activity TEXT PRIMARY KEY,
          message TEXT
        )''');
      },
      version: 1,
    );
  }

  List<DateTime> _daysBetween(DateTime start, DateTime end) {
    final days = <DateTime>[];
    for (int i = 1; i <= end.difference(start).inDays; i++) {
      days.add(start.add(Duration(days: i)));
    }
    return days;
  }

  Future<DateTime?> _getLastSavedDate(Database? db) async {
    if (db == null) return null;
    final result = await db.query(
      'Activities',
      columns: ['date'],
      orderBy: 'date DESC',
      limit: 1
    );

    if (result.isEmpty) return null;
    return DateTime.parse(result.first['date'] as String);
  }

  Future<void> verifyDatabase() async {
    Database? db = database;
    final DateTime today = DateTime.now();

    final DateTime? lastSavedDate = await _getLastSavedDate(db);

    if (lastSavedDate != null) {
      final missingDays = _daysBetween(
        lastSavedDate,
        DateTime(today.year, today.month, today.day)
      );

      for (final day in missingDays) {
        final activity = Activities(
          date: day.toIso8601String().substring(0, 10),
          biceps: 0,
          elevacaoLateral: 0,
          abdominalSupraSolo: 0,
          flexao: 0,
          escalador: 0,
          agachamento: 0
        );
        await insertActivities(activity);
      }
    }

    List<Map<String, dynamic>>? mapsActivities = await db?.query('Activities',
        where: 'date = ?',
        whereArgs: [activitiesNow?.date]);

    if (mapsActivities!.isNotEmpty) {
      setState(() {
        activitiesNow?.biceps = mapsActivities.first['biceps'];
        activitiesNow?.elevacaoLateral =
          mapsActivities.first['elevacaoLateral'];
        activitiesNow?.abdominalSupraSolo =
          mapsActivities.first['abdominalSupraSolo'];
        activitiesNow?.flexao = mapsActivities.first['flexao'];
        activitiesNow?.escalador = mapsActivities.first['escalador'];
        activitiesNow?.agachamento = mapsActivities.first['agachamento'];
      });
    } else if (mapsActivities.isEmpty) {
      await insertActivities(activitiesNow);
    }

    List<Map<String, dynamic>>? weightMaps = await db?.query('Weight');

    if (weightMaps?.length != null) {
      if (weightMaps!.isNotEmpty) {
        setState(() {
          for (int i = 0; i < weightMaps.length; i++) {
            weights[i] = Weight(
                activity: weightMaps[i]['activity'],
                message: weightMaps[i]['message'],
            );
          }
        });
      } else if (weightMaps.isEmpty) {
        await insertWeight(Weight(activity: 'biceps', message: '1 kg'));
        await insertWeight(
            Weight(activity: 'elevacaoLateral', message: '1 kg'));
        await insertWeight(
            Weight(activity: 'abdominalSupraSolo', message: '0 kg'));
        await insertWeight(
            Weight(activity: 'flexao', message: '0 kg'));
        await insertWeight(Weight(activity: 'escalador', message: '0 kg'));
        await insertWeight(Weight(activity: 'agachamento', message: '0 kg'));
        await verifyDatabase();
      }
    }
  }

  Future<void> insertActivities(Activities? activities) async {
    Database? db = database;

    await db?.insert(
      'Activities',
      activities!.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> insertWeight(Weight weight) async {
    Database? db = database;

    await db?.insert(
      'Weight',
      weight!.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> updateActivities(
      int iBiceps,
      int iElevacaoLateral,
      int iAbdominalSupraSolo,
      int iFlexao,
      int iEscalador,
      int iAgachamento) async {
    final db = database;
    setState(() {
      activitiesNow?.biceps += iBiceps;
      activitiesNow?.elevacaoLateral += iElevacaoLateral;
      activitiesNow?.abdominalSupraSolo += iAbdominalSupraSolo;
      activitiesNow?.flexao += iFlexao;
      activitiesNow?.escalador += iEscalador;
      activitiesNow?.agachamento += iAgachamento;
    });

    await db?.update(
      'Activities',
      activitiesNow!.toMap(),
      where: "date = ?",
      whereArgs: [activitiesNow?.date],
    );
  }

  Future<void> updateWeight(String activity, String newMessage) async {
    final db = database;
    setState(() {
      int index = weights.indexWhere((w) => w?.activity == activity);
      if (index != -1 && weights[index] != null) {
        weights[index]!.message = newMessage;
      }
    });

    await db?.update(
      'Weight',
      {'message': newMessage},
      where: "activity = ?",
      whereArgs: [activity],
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

  Future<String> getMessageFromActivity(String activity) async {
    Database? db = database;

    List<Map<String, dynamic>>? mapsWeights = await db?.query('Weight',
        columns: ['activity', 'message'],
        where: 'activity = ?',
        whereArgs: [activity]);
    if (mapsWeights != null && mapsWeights.isNotEmpty) {
      return mapsWeights.first['message'] as String;
    } else {
      return "";
    }
  }

  void _showAboutDialog() async {
    showAboutDialog(
        context: context,
        applicationName: "Fitness",
        applicationVersion: "0.3.0",
        applicationIcon: const SizedBox(
          width: 48,
          height: 48,
          child: Image(
            image: AssetImage('images/burpees_in_room.png'),
          ),
        ),
        applicationLegalese: "Copyright (C) 2023-2025  Rafael Bento\n\n"
            "This program comes with ABSOLUTELY NO WARRANTY. This is "
            "free software, and you are welcome to redistribute it under "
            "certain conditions; press the 'View licenses' button for details.");
  }

  void _deleteAllActivities() async {
    final Database? db = database;
    await db?.delete('Activities');
    activitiesNow?.biceps = 0;
    activitiesNow?.elevacaoLateral = 0;
    activitiesNow?.abdominalSupraSolo = 0;
    activitiesNow?.flexao = 0;
    activitiesNow?.escalador = 0;
    activitiesNow?.agachamento = 0;
    await verifyDatabase();
  }

  void _deleteAllActivitiesDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: const Text('Confirm Action'),
        content: const Text('Are you sure you want to delete all activities?'),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              _deleteAllActivities();
              Navigator.of(context).pop();
            },
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  void openPage(BuildContext context) {
    Navigator.push(context, MaterialPageRoute(
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Settings'),
              ),
              body: SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    ListTile(
                      title: Text('Bíceps'),
                      trailing: DropdownButton<String>(
                        value: weights[0]?.message,
                        onChanged: (String? newValue) {
                          setState(() {
                            weights[0] =
                                Weight(activity: 'biceps', message: newValue!);
                            updateWeight('biceps', newValue!);
                          });
                        },
                        items: bicepsOptions
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    ListTile(
                      title: Text('Elevação lateral'),
                      trailing: DropdownButton<String>(
                        value: weights[1]?.message,
                        onChanged: (String? newValue) {
                          setState(() {
                            weights[1] = Weight(
                                activity: 'elevacaoLateral',
                                message: newValue!);
                            updateWeight('elevacaoLateral', newValue!);
                          });
                        },
                        items: elevacaoLateralOptions
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    ListTile(
                      title: Text('Abdominal supra solo'),
                      trailing: DropdownButton<String>(
                        value: weights[2]?.message,
                        onChanged: (String? newValue) {
                          setState(() {
                            weights[2] = Weight(
                                activity: 'abdominalSupraSolo',
                                message: newValue!);
                            updateWeight('abdominalSupraSolo', newValue!);
                          });
                        },
                        items: abdominalSupraSoloOptions
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    ListTile(
                      title: Text('Flexão'),
                      trailing: DropdownButton<String>(
                        value: weights[3]?.message,
                        onChanged: (String? newValue) {
                          setState(() {
                            weights[3] = Weight(
                                activity: 'flexao', message: newValue!);
                            updateWeight('flexao', newValue!);
                          });
                        },
                        items: flexaoOptions
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    ListTile(
                      title: Text('Escalador'),
                      trailing: DropdownButton<String>(
                        value: weights[4]?.message,
                        onChanged: (String? newValue) {
                          setState(() {
                            weights[4] = Weight(
                                activity: 'escalador', message: newValue!);
                            updateWeight('escalador', newValue!);
                          });
                        },
                        items: escaladorOptions
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    ListTile(
                      title: Text('Agachamento'),
                      trailing: DropdownButton<String>(
                        value: weights[5]?.message,
                        onChanged: (String? newValue) {
                          setState(() {
                              weights[5] = Weight(
                              activity: 'agachamento', message: newValue!);
                              updateWeight('agachamento', newValue!);
                          });
                        },
                        items: agachamentoOptions
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    Divider(),
                    ListView(
                      shrinkWrap: true,
                      children: [
                        ListTile(
                          leading: const Icon(Icons.delete),
                          title: const Text('Delete all activities'),
                          onTap: _deleteAllActivitiesDialog,
                        ),
                        ListTile(
                          leading: const Icon(Icons.info),
                          title: const Text('About Fitness'),
                          onTap: _showAboutDialog,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    ));
  }

  Widget _buildActivityCircle(
      double sizeCustomPaint, int? activityValue, ui.Image? imgFile) {
    if (isImageLoaded(imgFile)) {
      return CustomPaint(
        size: Size(
          sizeCustomPaint,
          sizeCustomPaint,
        ),
        painter:
            ActivityCircle(value: activityValue!, limit: 45, image: imgFile!),
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

  Widget buildActivityColumn(
      {required BuildContext context,
      required VoidCallback onTap,
      required int? activityValue,
      required int? activityTotal,
      required String label,
      required String weightMessage,
      required ui.Image? image}) {
    return Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          GestureDetector(
              onTap: onTap,
              child: _buildActivityCircle(
                  MediaQuery.of(context).size.width * 0.25,
                  activityValue,
                  image)),
          Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Text('${activityValue ?? 0}/${activityTotal ?? 0}')),
          Padding(padding: const EdgeInsets.only(top: 10), child: Text(label)),
          Chip(
            avatar: Icon(Icons.label_outline, color: Colors.white),
            label: Text(weightMessage),
          )
        ]);
  }

  Widget chartToRun() {
    getList().then((list) {
      if (list != null) this.expectedList = [...list!];
    });
    List<double> treino1Counter = [];
    List<double> treino2Counter = [];
    if (expectedList != null && expectedList!.length != null) {
      if (expectedList!.length > 30) {
        expectedList = expectedList?.sublist(expectedList!.length - 30);
      } else if (expectedList!.length < 30) {
        while (expectedList!.length < 30) {
          expectedList!.insert(0, {
            'date': "",
            'biceps': 0,
            'elevacaoLateral': 0,
            'abdominalSupraSolo': 0,
            'flexao': 0,
            'escalador': 0,
            'agachamento': 0
          });
        }
      }
      expectedList!.forEach((element) => {
            treino1Counter.add(element["biceps"].toDouble() +
                element["elevacaoLateral"].toDouble() +
                element["abdominalSupraSolo"].toDouble() +
                element["flexao"].toDouble()),
            treino2Counter.add(element["escalador"].toDouble() +
              element["agachamento"].toDouble()),
          });
    } else {
      treino1Counter = [
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0
      ];

      treino2Counter = [
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0,
        0.0
      ];
    }
    LabelLayoutStrategy? xContainerLabelLayoutStrategy;
    ChartData chartData;
    ChartOptions chartOptions = const ChartOptions();
    chartData = ChartData(
      dataRows: [
        treino1Counter,
        treino2Counter,
      ],
      xUserLabels: const [
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        '',
        ''
      ],
      dataRowsLegends: const [
        'Treino 1',
        'Treino 2',
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
      body: _selectedIndex == 0
          ? Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    buildActivityColumn(
                        context: context,
                        onTap: () => updateActivities(
                            15, 0, 0, 0, 0, 0),
                        activityValue: activitiesNow?.biceps,
                        activityTotal: 45,
                        label: 'Bíceps\n',
                        weightMessage: weights[0]?.message ?? '',
                        image: imageList[0]),
                    buildActivityColumn(
                        context: context,
                        onTap: () => updateActivities(
                            0, 15, 0, 0, 0, 0),
                        activityValue: activitiesNow?.elevacaoLateral,
                        activityTotal: 45,
                        label: 'Elevação lateral\n',
                        weightMessage: weights[1]?.message ?? '',
                        image: imageList[1])
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    buildActivityColumn(
                        context: context,
                        onTap: () => updateActivities(
                            0, 0, 15, 0, 0, 0),
                        activityValue: activitiesNow?.abdominalSupraSolo,
                        activityTotal: 45,
                        label: 'Abdominal supra\n solo',
                        weightMessage: weights[2]?.message ?? '',
                        image: imageList[2]),
                    buildActivityColumn(
                        context: context,
                        onTap: () => updateActivities(
                            0, 0, 0, 15, 0, 0),
                        activityValue: activitiesNow?.flexao,
                        activityTotal: 45,
                        label: 'Flexão\n',
                        weightMessage: weights[3]?.message ?? '',
                        image: imageList[3]),
                  ],
                ),
              ],
            )
          : (_selectedIndex == 1
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        buildActivityColumn(
                            context: context,
                            onTap: () => updateActivities(
                              0, 0, 0, 0, 15, 0
                            ),
                            activityValue: activitiesNow?.escalador,
                            activityTotal: 45,
                            label: 'Escalador',
                            weightMessage: weights[4]?.message ?? '',
                            image: imageList[4]),
                         buildActivityColumn(
                            context: context,
                            onTap: () => updateActivities(
                              0, 0, 0, 0, 0, 15
                            ),
                            activityValue: activitiesNow?.agachamento,
                            activityTotal: 45,
                            label: 'Agachamento',
                            weightMessage: weights[5]?.message ?? '',
                            image: imageList[5]),
                      ],
                    ),
                  ],
                )
              : Column(
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
                )),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Treino 1',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center),
            label: 'Treino 2',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.show_chart),
            label: 'Chart',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.red[800],
        onTap: _onItemTapped,
      ),
    );
  }
}
