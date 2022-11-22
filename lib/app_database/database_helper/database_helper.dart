import 'dart:io';

import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

import '../database_naming/database_naming.dart';

class DataBaseHelper {
  DataBaseHelper._();

  static final DataBaseHelper _instance = DataBaseHelper._();

  factory DataBaseHelper() => _instance;
  Database? _database;

  Future<Database> get dataBase async => _database ??= await _initDataBase();

  Future<Database> _initDataBase() async {
    Directory directory = await getApplicationDocumentsDirectory();
    String dataBasePath = join(directory.path, DataBaseNaming.dataBaseName);
    return openDatabase(
      dataBasePath,
      version: DataBaseNaming.dataBaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async => await db.execute('''
  CREATE TABLE ${DataBaseNaming.table} (
	${DataBaseNaming.name}	TEXT,
	${DataBaseNaming.lastName}	TEXT,
	${DataBaseNaming.country}	TEXT,
	${DataBaseNaming.address}	TEXT,
	${DataBaseNaming.education}	INTEGER,
	${DataBaseNaming.id}	INTEGER,
	PRIMARY KEY("_id" AUTOINCREMENT))''');

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < newVersion) {
      Batch batch = db.batch();
      batch.execute(
          "ALTER TABLE ${DataBaseNaming.table} ADD COLUMN ${DataBaseNaming.country} TEXT");
      batch.execute(
          "ALTER TABLE ${DataBaseNaming.table} ADD COLUMN ${DataBaseNaming.address} TEXT");
      await batch.commit();
    }
  }
}
