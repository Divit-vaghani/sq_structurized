import 'dart:convert';
import 'dart:developer';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sqf_demo/app_database/database_naming/database_naming.dart';
import 'package:sqf_demo/model/user_information.dart';

import 'database_helper/database_helper.dart';
import 'helper/database_method_helper.dart';

class AppDataBase implements DBHelperMethod<UserInformation> {
  final RootIsolateToken isolateToken;

  AppDataBase(this.isolateToken);

  @override
  Future<int> insertAll(List<UserInformation> dataList) async {
    final DataBaseHelper db = DataBaseHelper();
    final database = await db.dataBase;
    final batch = database.batch();
    for (UserInformation data in dataList) {
      batch.insert(
        DataBaseNaming.table,
        data.toJson(),
      );
    }
    final results = await batch.commit();
    return results.length;
  }

  @override
  Future<int> insert(UserInformation data) async {
    final DataBaseHelper db = DataBaseHelper();
    final database = await db.dataBase;
    return database.transaction(
      (txn) => txn.insert(
        DataBaseNaming.table,
        data.toJson(),
      ),
    );
  }

  @override
  Future<List<UserInformation>> query() async {
    final DataBaseHelper db = DataBaseHelper();
    final database = await db.dataBase;
    List<Map<String, dynamic>> userData = await database.transaction(
      (txn) => txn.query(DataBaseNaming.table),
    );
    return userInformationFromJson(jsonEncode(userData));
  }

  Future<List<UserInformation>> queryPagination(int value) async {
    final DataBaseHelper db = DataBaseHelper();
    final database = await db.dataBase;
    List<Map<String, dynamic>> userData = await database.transaction(
      (txn) => txn.query(DataBaseNaming.table, limit: value),
    );
    return userInformationFromJson(jsonEncode(userData));
  }

  @override
  Future<int> delete({int? data}) async {
    final DataBaseHelper db = DataBaseHelper();
    final database = await db.dataBase;
    return data != null
        ? database.transaction(
            (txn) => txn.delete(
              DataBaseNaming.table,
              where: '${DataBaseNaming.id} = ?',
              whereArgs: [data],
            ),
          )
        : database.transaction(
            (txn) => txn.delete(DataBaseNaming.table),
          );
  }

  @override
  Future<int> update(UserInformation data) async {
    final DataBaseHelper db = DataBaseHelper();
    final database = await db.dataBase;
    return database.transaction(
      (txn) => txn.update(DataBaseNaming.table, data.toJson()),
    );
  }

  Future<void> insertLargeData(List<UserInformation> dataList) async {
    const batchSize = 50000;
    final totalBatches = (dataList.length / batchSize).ceil();
    for (int i = 0; i < totalBatches; i++) {
      final start = i * batchSize;
      final end = (i + 1) * batchSize;
      final batchData = dataList.sublist(start, end);
      await compute(_insertBatchInBackground, batchData);
      await Future.delayed(const Duration(milliseconds: 100));
      log("From $start to $end Total : ${batchData.length}", name: "HEAVY");
    }
  }

  Future<void> _insertBatchInBackground(List<UserInformation> batchData) async {
    BackgroundIsolateBinaryMessenger.ensureInitialized(isolateToken);
    final DataBaseHelper db = DataBaseHelper();
    final database = await db.dataBase;
    final batch = database.batch();
    for (UserInformation data in batchData) {
      batch.insert(
        DataBaseNaming.table,
        data.toJson(),
      );
    }
    await batch.commit();
    await database.close();
  }
}
