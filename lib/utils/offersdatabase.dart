import 'dart:io';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

class OffersDatabase {
  static const _databaseName = "MyDatabasesccmoffers.db";
  static const _databaseVersion = 1;

  static const table = 'my_table_sccm';

  static const columnId = 'id';
  static const colofferId = "offerID";
  static const colstoreid = "StoreID";
  static const colstore = "store";
  static const colcatid = "CategoryID";
  static const coloffername = "OfferName";
  static const colimage = "ItemImages";
  static const colitempromo = "itemPromo";
  static const colitemdetails = "itemDetails";
  static const colimageurl = "imageUrl";
  static const colpromo = "promo";
  static const colstartdate = "startDate";
  static const colenddate = "endDate";
  static const colfloor = "Floor";

  OffersDatabase._privateConstructor();
  static final OffersDatabase instance = OffersDatabase._privateConstructor();

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
            $colofferId INTEGER,
            $colstoreid TEXT,
  $colstore TEXT,
  $colcatid TEXT,
  $coloffername TEXT,
  $colimage TEXT,
  $colitempromo TEXT,
  $colitemdetails TEXT,
  $colimageurl TEXT,
  $colpromo TEXT,
  $colstartdate TEXT,
  $colenddate TEXT,
  $colfloor TEXT
           
           
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
  }

  Future<int> delete() async {
    Database db = await instance.database;
    return await db.delete(table);
    //.delete(table, where: '$columnmajor = ?', whereArgs: [major]);
  }
}
