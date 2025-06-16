import 'package:flutter/material.dart';
import 'package:biblia_e_harpa/src/config.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Config extends StatefulWidget {
  const Config({super.key});

  @override
  State<Config> createState() => _ConfigState();
}

class _ConfigState extends State<Config> {
  final TextEditingController _fontController = TextEditingController();

  String? _selectedVersion;
  double _fontSize = 16;

  final Map<String, String> _versions = {
    'ACF': 'acf.json',
    'NVI': 'nvi.json',
    'AA': 'aa.json'
  };

  @override
  void initState() {
    super.initState();
    _loadSelectedVersion();
    _loadFontSize();
  }

  Future<void> _loadSelectedVersion() async {
    final prefs = await SharedPreferences.getInstance();
    String savedVersion = prefs.getString("selectedVersion") ?? "acf.json";

    setState(() {
      _selectedVersion = _versions.entries
          .firstWhere((entry) => entry.value == savedVersion,
              orElse: () => _versions.entries.first)
          .key;
    });
  }

  Future<void> _saveSelectedVersion(String versionKey) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("selectedVersion", _versions[versionKey]!);
    setState(() {
      _selectedVersion = versionKey;
    });
  }

  Future<void> _loadFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    double savedFontSize = prefs.getDouble("fontSize") ?? 16;
    setState(() {
      _fontSize = savedFontSize;
      _fontController.text = savedFontSize.toString();
    });
  }

  Future<void> _saveFontSize() async {
    final prefs = await SharedPreferences.getInstance();
    double? newFontSize = double.tryParse(_fontController.text);
    if (newFontSize != null && newFontSize > 0) {
      await prefs.setDouble("fontSize", newFontSize);
      setState(() {
        _fontSize = newFontSize;
      });
    } else {
      _fontSize = 16;
      _fontController.text = _fontSize.toString();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Configurações", style: TextStyle(color: cinzaEscuro)),
        backgroundColor: begeClaro,
        centerTitle: true,
        automaticallyImplyLeading: true,
        iconTheme: const IconThemeData(color: cinzaEscuro),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              Row(
                children: [
                  const Text("Escolha a versão da Bíblia:",
                      style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 20),
                  Container(
                    width: sizeBtnOptions[0], 
                    height: sizeBtnOptions[1], 
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                    decoration: BoxDecoration(
                        color: Colors.white, 
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color.fromARGB(255, 118, 117, 117), width: 1)), 
                    child: Center(
                      child: DropdownButton<String>(
                        value: _selectedVersion,
                        icon: const Icon(Icons.arrow_drop_down, color: Colors.black),
                        dropdownColor: Colors.white,
                        borderRadius: BorderRadius.circular(10),
                        style: const TextStyle(fontSize: 16, color: Colors.black),
                        onChanged: (String? newValue) {
                          if (newValue != null) {
                            _saveSelectedVersion(newValue);
                          }
                        },
                        items: _versions.keys
                            .map<DropdownMenuItem<String>>((String key) {
                          return DropdownMenuItem(
                            value: key,
                            child: Text(key),
                          );
                        }).toList(),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              Row(
                children: [
                  const Text("Tamanho da fonte:", style: TextStyle(fontSize: 18)),
                  const SizedBox(width: 20),
                  SizedBox(
                    width: sizeBtnOptions[0], 
                    height: sizeBtnOptions[1],
                    child: TextField(
                      controller: _fontController,
                      decoration: InputDecoration(
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      keyboardType: TextInputType.number,
                      onSubmitted: (value) {
                        _saveFontSize();
                      },
                    ),
                  ),
                  IconButton(onPressed: _saveFontSize, icon: const Icon(Icons.save)),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}