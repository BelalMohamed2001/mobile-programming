import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/event_model.dart';
import '../models/gift_model.dart';
import '../models/auth_model.dart';

class DatabaseHelper {
  static final _databaseName = "local.db";
  static final _databaseVersion = 1;

  static final userTable = 'users';
  static final eventsTable = 'events';
  static final giftsTable = 'gifts';
  static final pendingQueueTable = 'pending_operations'; // For pending operations

  DatabaseHelper._privateConstructor();
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    String path = join(await getDatabasesPath(), _databaseName);
    return await openDatabase(path, version: _databaseVersion, onCreate: _onCreate);
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE $userTable(
        uid TEXT PRIMARY KEY,
        name TEXT,
        email TEXT,
        phoneNumber TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $eventsTable(
        id TEXT PRIMARY KEY,
        name TEXT,
        category TEXT,
        status TEXT,
        userId TEXT,
        date TEXT,
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE $giftsTable(
        id TEXT PRIMARY KEY,
        name TEXT,
        category TEXT,
        price REAL,
        pledged INTEGER,
        pledgedBy TEXT,
        eventId TEXT,
        description TEXT,
        imageUrl TEXT
      )
    ''');

    // Create table for pending operations
    await db.execute('''
      CREATE TABLE $pendingQueueTable(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        table_name TEXT,
        operation TEXT,
        data TEXT,
        status TEXT
      )
    ''');
  }

  // CRUD for Users
  Future<int> insertUser(UserModel user) async {
    Database db = await database;
    return await db.insert(userTable, user.toMapSQLite());
  }

  Future<UserModel?> getUser(String uid) async {
    Database db = await database;
    List<Map<String, dynamic>> result =
        await db.query(userTable, where: "uid = ?", whereArgs: [uid]);
    return result.isNotEmpty ? UserModel.fromMapSQLite(result.first) : null;
  }

  Future<int> updateUser(UserModel user) async {
    Database db = await database;
    return await db.update(
      userTable,
      user.toMapSQLite(),
      where: "uid = ?",
      whereArgs: [user.uid],
    );
  }

  // CRUD for Events
  Future<int> insertEvent(EventModel event) async {
    Database db = await database;
    return await db.insert(eventsTable, event.toMapSQLite());
  }

  Future<int> deleteEvent(String eventId) async {
    Database db = await database;
    return await db.delete(eventsTable, where: "id = ?", whereArgs: [eventId]);
  }

  Future<int> updateEvent(EventModel event) async {
    Database db = await database;
    return await db.update(eventsTable, event.toMapSQLite(), where: "id = ?", whereArgs: [event.id]);
  }

  Future<List<EventModel>> fetchEvents(String userId) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(eventsTable, where: "userId = ?", whereArgs: [userId]);
    return result.isNotEmpty ? result.map((map) => EventModel.fromMapSQLite(map)).toList() : [];
  }

  // CRUD for Gifts
  Future<int> insertGift(Gift gift) async {
    Database db = await database;
    return await db.insert(giftsTable, gift.toMapSQLite());
  }

  Future<int> updateGift(Gift gift) async {
    Database db = await database;
    return await db.update(giftsTable, gift.toMapSQLite(), where: "id = ?", whereArgs: [gift.id]);
  }

  Future<int> deleteGift(String giftId) async {
    Database db = await database;
    return await db.delete(giftsTable, where: "id = ?", whereArgs: [giftId]);
  }

  Future<List<Gift>> fetchGifts(String eventId) async {
    Database db = await database;
    List<Map<String, dynamic>> result = await db.query(giftsTable, where: "eventId = ?", whereArgs: [eventId]);
    return result.isNotEmpty ? result.map((map) => Gift.fromMapSQLite(map)).toList() : [];
  }

  // Pending Operations for Sync
  Future<int> insertPendingOperation(String tableName, String operation, String data) async {
    Database db = await database;
    Map<String, dynamic> row = {
      'table_name': tableName,
      'operation': operation,
      'data': data,
      'status': 'pending'
    };
    return await db.insert(pendingQueueTable, row);
  }

  Future<List<Map<String, dynamic>>> fetchPendingOperations() async {
    Database db = await database;
    return await db.query(pendingQueueTable, where: "status = ?", whereArgs: ['pending']);
  }

  Future<int> updatePendingOperationStatus(int id, String status) async {
    Database db = await database;
    return await db.update(pendingQueueTable, {'status': status}, where: "id = ?", whereArgs: [id]);
  }
}
