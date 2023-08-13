import 'dart:developer';
import 'dart:io';
import 'package:faker/faker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqf_demo/app_database/app_database.dart';
import 'package:sqf_demo/app_database/database_naming/database_naming.dart';
import 'package:sqf_demo/model/user_information.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Sqflite'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final Faker faker = Faker();
  late final AppDataBase appDataBase;

  @override
  void initState() {
    super.initState();
    RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
    appDataBase = AppDataBase(rootIsolateToken);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
        actions: [
          IconButton(
            onPressed: () async {
              RootIsolateToken rootIsolateToken = RootIsolateToken.instance!;
              await addToMuchData(rootIsolateToken);
            },
            icon: const Icon(Icons.add),
          ),
          IconButton(
            onPressed: () async {
              final data = await saveDatabaseToInternalStorage();
              log(data, name: "PATH");
            },
            icon: const Icon(Icons.save),
          ),
        ],
      ),
      body: FutureBuilder<List<UserInformation>>(
        future: appDataBase.queryPagination(10000),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return ListView(
              children: snapshot.data!
                  .map(
                    (element) => ExpansionTile(
                      initiallyExpanded: true,
                      title: Text('${element.name} ${element.lastName}'),
                      trailing: IconButton(
                        onPressed: () async {
                          appDataBase.delete(data: element.id);
                          setState(() {});
                        },
                        icon: const Icon(Icons.delete),
                      ),
                      children: [
                        ListTile(
                          title: Text('Address : ${element.address}'),
                        ),
                        ListTile(
                          title: Text('Country : ${element.country}'),
                        ),
                        ListTile(
                          title: Text('Education : ${element.education}'),
                        ),
                      ],
                    ),
                  )
                  .toList(),
            );
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      ),
    );
  }
}

Future<void> addToMuchData(RootIsolateToken value) async {
  AppDataBase appDataBase = AppDataBase(value);
  List<UserInformation> info = await compute(listOfData, value);
  await appDataBase.insertLargeData(info);
  log("INSERTATION SUCCESS");
}

List<UserInformation> listOfData(RootIsolateToken value) {
  BackgroundIsolateBinaryMessenger.ensureInitialized(value);
  List<UserInformation> info = <UserInformation>[];
  for (int i = 0; i < 2000000; i++) {
    final data = UserInformation(
      name: faker.person.name(),
      lastName: faker.person.lastName(),
      education: faker.company.position(),
      address: faker.address.streetAddress(),
      country: faker.address.country(),
    );
    info.add(data);
  }
  return info;
}

Future<String> saveDatabaseToInternalStorage() async {
  Directory directory = await getApplicationDocumentsDirectory();
  String dataBasePath = join(directory.path, DataBaseNaming.dataBaseName);
  final currentDataBase = File(dataBasePath);
  final external = await getExternalStorageDirectory();
  final newDataBase = join(external!.path, DataBaseNaming.dataBaseName);
  await File(newDataBase).writeAsBytes(await currentDataBase.readAsBytes());
  return newDataBase;
}
