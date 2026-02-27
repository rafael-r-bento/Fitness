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
  final List<String> remadaArticuladaSupinadaOptions = [
    '5 kg',
    '10 kg',
    '15 kg',
    '20 kg',
    '25 kg',
    '30 kg',
    '35 kg',
    '40 kg',
    '45 kg',
    '50 kg',
    '55 kg',
    '60 kg',
    '65 kg',
    '70 kg',
    '75 kg'
  ];
  final List<String> puxadaArticuladaOptions = [
    '5 kg',
    '10 kg',
    '15 kg',
    '20 kg',
    '25 kg',
    '30 kg',
    '35 kg',
    '40 kg',
    '45 kg',
    '50 kg',
    '55 kg',
    '60 kg',
    '65 kg',
    '70 kg',
    '75 kg'
  ];
  final List<String> supinoVerticalOptions = [
    '5 kg',
    '10 kg',
    '15 kg',
    '20 kg',
    '25 kg',
    '30 kg',
    '35 kg',
    '40 kg',
    '45 kg',
    '50 kg',
    '55 kg',
    '60 kg',
    '65 kg',
    '70 kg',
    '75 kg'
  ];
  final List<String> crucifixoOptions = [
    '5 kg',
    '12 kg',
    '19 kg',
    '26 kg',
    '33 kg',
    '40 kg',
    '47 kg',
    '54 kg',
    '61 kg',
    '68 kg',
    '75 kg',
    '82 kg',
    '89 kg',
    '96 kg',
    '103 kg',
    '110 kg',
    '117 kg',
    '124 kg',
    '131 kg',
    '138 kg'
  ];
  final List<String> desenvolvimentoOptions = [
    '5 kg',
    '10 kg',
    '15 kg',
    '20 kg',
    '25 kg',
    '30 kg',
    '35 kg',
    '40 kg',
    '45 kg',
    '50 kg',
    '55 kg',
    '60 kg',
    '65 kg',
    '70 kg',
    '75 kg'
  ];
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
  final List<String> esteira1Options = ['0%', '3%', '6%', '9%', '12%', '15%'];
  final List<String> cadeiraFlexoraOptions = [
    '5 kg',
    '12 kg',
    '19 kg',
    '26 kg',
    '33 kg',
    '40 kg',
    '47 kg',
    '54 kg',
    '61 kg',
    '68 kg',
    '75 kg',
    '82 kg',
    '89 kg',
    '96 kg',
    '103 kg',
    '110 kg',
    '117 kg',
    '124 kg',
    '131 kg',
    '138 kg'
  ];
  final List<String> cadeiraExtensoraOptions = [
    '5 kg',
    '12 kg',
    '19 kg',
    '26 kg',
    '33 kg',
    '40 kg',
    '47 kg',
    '54 kg',
    '61 kg',
    '68 kg',
    '75 kg',
    '82 kg',
    '89 kg',
    '96 kg',
    '103 kg',
    '110 kg',
    '117 kg',
    '124 kg',
    '131 kg',
    '138 kg'
  ];
  final List<String> legHorizontalOptions = [
    '5 kg',
    '15 kg',
    '25 kg',
    '35 kg',
    '45 kg',
    '55 kg',
    '65 kg',
    '75 kg',
    '85 kg',
    '95 kg',
    '105 kg',
    '115 kg',
    '125 kg',
    '135 kg',
    '145 kg',
    '155 kg',
    '165 kg',
    '175 kg',
    '185 kg',
    '195 kg'
  ];
  final List<String> cadeiraAbdutoraOptions = [
    '5 kg',
    '12 kg',
    '19 kg',
    '26 kg',
    '33 kg',
    '40 kg',
    '47 kg',
    '54 kg',
    '61 kg',
    '68 kg',
    '75 kg',
    '82 kg',
    '89 kg',
    '96 kg',
    '103 kg',
    '110 kg',
    '117 kg',
    '124 kg',
    '131 kg',
    '138 kg'
  ];
  final List<String> panturrilhaSentadoOptions = [
    '10 kg',
    '20 kg',
    '30 kg',
    '40 kg'
  ];
  final List<String> leg45Options = [
    '10 kg',
    '20 kg',
    '30 kg',
    '40 kg'
  ];
  final List<String> esteira2Options = ['0%', '3%', '6%', '9%', '12%', '15%'];

  MyHomePageState() {
    activitiesNow = Activities(
        date: DateTime.now().toIso8601String().substring(0, 10),
        remadaArticuladaSupinada: 0,
        puxadaArticulada: 0,
        supinoVertical: 0,
        crucifixo: 0,
        desenvolvimento: 0,
        biceps: 0,
        elevacaoLateral: 0,
        abdominalSupraSolo: 0,
        esteira1: 0,
        cadeiraFlexora: 0,
        cadeiraExtensora: 0,
        legHorizontal: 0,
        cadeiraAbdutora: 0,
        panturrilhaSentado: 0,
        leg45: 0,
        esteira2: 0);
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
            remadaArticuladaSupinada: 0,
            puxadaArticulada: 0,
            supinoVertical: 0,
            crucifixo: 0,
            desenvolvimento: 0,
            biceps: 0,
            elevacaoLateral: 0,
            abdominalSupraSolo: 0,
            esteira1: 0,
            cadeiraFlexora: 0,
            cadeiraExtensora: 0,
            legHorizontal: 0,
            cadeiraAbdutora: 0,
            panturrilhaSentado: 0,
            leg45: 0,
            esteira2: 0);
      });
      insertActivities(activitiesNow);
    }
  }

  Future<void> initImages() async {
    List<ByteData> dataList = List<ByteData>.filled(16, ByteData(0));

    dataList[0] =
        await rootBundle.load('images/remada_articulada_supinada.png');
    dataList[1] = await rootBundle.load('images/puxada_articulada.png');
    dataList[2] = await rootBundle.load('images/supino_vertical.png');
    dataList[3] = await rootBundle.load('images/crucifixo.png');
    dataList[4] = await rootBundle.load('images/desenvolvimento.png');
    dataList[5] = await rootBundle.load('images/biceps.png');
    dataList[6] = await rootBundle.load('images/elevacao_lateral.png');
    dataList[7] = await rootBundle.load('images/abdominal_supra_solo.png');
    dataList[8] = await rootBundle.load('images/esteira.png');
    dataList[9] = await rootBundle.load('images/cadeira_flexora.png');
    dataList[10] = await rootBundle.load('images/cadeira_extensora.png');
    dataList[11] = await rootBundle.load('images/leg_horizontal.png');
    dataList[12] = await rootBundle.load('images/cadeira_abdutora.png');
    dataList[13] = await rootBundle.load('images/panturrilha_sentado.png');
    dataList[14] = await rootBundle.load('images/leg45.png');
    dataList[15] = await rootBundle.load('images/esteira2.png');

    for (int i = 0; i < 16; i++) {
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
          remadaArticuladaSupinada INTEGER,
          puxadaArticulada INTEGER,
          supinoVertical INTEGER,
          crucifixo INTEGER,
          desenvolvimento INTEGER,
          biceps INTEGER,
          elevacaoLateral INTEGER,
          abdominalSupraSolo INTEGER,
          esteira1 INTEGER,
          cadeiraFlexora INTEGER,
          cadeiraExtensora INTEGER,
          legHorizontal INTEGER,
          cadeiraAbdutora INTEGER,
          panturrilhaSentado INTEGER,
          leg45 INTEGER,
          esteira2 INTEGER
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
          remadaArticuladaSupinada: 0,
          puxadaArticulada: 0,
          supinoVertical: 0,
          crucifixo: 0,
          desenvolvimento: 0,
          biceps: 0,
          elevacaoLateral: 0,
          abdominalSupraSolo: 0,
          esteira1: 0,
          cadeiraFlexora: 0,
          cadeiraExtensora: 0,
          legHorizontal: 0,
          cadeiraAbdutora: 0,
          panturrilhaSentado: 0,
          leg45: 0,
          esteira2: 0,
        );
        await insertActivities(activity);
      }
    }

    List<Map<String, dynamic>>? mapsActivities = await db?.query('Activities',
        where: 'date = ?',
        whereArgs: [activitiesNow?.date]);

    if (mapsActivities!.isNotEmpty) {
      setState(() {
        activitiesNow?.remadaArticuladaSupinada =
          mapsActivities.first['remadaArticuladaSupinada'];
        activitiesNow?.puxadaArticulada =
          mapsActivities.first['puxadaArticulada'];
        activitiesNow?.supinoVertical =
          mapsActivities.first['supinoVertical'];
        activitiesNow?.crucifixo = mapsActivities.first['crucifixo'];
        activitiesNow?.desenvolvimento =
          mapsActivities.first['desenvolvimento'];
        activitiesNow?.biceps = mapsActivities.first['biceps'];
        activitiesNow?.elevacaoLateral =
          mapsActivities.first['elevacaoLateral'];
        activitiesNow?.abdominalSupraSolo =
          mapsActivities.first['abdominalSupraSolo'];
        activitiesNow?.esteira1 = mapsActivities.first['esteira1'];
        activitiesNow?.cadeiraFlexora =
          mapsActivities.first['cadeiraFlexora'];
        activitiesNow?.cadeiraExtensora =
          mapsActivities.first['cadeiraExtensora'];
        activitiesNow?.legHorizontal = mapsActivities.first['legHorizontal'];
        activitiesNow?.cadeiraAbdutora =
          mapsActivities.first['cadeiraAbdutora'];
        activitiesNow?.panturrilhaSentado =
          mapsActivities.first['panturrilhaSentado'];
        activitiesNow?.leg45 = mapsActivities.first['leg45'];
        activitiesNow?.esteira2 = mapsActivities.first['esteira2'];
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
        await insertWeight(
            Weight(activity: 'remadaArticuladaSupinada', message: '5 kg'));
        await insertWeight(
            Weight(activity: 'puxadaArticulada', message: '5 kg'));
        await insertWeight(
            Weight(activity: 'supinoVertical', message: '5 kg'));
        await insertWeight(Weight(activity: 'crucifixo', message: '5 kg'));
        await insertWeight(
            Weight(activity: 'desenvolvimento', message: '5 kg'));
        await insertWeight(Weight(activity: 'biceps', message: '1 kg'));
        await insertWeight(
            Weight(activity: 'elevacaoLateral', message: '1 kg'));
        await insertWeight(
            Weight(activity: 'abdominalSupraSolo', message: '0 kg'));
        await insertWeight(Weight(activity: 'esteira1', message: '0%'));
        await insertWeight(
            Weight(activity: 'cadeiraFlexora', message: '5 kg'));
        await insertWeight(
            Weight(activity: 'cadeiraExtensora', message: '5 kg'));
        await insertWeight(Weight(activity: 'legHorizontal', message: '5 kg'));
        await insertWeight(
            Weight(activity: 'cadeiraAbdutora', message: '5 kg'));
        await insertWeight(
            Weight(activity: 'panturrilhaSentado', message: '10 kg'));
        await insertWeight(Weight(activity: 'leg45', message: '10 kg'));
        await insertWeight(Weight(activity: 'esteira2', message: '0%'));
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
      int iRemadaArticuladaSupinada,
      int iPuxadaArticulada,
      int iSupinoVertical,
      int iCrucifixo,
      int iDesenvolvimento,
      int iBiceps,
      int iElevacaoLateral,
      int iAbdominalSupraSolo,
      int iEsteira1,
      int iCadeiraFlexora,
      int iCadeiraExtensora,
      int iLegHorizontal,
      int iCadeiraAbdutora,
      int iPanturrilhaSentado,
      int iLeg45,
      int iEsteira2) async {
    final db = database;
    setState(() {
      activitiesNow?.remadaArticuladaSupinada += iRemadaArticuladaSupinada;
      activitiesNow?.puxadaArticulada += iPuxadaArticulada;
      activitiesNow?.supinoVertical += iSupinoVertical;
      activitiesNow?.crucifixo += iCrucifixo;
      activitiesNow?.desenvolvimento += iDesenvolvimento;
      activitiesNow?.biceps += iBiceps;
      activitiesNow?.elevacaoLateral += iElevacaoLateral;
      activitiesNow?.abdominalSupraSolo += iAbdominalSupraSolo;
      activitiesNow?.esteira1 += iEsteira1;
      activitiesNow?.cadeiraFlexora += iCadeiraFlexora;
      activitiesNow?.cadeiraExtensora += iCadeiraExtensora;
      activitiesNow?.legHorizontal += iLegHorizontal;
      activitiesNow?.cadeiraAbdutora += iCadeiraAbdutora;
      activitiesNow?.panturrilhaSentado += iPanturrilhaSentado;
      activitiesNow?.leg45 += iLeg45;
      activitiesNow?.esteira2 += iEsteira2;
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
    activitiesNow?.remadaArticuladaSupinada = 0;
    activitiesNow?.puxadaArticulada = 0;
    activitiesNow?.supinoVertical = 0;
    activitiesNow?.crucifixo = 0;
    activitiesNow?.desenvolvimento = 0;
    activitiesNow?.biceps = 0;
    activitiesNow?.elevacaoLateral = 0;
    activitiesNow?.abdominalSupraSolo = 0;
    activitiesNow?.esteira1 = 0;
    activitiesNow?.cadeiraFlexora = 0;
    activitiesNow?.cadeiraExtensora = 0;
    activitiesNow?.legHorizontal = 0;
    activitiesNow?.cadeiraAbdutora = 0;
    activitiesNow?.panturrilhaSentado = 0;
    activitiesNow?.leg45 = 0;
    activitiesNow?.esteira2 = 0;
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
                      title: Text('Remada articulada supinada maq 01'),
                      trailing: DropdownButton<String>(
                        value: weights[0]?.message,
                        onChanged: (String? newValue) {
                          setState(() {
                            weights[0] = Weight(
                                activity: 'remadaArticuladaSupinada',
                                message: newValue!);
                            updateWeight('remadaArticuladaSupinada', newValue!);
                          });
                        },
                        items: remadaArticuladaSupinadaOptions
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    ListTile(
                      title: Text('Puxada articulada maq 03'),
                      trailing: DropdownButton<String>(
                        value: weights[1]?.message,
                        onChanged: (String? newValue) {
                          setState(() {
                            weights[1] = Weight(
                                activity: 'puxadaArticulada',
                                message: newValue!);
                            updateWeight('puxadaArticulada', newValue!);
                          });
                        },
                        items: puxadaArticuladaOptions
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    ListTile(
                      title: Text('Supino maq 05'),
                      trailing: DropdownButton<String>(
                        value: weights[2]?.message,
                        onChanged: (String? newValue) {
                          setState(() {
                            weights[2] = Weight(
                                activity: 'supinoVertical', message: newValue!);
                            updateWeight('supinoVertical', newValue!);
                          });
                        },
                        items: supinoVerticalOptions
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    ListTile(
                      title: Text('Crucifixo maq 06'),
                      trailing: DropdownButton<String>(
                        value: weights[3]?.message,
                        onChanged: (String? newValue) {
                          setState(() {
                            weights[3] = Weight(
                                activity: 'crucifixo', message: newValue!);
                            updateWeight('crucifixo', newValue!);
                          });
                        },
                        items: crucifixoOptions
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    ListTile(
                      title: Text('Desenvolvimento maq 07'),
                      trailing: DropdownButton<String>(
                        value: weights[4]?.message,
                        onChanged: (String? newValue) {
                          setState(() {
                            weights[4] = Weight(
                                activity: 'desenvolvimento',
                                message: newValue!);
                            updateWeight('desenvolvimento', newValue!);
                          });
                        },
                        items: desenvolvimentoOptions
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    ListTile(
                      title: Text('Bíceps'),
                      trailing: DropdownButton<String>(
                        value: weights[5]?.message,
                        onChanged: (String? newValue) {
                          setState(() {
                            weights[5] =
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
                        value: weights[6]?.message,
                        onChanged: (String? newValue) {
                          setState(() {
                            weights[6] = Weight(
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
                        value: weights[7]?.message,
                        onChanged: (String? newValue) {
                          setState(() {
                            weights[7] = Weight(
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
                      title: Text('Esteira (min)'),
                      trailing: DropdownButton<String>(
                        value: weights[8]?.message,
                        onChanged: (String? newValue) {
                          setState(() {
                            weights[8] = Weight(
                                activity: 'esteira1', message: newValue!);
                            updateWeight('esteira1', newValue!);
                          });
                        },
                        items: esteira1Options
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    ListTile(
                      title: Text('Cadeira flexora maq 12'),
                      trailing: DropdownButton<String>(
                        value: weights[9]?.message,
                        onChanged: (String? newValue) {
                          setState(() {
                            weights[9] = Weight(
                                activity: 'cadeiraFlexora', message: newValue!);
                            updateWeight('cadeiraFlexora', newValue!);
                          });
                        },
                        items: cadeiraFlexoraOptions
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    ListTile(
                      title: Text('Cadeira extensora maq 13'),
                      trailing: DropdownButton<String>(
                        value: weights[10]?.message,
                        onChanged: (String? newValue) {
                          setState(() {
                            weights[10] = Weight(
                                activity: 'cadeiraExtensora',
                                message: newValue!);
                            updateWeight('cadeiraExtensora', newValue!);
                          });
                        },
                        items: cadeiraExtensoraOptions
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    ListTile(
                      title: Text('Leg horizontal maq 14'),
                      trailing: DropdownButton<String>(
                        value: weights[11]?.message,
                        onChanged: (String? newValue) {
                          setState(() {
                            weights[11] = Weight(
                                activity: 'legHorizontal', message: newValue!);
                            updateWeight('legHorizontal', newValue!);
                          });
                        },
                        items: legHorizontalOptions
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    ListTile(
                      title: Text('Cadeira abdutora maq 16'),
                      trailing: DropdownButton<String>(
                        value: weights[12]?.message,
                        onChanged: (String? newValue) {
                          setState(() {
                            weights[12] = Weight(
                                activity: 'cadeiraAbdutora',
                                message: newValue!);
                            updateWeight('cadeiraAbdutora', newValue!);
                          });
                        },
                        items: cadeiraAbdutoraOptions
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    ListTile(
                      title: Text('Panturrilha sentado maq 26'),
                      trailing: DropdownButton<String>(
                        value: weights[13]?.message,
                        onChanged: (String? newValue) {
                          setState(() {
                            weights[13] = Weight(
                                activity: 'panturrilhaSentado',
                                message: newValue!);
                            updateWeight('panturrilhaSentado', newValue!);
                          });
                        },
                        items: panturrilhaSentadoOptions
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    ListTile(
                      title: Text('Leg 45 maq 29'),
                      trailing: DropdownButton<String>(
                        value: weights[14]?.message,
                        onChanged: (String? newValue) {
                          setState(() {
                            weights[14] =
                                Weight(activity: 'leg45', message: newValue!);
                            updateWeight('leg45', newValue!);
                          });
                        },
                        items: leg45Options
                            .map<DropdownMenuItem<String>>((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                      ),
                    ),
                    ListTile(
                      title: Text('Esteira (min)'),
                      trailing: DropdownButton<String>(
                        value: weights[15]?.message,
                        onChanged: (String? newValue) {
                          setState(() {
                            weights[15] = Weight(
                                activity: 'esteira2', message: newValue!);
                            updateWeight('esteira2', newValue!);
                          });
                        },
                        items: esteira2Options
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
            'remadaArticuladaSupinada': 0,
            'puxadaArticulada': 0,
            'supinoVertical': 0,
            'crucifixo': 0,
            'desenvolvimento': 0,
            'biceps': 0,
            'elevacaoLateral': 0,
            'abdominalSupraSolo': 0,
            'esteira1': 0,
            'cadeiraFlexora': 0,
            'cadeiraExtensora': 0,
            'legHorizontal': 0,
            'cadeiraAbdutora': 0,
            'panturrilhaSentado': 0,
            'leg45': 0,
            'esteira2': 0
          });
        }
      }
      expectedList!.forEach((element) => {
            treino1Counter.add(element["remadaArticuladaSupinada"].toDouble() +
                element["puxadaArticulada"].toDouble() +
                element["supinoVertical"].toDouble() +
                element["crucifixo"].toDouble() +
                element["desenvolvimento"].toDouble() +
                element["biceps"].toDouble() +
                element["elevacaoLateral"].toDouble() +
                element["abdominalSupraSolo"].toDouble() +
                element["esteira1"].toDouble()),
            treino2Counter.add(element["cadeiraFlexora"].toDouble() +
                element["cadeiraExtensora"].toDouble() +
                element["legHorizontal"].toDouble() +
                element["cadeiraAbdutora"].toDouble() +
                element["panturrilhaSentado"].toDouble() +
                element["leg45"].toDouble() +
                element["esteira2"].toDouble()),
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
                            15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
                        activityValue: activitiesNow?.remadaArticuladaSupinada,
                        activityTotal: 45,
                        label: 'Remada articulada\n supinada maq 01',
                        weightMessage: weights[0]?.message ?? '',
                        image: imageList[0]),
                    buildActivityColumn(
                        context: context,
                        onTap: () => updateActivities(
                            0, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
                        activityValue: activitiesNow?.puxadaArticulada,
                        activityTotal: 45,
                        label: 'Puxada articulada\n maq 03',
                        weightMessage: weights[1]?.message ?? '',
                        image: imageList[1]),
                    buildActivityColumn(
                        context: context,
                        onTap: () => updateActivities(
                            0, 0, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
                        activityValue: activitiesNow?.supinoVertical,
                        activityTotal: 45,
                        label: 'Supino\n maq 05',
                        weightMessage: weights[2]?.message ?? '',
                        image: imageList[2]),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    buildActivityColumn(
                        context: context,
                        onTap: () => updateActivities(
                            0, 0, 0, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
                        activityValue: activitiesNow?.crucifixo,
                        activityTotal: 45,
                        label: 'Crucifixo\n maq 06',
                        weightMessage: weights[3]?.message ?? '',
                        image: imageList[3]),
                    buildActivityColumn(
                        context: context,
                        onTap: () => updateActivities(
                            0, 0, 0, 0, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
                        activityValue: activitiesNow?.desenvolvimento,
                        activityTotal: 45,
                        label: 'Desenvolvimento\n maq 07',
                        weightMessage: weights[4]?.message ?? '',
                        image: imageList[4]),
                    buildActivityColumn(
                        context: context,
                        onTap: () => updateActivities(
                            0, 0, 0, 0, 0, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0),
                        activityValue: activitiesNow?.biceps,
                        activityTotal: 45,
                        label: 'Bíceps\n',
                        weightMessage: weights[5]?.message ?? '',
                        image: imageList[5]),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: <Widget>[
                    buildActivityColumn(
                        context: context,
                        onTap: () => updateActivities(
                            0, 0, 0, 0, 0, 0, 15, 0, 0, 0, 0, 0, 0, 0, 0, 0),
                        activityValue: activitiesNow?.elevacaoLateral,
                        activityTotal: 45,
                        label: 'Elevação lateral\n',
                        weightMessage: weights[6]?.message ?? '',
                        image: imageList[6]),
                    buildActivityColumn(
                        context: context,
                        onTap: () => updateActivities(
                            0, 0, 0, 0, 0, 0, 0, 15, 0, 0, 0, 0, 0, 0, 0, 0),
                        activityValue: activitiesNow?.abdominalSupraSolo,
                        activityTotal: 45,
                        label: 'Abdominal supra\n solo',
                        weightMessage: weights[7]?.message ?? '',
                        image: imageList[7]),
                    buildActivityColumn(
                        context: context,
                        onTap: () => updateActivities(
                            0, 0, 0, 0, 0, 0, 0, 0, 15, 0, 0, 0, 0, 0, 0, 0),
                        activityValue: activitiesNow?.esteira1,
                        activityTotal: 45,
                        label: 'Esteira (min)\n',
                        weightMessage: weights[8]?.message ?? '',
                        image: imageList[8]),
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
                            onTap: () => updateActivities(0, 0, 0, 0, 0, 0, 0,
                                0, 0, 15, 0, 0, 0, 0, 0, 0),
                            activityValue: activitiesNow?.cadeiraFlexora,
                            activityTotal: 45,
                            label: 'Cadeira flexora\n maq 12',
                            weightMessage: weights[9]?.message ?? '',
                            image: imageList[9]),
                        buildActivityColumn(
                            context: context,
                            onTap: () => updateActivities(0, 0, 0, 0, 0, 0, 0,
                                0, 0, 0, 15, 0, 0, 0, 0, 0),
                            activityValue: activitiesNow?.cadeiraExtensora,
                            activityTotal: 45,
                            label: 'Cadeira extensora\n maq 13',
                            weightMessage: weights[10]?.message ?? '',
                            image: imageList[10]),
                        buildActivityColumn(
                            context: context,
                            onTap: () => updateActivities(0, 0, 0, 0, 0, 0, 0,
                                0, 0, 0, 0, 15, 0, 0, 0, 0),
                            activityValue: activitiesNow?.legHorizontal,
                            activityTotal: 45,
                            label: 'Leg horizontal\n maq 14',
                            weightMessage: weights[11]?.message ?? '',
                            image: imageList[11]),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        buildActivityColumn(
                            context: context,
                            onTap: () => updateActivities(0, 0, 0, 0, 0, 0, 0,
                                0, 0, 0, 0, 0, 15, 0, 0, 0),
                            activityValue: activitiesNow?.cadeiraAbdutora,
                            activityTotal: 45,
                            label: 'Cadeira abdutora\n maq 16',
                            weightMessage: weights[12]?.message ?? '',
                            image: imageList[12]),
                        buildActivityColumn(
                            context: context,
                            onTap: () => updateActivities(0, 0, 0, 0, 0, 0, 0,
                                0, 0, 0, 0, 0, 0, 15, 0, 0),
                            activityValue: activitiesNow?.panturrilhaSentado,
                            activityTotal: 45,
                            label: 'Panturrilha sentado\n maq 26',
                            weightMessage: weights[13]?.message ?? '',
                            image: imageList[13]),
                        buildActivityColumn(
                            context: context,
                            onTap: () => updateActivities(0, 0, 0, 0, 0, 0, 0,
                                0, 0, 0, 0, 0, 0, 0, 15, 0),
                            activityValue: activitiesNow?.leg45,
                            activityTotal: 45,
                            label: 'Leg 45\n maq 29',
                            weightMessage: weights[14]?.message ?? '',
                            image: imageList[14]),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: <Widget>[
                        buildActivityColumn(
                            context: context,
                            onTap: () => updateActivities(0, 0, 0, 0, 0, 0, 0,
                                0, 0, 0, 0, 0, 0, 0, 0, 15),
                            activityValue: activitiesNow?.esteira2,
                            activityTotal: 45,
                            label: 'Esteira (min)\n',
                            weightMessage: weights[15]?.message ?? '',
                            image: imageList[15]),
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
