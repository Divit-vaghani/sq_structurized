import 'dart:convert';

import 'package:sqf_demo/app_database/database_naming/database_naming.dart';
import 'package:sqf_demo/model/user_information.dart';
import 'package:sqflite/sqflite.dart';

import 'database_helper/database_helper.dart';
import 'helper/database_method_helper.dart';

class AppDataBase implements DBHelperMethod<UserInformation> {
  final DataBaseHelper _dataBaseHelper = DataBaseHelper();

  @override
  Future<int> insert(UserInformation data) async {
    Database dataBase = await _dataBaseHelper.dataBase;
    return dataBase.transaction(
      (txn) => txn.insert(
        DataBaseNaming.table,
        data.toJson(),
      ),
    );
  }

  @override
  Future<List<UserInformation>> query() async {
    Database dataBase = await _dataBaseHelper.dataBase;
    List<Map<String, dynamic>> userData = await dataBase.transaction(
      (txn) => txn.query(DataBaseNaming.table),
    );
    return userInformationFromJson(jsonEncode(userData));
  }

  @override
  Future<int> delete({int? data}) async {
    Database dataBase = await _dataBaseHelper.dataBase;
    return data != null
        ? dataBase.transaction(
            (txn) => txn.delete(
              DataBaseNaming.table,
              where: '${DataBaseNaming.id} = ?',
              whereArgs: [data],
            ),
          )
        : dataBase.transaction(
            (txn) => txn.delete(DataBaseNaming.table),
          );
  }

  @override
  Future<int> update(UserInformation data) async {
    Database dataBase = await _dataBaseHelper.dataBase;
    return dataBase.transaction(
      (txn) => txn.update(DataBaseNaming.table, data.toJson()),
    );
  }
}
