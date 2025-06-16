import 'dart:convert';

import 'package:biblia_e_harpa/src/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Data {
  final int index;
  final String palavra;

  Data({required this.index, required this.palavra});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(index: json["index"], palavra: json["palavra"]);
  }
}

class PalavraDoDia extends StatelessWidget {
  const PalavraDoDia({super.key});

  Future<List<Data>> loadData() async {
    try {
      String jsonString = await rootBundle.loadString("");
      Map<String, dynamic> jsonResponse = jsonDecode(jsonString);
      List<Data> data = [];
      jsonResponse.forEach((key, value) {
        data.add(Data.fromJson(value));
      });
      return data;
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: begeClaro,
        centerTitle: true,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: cinzaEscuro),
        title: const Text(
          "Palavra do Dia",
          style: TextStyle(color: cinzaEscuro),
        ),
      ),
      body: const SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Center(
              child: Text("Em desenvolvimento, aguarde atualizações futuras."),
            ),
          ],
        ),
      ),
    );
  }
}
