import 'dart:convert';
import 'dart:math';

import 'package:biblia_e_harpa/src/config.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Data {
  final int id;
  final String texto;
  final String versiculo;

  Data({required this.id, required this.texto, required this.versiculo});

  factory Data.fromJson(Map<String, dynamic> json) {
    return Data(
      id: json["id"],
      texto: json["texto"],
      versiculo: json["versiculo"],
    );
  }
}

class PalavraDoDia extends StatefulWidget {
  const PalavraDoDia({super.key});

  @override
  State<PalavraDoDia> createState() => _PalavraDoDiaState();
}

class _PalavraDoDiaState extends State<PalavraDoDia> {
  Data? palavraAtual;
  DateTime? ultimaAtualizacao;

  @override
  void initState() {
    super.initState();
    _loadPalavraDoDia();
  }

  Future<void> _loadPalavraDoDia() async {
    final prefs = await SharedPreferences.getInstance();
    final String? lastUpdate = prefs.getString("last_update");
    final String? palavraSalva = prefs.getString("palavra_atual");

    final now = DateTime.now();
    bool precisaAtualizar = lastUpdate == null || DateTime.parse(lastUpdate).difference(now).inDays.abs() >= 1;

    if (!precisaAtualizar && palavraSalva != null) {
      setState(() {
        palavraAtual = Data.fromJson(jsonDecode(palavraSalva));
        ultimaAtualizacao = DateTime.parse(lastUpdate);
      });
      return;
    }

    try {
      final String jsonString = await DefaultAssetBundle.of(context).loadString("assets/json/palavraDoDia.json");
      final List<dynamic> jsonResponse = jsonDecode(jsonString)["palavraDoDia"];

      final randomIndex = Random().nextInt(jsonResponse.length);
      final selectedPalavra = jsonResponse[randomIndex];

      setState(() {
        palavraAtual = Data.fromJson(selectedPalavra);
        ultimaAtualizacao = now;
      });

      await prefs.setString("last_update", now.toIso8601String());
      await prefs.setString("palavra_atual", jsonEncode(selectedPalavra));
    } catch (e) {
      print("Erro ao carregar dado: ${e.toString()}");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erro ao carregar a palavra do dia: ${e.toString()}")),
      );
    }
  }

  void _compartilharPalavra() {
    if (palavraAtual != null) {
      Share.share("${palavraAtual!.texto} \n ${palavraAtual!.versiculo}");
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
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  Text(
                    palavraAtual?.texto ?? "Palavra do dia não encontrada",
                    style: const TextStyle(
                      fontSize: 18,
                      fontStyle: FontStyle.italic,
                      color: cinzaEscuro,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 20),
                  Text(
                    palavraAtual?.versiculo ?? "Versículo não encontrado",
                    style: const TextStyle(fontSize: 16, color: cinzaClaro),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 80),
                ],
              ),
            ),
          ),
          Positioned(
            left: 20,
            right: 20,
            bottom: 20,
            child: SizedBox(
              height: 50,
              child: ElevatedButton(
                child: const Text("Compartilhar", style: TextStyle(color: cinzaEscuro, fontSize: 16)),
                onPressed: _compartilharPalavra,
                style: ElevatedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  backgroundColor: begeClaro,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
