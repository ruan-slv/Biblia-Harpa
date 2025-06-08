import 'package:biblia_e_harpa/src/config.dart';
import 'package:flutter/material.dart';

class PalavraDoDia extends StatefulWidget {
  const PalavraDoDia({super.key});

  @override
  State<PalavraDoDia> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<PalavraDoDia> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: mainColor,
          centerTitle: true,
          automaticallyImplyLeading: true,
          iconTheme: const IconThemeData(color: brancoNeve),
          title: const Text(
            "Palavra do Dia",
            style: TextStyle(color: brancoNeve),
          ),
        ),
        body: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("Em desenvolvimento, aguarde atualizações futuras"),
            ],
          ),
        ));
  }
}
