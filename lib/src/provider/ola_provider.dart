import 'package:flutter/material.dart';
import '../database/db_helper.dart';

class OlaProvider extends ChangeNotifier {
  List<String> mensagens = [];

  Future<void> carregar() async {
    mensagens = await DBHelper.getAll();
    notifyListeners();
  }

  Future<void> adicionar(String msg) async {
    await DBHelper.insert(msg);
    await carregar();
  }

  Future<void> limpar() async {
    await DBHelper.clear();
    mensagens = [];
    notifyListeners();
  }
}