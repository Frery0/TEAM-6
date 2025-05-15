import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'models/gasto.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  factory DatabaseHelper() => _instance;
  DatabaseHelper._internal();

  static Database? _database;

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'gastos.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  Future _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE gastos (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        titulo TEXT,
        categoria TEXT,
        monto TEXT,
        fecha TEXT
      )
    ''');
  }

  Future<int> insertarGasto(Map<String, dynamic> gasto) async {
    final db = await database;
    return await db.insert('gastos', gasto);
  }

  Future<List<Map<String, dynamic>>> obtenerGastos() async {
    final db = await database;
    return await db.query('gastos', orderBy: 'id DESC');
  }

  Future<int> actualizarGasto(Gasto gasto) async {
    final db = await database;
    return await db.update(
      'gastos',
      gasto.toMap(),
      where: 'id = ?',
      whereArgs: [gasto.id],
    );
  }

  Future<int> eliminarGasto(int id) async {
    final db = await database;
    return await db.delete('gastos', where: 'id = ?', whereArgs: [id]);
  }

  Future<void> borrarTodo() async {
    final db = await database;
    await db.delete('gastos');
  }
}

