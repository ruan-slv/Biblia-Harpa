import 'dart:convert';
import 'package:biblia_e_harpa/src/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:shared_preferences/shared_preferences.dart';

class TextModel {
  final String versiculo;
  final String texto;
  final String oracao;

  TextModel({required this.versiculo, required this.texto, required this.oracao});

  factory TextModel.fromJson(Map<String, dynamic> json) {
    return TextModel(
      versiculo: json['versiculo'] ?? 'Versículo não encontrado',
      texto: json['texto'] ?? 'Texto não encontrado',
      oracao: json['Oração'] ?? 'Oração não encontrada',
    );
  }
}

class DevocionalContentScreen extends StatefulWidget {
  const DevocionalContentScreen({super.key, required this.devo});

  final String devo;

  @override
  _DevocionalContentScreenState createState() => _DevocionalContentScreenState();
}

class _DevocionalContentScreenState extends State<DevocionalContentScreen> {
  List<TextModel> devocionais = [];
  int currentIndex = 0;

  @override
  void initState() {
    super.initState();
    loadDevocionais();
  }

  Future<void> loadDevocionais() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/json/newDevocionalModel.json');
      final Map<String, dynamic> jsonResponse = jsonDecode(jsonString);
      final List<dynamic> topicDevocionais = jsonResponse[widget.devo] ?? [];
      setState(() {
        devocionais = topicDevocionais.map((json) => TextModel.fromJson(json)).toList();
      });
    } catch (e) {
      print('Error loading devotionals: $e');
      setState(() {
        devocionais = [];
      });
    }
  }

  void nextDevocional() {
    setState(() {
      currentIndex = (currentIndex + 1) % devocionais.length;
    });
  }

  void previousDevocional() {
    setState(() {
      currentIndex = (currentIndex - 1 + devocionais.length) % devocionais.length;
    });
  }

  void initialDevocional() {
    setState(() {
      currentIndex = 0;
      _saveLastIndex();
    });
    loadDevocionais();
  }

  Future<void> _saveLastIndex() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('lastDevocionalIndex', currentIndex);
  }

  @override
  Widget build(BuildContext context) {
    if (devocionais.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.background,
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.primary,
          title: Text(widget.devo, style:  TextStyle(color: Theme.of(context).colorScheme.secondary)),
          actions: [
            SizedBox(
              width: sizeBtnOptions[0],
              height: sizeBtnOptions[1],
              child: IconButton(
                onPressed: initialDevocional,
                icon: const Icon(Icons.refresh),
                color: Theme.of(context).colorScheme.secondary,
                tooltip: "Reiniciar o devocional",
              ),
            ),
          ],
          centerTitle: true,
        ),
        body: const Center(
          child: Text('Nenhum devocional encontrado para este tema'),
        ),
      );
    }

    final devocional = devocionais[currentIndex];
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(widget.devo, style:  TextStyle(color: Theme.of(context).colorScheme.secondary)),
        iconTheme:  IconThemeData(color: Theme.of(context).colorScheme.secondary),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                devocional.versiculo,
                style:  TextStyle(fontSize: 18, fontStyle: FontStyle.italic, color: Theme.of(context).colorScheme.secondary),
              ),
              const SizedBox(height: 20),
               Text(
                'Reflexão',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
              ),
              const SizedBox(height: 10),
              Text(
                devocional.texto,
                style:  TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.secondary),
              ),
              const SizedBox(height: 20),
               Text(
                'Oração',
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.secondary),
              ),
              const SizedBox(height: 10),
              Text(
                devocional.oracao,
                style:  TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.secondary),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 20),
        color: Colors.transparent,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 0.5,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: devocionais.length > 1 ? previousDevocional : null,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.secondary,
                ),
                child:  Icon(Icons.arrow_back, size: 24, color: Theme.of(context).colorScheme.secondary),
              ),
            ),
            const SizedBox(width: 20),
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 0.5,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: ElevatedButton(
                onPressed: devocionais.length > 1 ? nextDevocional : null,
                style: ElevatedButton.styleFrom(
                  shape: const CircleBorder(),
                  padding: const EdgeInsets.all(12),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Theme.of(context).colorScheme.secondary,
                ),
                child:  Icon(Icons.arrow_forward, size: 24, color: Theme.of(context).colorScheme.secondary),
              ),
            ),
          ],
        ),
      ),
    );
  }
}