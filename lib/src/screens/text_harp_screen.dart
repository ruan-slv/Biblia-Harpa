import 'dart:convert';
import 'package:biblia_e_harpa/src/config.dart';
import 'package:biblia_e_harpa/src/controllers/fontSizeController.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class TextModel {
  final String hino;
  final String coro;
  final Map<String, String> verses;

  TextModel({required this.hino, required this.coro, required this.verses});

  factory TextModel.fromJson(Map<String, dynamic> json) {
    return TextModel(
      hino: json['hino'] ?? 'Hino não encontrado',
      coro: json['coro'] ?? 'Não possui coro',
      verses: Map<String, String>.from(json['verses'] ?? {}),
    );
  }
}

class HarpContentScreen extends StatefulWidget {
  const HarpContentScreen({super.key, required this.harp});

  final String harp;

  @override
  State<HarpContentScreen> createState() => _HarpContentScreenState();
}

class _HarpContentScreenState extends State<HarpContentScreen> {
  Future<List<TextModel>> loadTexts() async {
    try {
      String jsonString = await rootBundle
          .loadString('assets/json/harpa_crista_640_hinos.json');
      Map<String, dynamic> jsonResponse = jsonDecode(jsonString);
      List<TextModel> texts = [];
      jsonResponse.forEach((key, value) {
        texts.add(TextModel.fromJson(value));
      });
      return texts;
    } catch (_) {
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text(
          widget.harp,
          style: TextStyle(color: Theme.of(context).colorScheme.secondary),
        ),
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.secondary),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: FutureBuilder<List<TextModel>>(
          future: loadTexts(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            if (snapshot.hasError) {
              return const Center(
                child: Text('Erro ao carregar os textos.'),
              );
            }
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text('Nenhum texto encontrado.'),
              );
            }

            final harpText = snapshot.data!.firstWhere(
              (text) =>
                  text.hino.toLowerCase().trim() ==
                  widget.harp.toLowerCase().trim(),
              orElse: () => TextModel(hino: '', coro: '', verses: {}),
            );

            return SingleChildScrollView(
              child: SizedBox(
                width: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "** CORO **",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    ValueListenableBuilder<double>(
                      valueListenable: FontSizeController.fontSizeNotifier,
                      builder: (context, fontSize, _) {
                        return Text(
                          harpText.coro,
                          style: TextStyle(
                            fontSize: fontSize,
                            fontWeight: FontWeight.bold,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                          textAlign: TextAlign.center,
                        );
                      },
                    ),
                    const SizedBox(height: 30),
                    ...harpText.verses.entries.map(
                      (entry) => Padding(
                        padding: const EdgeInsets.only(bottom: 30.0),
                        child: Column(
                          children: [
                            Text(
                              entry.key,
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            ValueListenableBuilder<double>(
                              valueListenable:
                                  FontSizeController.fontSizeNotifier,
                              builder: (context, fontSize, _) {
                                return Text(
                                  entry.value,
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                  textAlign: TextAlign.center,
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
