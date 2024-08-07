import 'dart:io';

import 'package:lumapp/models/car.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path_provider/path_provider.dart';

import 'dart:async';

class CarDB {
  Future<Database> _getDatabase() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();

    String path = join(documentsDirectory.path, "lumapp.db");
    String sql = """
    CREATE TABLE IF NOT EXISTS carros (
        id INTEGER PRIMARY KEY,
        cliente TEXT,
        placa TEXT UNIQUE,
        renavam TEXT,
        chassi TEXT,
        dataVenda INTEGER,
        tipo TEXT,
        color TEXT,
        marca TEXT,
        modelo TEXT,
        anoMod NUMBER,
        anoFab NUMBER,
        vendido BOOLEAN,
        valor FLOAT,
        debitos TEXT DEFAULT "[]",
        procuracoes TEXT DEFAULT "[]"
    );
    """;

    return openDatabase(
      path,
      onCreate: (db, version) {
        return db.execute(
          sql,
        );
      },
      onConfigure: (db) {
        return db.execute(
          sql,
        );
      },
      version: 1,
    );
  }

  Future<void> insertCarro(Car carro) async {
    // Get a reference to the database.
    final db = await _getDatabase();

    print(carro.toMap());
    // carro.toMap().forEach((key, value) { print(value.runtimeType);});

    await db.insert(
      'carros',
      carro.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<void> deleteCarro(Car carro) async {
    final db = await _getDatabase();
    await db.delete('carros', where: 'id = ${carro.id}');
  }

  Future<void> update(Car carro, int id) async {
    final db = await _getDatabase();

    await db.update('carros', carro.toMap(), where: 'id = $id');
  }

  Future<List<Car>> vendidos() async {
    // Get a reference to the database.
    final db = await _getDatabase();

    final List<Map<String, dynamic>> maps = await db.query('carros', where: "vendido = true");

    return List.generate(
      maps.length,
      (i) {
        return Car.fromJSON(maps[i]);
      },
    );
  }

  Future<List<Car>> vendidosByMonth(int month) async {
    // Get a reference to the database.
    final db = await _getDatabase();

    final List<Map<String, dynamic>> maps = await db.query('carros', where: "vendido = true");

    return List.generate(
      maps.length,
      (i) {
        return Car.fromJSON(maps[i]);
      },
    ).where((element) => element.dataVenda.month == month).toList();
  }

  Future<List<Car>> estoque() async {
    // Get a reference to the database.
    final db = await _getDatabase();

    final List<Map<String, dynamic>> maps = await db.query('carros', where: "vendido = false");

    return List.generate(
      maps.length,
      (i) {
        return Car.fromJSON(maps[i]);
      },
    );
  }

  Future<List<Car>> estoqueByMonth(int month) async {
    // Get a reference to the database.
    final db = await _getDatabase();

    final List<Map<String, dynamic>> maps = await db.query('carros', where: "vendido = false");

    return List.generate(
      maps.length,
      (i) {
        return Car.fromJSON(maps[i]);
      },
    ).where((element) => element.dataVenda.month == month).toList();
  }

  Future<void> venderCarro(int id, double valor, DateTime data) async {
    final db = await _getDatabase();

    await db.update('carros', {"vendido": 1, 'valor': valor, "dataVenda": data.millisecondsSinceEpoch},
        where: "id = $id");
  }
}
