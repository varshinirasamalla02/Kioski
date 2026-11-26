import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class EventDatabase {
  static const _databaseName = "MyDatabasesccmevents.db";
  static const _databaseVersion = 1;

  static const table = 'my_table_sccm';

  static const columnId = 'id';
  static const coleventid = "EventID";
  static const coleventname = "EventName";
  static const coldesc = "Description";
  static const colimage = "ImageUrl";
  static const colstartdate = "StartDate";
  static const colenddate = "EndDate";
  static const colwebsite = "WebsiteUrl";
  static const colcontact = "ContactNo";
  static const colagegroup = "AgeGroup";
  static const colopentime = "OpenTime";
  static const colclosetime = "CloseTime";
  static const colsponsered = "Sponsored";
  static const coleventtype = "EventType";

  EventDatabase._privateConstructor();
  static final EventDatabase instance = EventDatabase._privateConstructor();

  static Database? _database;
  Future<Database> get database async {
    if (_database != null) return _database!;

    _database = await _initDatabase();
    return _database!;
  }

  _initDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);
    return await openDatabase(path,
        version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
          CREATE TABLE $table (
            $columnId INTEGER PRIMARY KEY,
            $coleventid TEXT,
            $coleventname TEXT,
  $coldesc TEXT,
  $colimage TEXT,
  $colstartdate TEXT,
  $colenddate TEXT,
  $colwebsite TEXT,
  $colcontact TEXT,
  $colagegroup TEXT,
  $colopentime TEXT,
  $colclosetime TEXT,
  $colsponsered TEXT,
  $coleventtype TEXT
           
           
          )
          ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryevents(type) async {
    Database db = await instance.database;
    return await db.rawQuery(
        '''SELECT * FROM my_table_sccm WHERE EventType ='$type' ORDER BY StartDate ASC''');
  }

  Future<int> delete() async {
    Database db = await instance.database;
    return await db.delete(table);
    //.delete(table, where: '$columnmajor = ?', whereArgs: [major]);
  }
}
