import 'dart:convert';
import 'package:biblia_e_harpa/src/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

class DevocionalScreen extends StatefulWidget {
  const DevocionalScreen({super.key});

  @override
  _DevocionalScreenState createState() => _DevocionalScreenState();
}

class _DevocionalScreenState extends State<DevocionalScreen> {
  List<dynamic> devocionais = [];
  int index = 0;

  @override
  void initState() {
    super.initState();
    _loadLastIndex();
    loadDevocionais();
  }

  Future<void> _loadLastIndex() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      index = prefs.getInt('lastDevocionalIndex') ?? 0;
    });
  }

  Future<void> _saveLastIndex() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastDevocionalIndex', index);
  }

  Future<void> loadDevocionais() async {
    final String response =
        await rootBundle.loadString('assets/json/devocional.json');
    final data = json.decode(response);
    setState(() {
      devocionais = data['devocionais'];
    });
  }

  void proximoDevocional() {
    setState(() {
      index = (index + 1) % devocionais.length;
      _saveLastIndex();
    });
  }

  void anteriorDevocional() {
    setState(() {
      index = (index - 1 + devocionais.length) % devocionais.length;
      _saveLastIndex();
    });
  }

  void initialDevocional() {
    setState(() {
      index = 0;
      _saveLastIndex();
    });
    loadDevocionais();
  }

  @override
  Widget build(BuildContext context) {
    if (devocionais.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final devocional = devocionais[index];
    return Scaffold(
      backgroundColor: brancoNeve,
      appBar: AppBar(
        backgroundColor: azulSereno,
        title: const Text("Devocional 365 Dias", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
        actions: [
          SizedBox(
            width: sizeBtnOptions[0],
            height: sizeBtnOptions[1],
            child: IconButton(
              onPressed: initialDevocional,
              icon: const Icon(Icons.refresh),
              color: brancoNeve,
              tooltip: "Reiniciar o devocional",
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Text(
              //   'Dia ${devocional["data"]}',
              //   style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              // ),
              const SizedBox(height: 10),
              Text(
                '${devocional["texto"]}',
                style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: cinzaEscuro),
              ),
              Text(
                '- ${devocional["versiculo"]}',
                style: const TextStyle(fontSize: 16, color: cinzaClaro),
              ),
              const SizedBox(height: 20),
              const Text(
                'Reflexão',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cinzaEscuro),
              ),
              const SizedBox(height: 10),
              Text(devocional["reflexao"], style: const TextStyle(fontSize: 16, color: cinzaEscuro)),
              const SizedBox(height: 20),
              const Text(
                'Oração',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: cinzaEscuro),
              ),
              const SizedBox(height: 10),
              Text(devocional["oracao"], style: const TextStyle(fontSize: 16, color: cinzaEscuro)),
              const SizedBox(height: 20), // Espaço final para evitar sobreposição
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        color: Colors.transparent, // Cor de fundo semelhante à AppBar
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Botão Anterior
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: cinzaEscuro,
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: anteriorDevocional,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                  backgroundColor: Colors.white, // Contraste com o fundo
                  foregroundColor: cinzaEscuro,
                ),
                child: const Icon(Icons.arrow_back, size: 24, color: cinzaEscuro),
              ),
            ),
            const SizedBox(width: 20), // Espaço entre os botões
            // Botão Próximo
            Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    // ignore: deprecated_member_use
                    color: cinzaEscuro,
                    spreadRadius: 2,
                    blurRadius: 5,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: proximoDevocional,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                  backgroundColor: Colors.white, // Contraste com o fundo
                  foregroundColor: cinzaEscuro,
                ),
                child: const Icon(Icons.arrow_forward, size: 24, color: cinzaEscuro),
              ),
            ),
          ],
        ),
      ),
    );
  }
}