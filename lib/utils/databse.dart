import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseBeacon {
  static const _databaseName = "MyDatabasesccmbeacon.db";
  static const _databaseVersion = 1;

  static const table = 'my_table_sccm';

  static const columnId = 'id';
  static const storeid = 'storeid';
  static const storename = 'storename';
  static const storelogo = 'storelogo';
  static const storefloor = 'storefloor';
  static const storeentity = 'storeentity';
  static const storeemail = 'storeemail';
  static const storecontactno = 'storecontactno';
  static const storeoffers = 'storeoffers';
  static const storekeywords = 'storekeywords';
  static const storeopen = 'storeopen';
  static const storeclose = 'storeclose';
  static const storecategoryid = 'storecategoryid';
  static const storecategoryname = 'storecategoryname';
  static const storecategoryimage = 'storecategoryimage';
  static const storeofferscount = 'storeofferscount';

  DatabaseBeacon._privateConstructor();
  static final DatabaseBeacon instance = DatabaseBeacon._privateConstructor();

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
            $storeid TEXT,
            $storename TEXT,
  $storelogo TEXT,
  $storefloor TEXT,
  $storeentity TEXT,
  $storeemail TEXT,
  $storecontactno TEXT,
  $storeoffers TEXT,
  $storekeywords TEXT,
  $storeopen TEXT,
  $storeclose TEXT,
  $storecategoryid TEXT,
  $storecategoryname TEXT,
  $storecategoryimage TEXT,
  $storeofferscount TEXT
           
           
          )
          ''');
  }

  Future<int> insert(Map<String, dynamic> row) async {
    Database db = await instance.database;
    return await db.insert(table, row);
  }

  Future<List<Map<String, dynamic>>> queryAllRows() async {
    Database db = await instance.database;
    return await db.rawQuery('''SELECT * FROM my_table_sccm ''');
    //SELECT * FROM my_table_sccm WHERE $columndate > time('now','- 5 seconds')''');

    //  return await db.rawQuery('''
    // SELECT * FROM my_table_sccm WHERE $columnarssi > -85.0 and $columnarssi < -0.0 ORDER BY $columnarssi DESC''');

    //'''SELECT * FROM my_table_sccm WHERE $columndate > time('now','- 5 seconds') '''
    //SELECT * FROM my_table_sccm WHERE $columnmajor = 1 and $columnarssi > -95.0 and $columnarssi < -0.0
    // var list2=db.rawQuery('''
    // SELECT * FROM my_table_sccm WHERE $columnarssi > -85.0 and $columnarssi < -0.0
    // ''');
    // db.rawQuery(sql)

    // list1.

    // return await db.rawQuery('''
    // SELECT * FROM my_table_sccm WHERE $columnarssi > -85.0 and $columnarssi < -0.0
    // '''); //, where: '$columnarssi >= -85');
  }

  Future<List<Map<String, dynamic>>> querysearchdata(String text) async {
    Database db = await instance.database;
    return await db.rawQuery(
        '''SELECT * FROM my_table_sccm WHERE storename LIKE '$text%' ''');
  }

  Future<List<Map<String, dynamic>>> querysearchdatafood(text) async {
    Database db = await instance.database;
    return await db.rawQuery(
        '''SELECT * FROM my_table_sccm WHERE storeentity ='Dine' AND storename LIKE '$text%' ''');
    //'''SELECT * FROM my_table_sccm WHERE storeentity ='Dine' AND storename LIKE '%$text%' ORDER BY storename ASC''');
  }

  Future<List<Map<String, dynamic>>> querysearc() async {
    Database db = await instance.database;
    return await db.rawQuery('''SELECT * FROM my_table_sccm ''');
  }

  Future<List<Map<String, dynamic>>> querycategories() async {
    Database db = await instance.database;
    return await db.rawQuery(
        '''SELECT DISTINCT  storecategoryid,storecategoryname,storecategoryimage FROM my_table_sccm ''');
    //'''SELECT storecategoryid,storecategoryname,storecategoryimage FROM my_table_sccm GROUP BY storecategoryid ORDER BY storecategoryname ASC''');
  }

  Future<List<Map<String, dynamic>>> queryalpabet(alphabet) async {
    Database db = await instance.database;
    return await db.rawQuery(
        '''SELECT DISTINCT storename ,storeid,storecategoryid,storelogo,storefloor,storeentity,storeemail,storecontactno,storekeywords,storeopen,storeclose FROM my_table_sccm WHERE storename LIKE '$alphabet%' ''');
    //'''SELECT DISTINCT storename ,storeid,storecategoryid,storelogo,storefloor,storeentity,storeemail,storecontactno,storekeywords,storeopen,storeclose FROM my_table_sccm WHERE storename LIKE '$alphabet%' ORDER BY storename ASC''');
  }

  Future<List<Map<String, dynamic>>> queryfloorwise(floor) async {
    Database db = await instance.database;
    return await db.rawQuery(
        '''SELECT * FROM my_table_sccm WHERE storefloor ='$floor' ''');
    //'''SELECT * FROM my_table_sccm WHERE storefloor ='$floor' ORDER BY storename ASC''');
  }

  Future<List<Map<String, dynamic>>> querysubcategorydata(catid) async {
    Database db = await instance.database;
    return await db.rawQuery(
        '''SELECT * FROM my_table_sccm WHERE storecategoryid ='$catid' ''');
    //'''SELECT * FROM my_table_sccm WHERE storecategoryid ='$catid' ORDER BY storename ASC''');
  }

  Future<int> queryRowCount() async {
    Database db = await instance.database;
    return Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $table'))!;
  }

  Future<List<Map<String, dynamic>>> queryallfood() async {
    Database db = await instance.database;
    return await db
        .rawQuery('''SELECT * FROM my_table_sccm WHERE storeentity ='Dine' ''');
  }

  Future<List<Map<String, dynamic>>> queryfloorwisefood(floor) async {
    Database db = await instance.database;
    return await db.rawQuery(
        '''SELECT * FROM my_table_sccm WHERE storefloor ='$floor' AND storeentity ='Dine' ''');
    //'''SELECT * FROM my_table_sccm WHERE storefloor ='$floor' AND storeentity ='Dine' ORDER BY storename ASC''');
  }

  Future<List<Map<String, dynamic>>> querycafes() async {
    Database db = await instance.database;
    return await db.rawQuery(
        '''SELECT DISTINCT storename ,storeid,storecategoryid,storelogo,storefloor,storeentity,storeemail,storecontactno,storekeywords,storeopen,storeclose FROM my_table_sccm WHERE storecategoryid='D-2' ''');
    //'''SELECT DISTINCT storename ,storeid,storecategoryid,storelogo,storefloor,storeentity,storeemail,storecontactno,storekeywords,storeopen,storeclose FROM my_table_sccm WHERE storecategoryid='D-2' ORDER BY storename ASC''');
  }

  Future<List<Map<String, dynamic>>> querybars() async {
    Database db = await instance.database;
    return await db.rawQuery(
        '''SELECT DISTINCT storename ,storeid,storecategoryid,storelogo,storefloor,storeentity,storeemail,storecontactno,storekeywords,storeopen,storeclose FROM my_table_sccm WHERE storecategoryid = 'D-3' ''');
    //'''SELECT DISTINCT storename ,storeid,storecategoryid,storelogo,storefloor,storeentity,storeemail,storecontactno,storekeywords,storeopen,storeclose FROM my_table_sccm WHERE storecategoryid = 'D-3' ORDER BY storename ASC''');
    //
  }

  // Future<int> update(double rssi, String major, String minor) async {
  //   Database db = await instance.database;
  //   // int id = row[columnmajor];
  //   return await db.rawUpdate('''
  //         UPDATE my_table_sccm
  //   SET $columndate = time('now','localtime')
  //   WHERE $columnmajor = $major and $columnminor = $minor
  //   ''');
  // }

  Future<int> delete() async {
    Database db = await instance.database;
    return await db.delete(table);
    //.delete(table, where: '$columnmajor = ?', whereArgs: [major]);
  }
}
