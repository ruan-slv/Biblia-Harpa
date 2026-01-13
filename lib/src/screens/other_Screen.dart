import 'package:biblia_e_harpa/src/components/button_component.dart';
import 'package:biblia_e_harpa/src/screens/aboutProjectScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Necessário para Clipboard
import 'package:url_launcher/url_launcher.dart';

class OtherScreen extends StatefulWidget {
  const OtherScreen({super.key});

  @override
  State<OtherScreen> createState() => _OtherScreenState();
}

class _OtherScreenState extends State<OtherScreen> {
  // --- Lógica copiada e adaptada da SettingsScreen ---
  final String _pixKey = "5e32d467-b1e8-4db4-ae93-e6767105b704";
  final List<String> _buttonTexts = ["Copiar Chave", "Chave Copiada!"];
  String _currentButtonText = "Copiar Chave";

  @override
  void initState() {
    super.initState();
    _currentButtonText = _buttonTexts[0];
  }

  // Método para copiar a chave Pix
  // Precisamos passar o StateSetter do Dialog para atualizar o texto DENTRO do diálogo
  void _copyToClipboard(StateSetter setStateDialog) {
    Clipboard.setData(ClipboardData(text: _pixKey));

    setStateDialog(() {
      _currentButtonText = _buttonTexts[1];
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setStateDialog(() {
          _currentButtonText = _buttonTexts[0];
        });
      }
    });
  }

  Future<void> _startSuport() async {
    const phoneNumber = "5527988045322";
    const message = "Olá, vim pelo App Bíblia e Harpa e preciso de suporte.";

    final Uri whatsappURL = Uri.parse(
        "https://wa.me/$phoneNumber?text=${Uri.encodeComponent(message)}");

    try {
      if (await canLaunchUrl(whatsappURL)) {
        await launchUrl(
          whatsappURL,
          mode: LaunchMode.externalApplication,
        );
      }
    } catch (_) {}

    if (context.mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ButtonComponent(
                  title: "Política de privacidade",
                  icon: Icon(Icons.info),
                  description:
                      "Leia sobre a nossa política de privacidade e informações importantes do app!",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Aboutprojectscreen(),
                      ),
                    );
                  },
                ),
                // BOTÃO DE APOIO MODIFICADO
                ButtonComponent(
                  title: "Apoio",
                  icon: Icon(Icons.handshake),
                  description: "Seja um apoiador do projeto para nos ajudar.",
                  onPressed: () {
                    showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          // StatefulBuilder é necessário para atualizar o texto do botão DENTRO do Dialog
                          return StatefulBuilder(
                              builder: (context, setStateDialog) {
                            return AlertDialog(
                              backgroundColor:
                                  Theme.of(context).colorScheme.background,
                              title: Text(
                                "Apoio",
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                              ),
                              content: Column(
                                mainAxisSize: MainAxisSize
                                    .min, // Importante para o dialog não ocupar a tela toda
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Nos ajude com uma doação voluntária, qualquer valor é bem vindo!",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                  ),
                                  const SizedBox(height: 20),
                                  Text(
                                    "Chave Pix (Ruan):",
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                  ),
                                  SelectableText(
                                    // Permite selecionar o texto manualmente também
                                    _pixKey,
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        fontSize: 12),
                                  ),
                                  const SizedBox(height: 10),
                                  Center(
                                    child: ElevatedButton.icon(
                                      onPressed: () =>
                                          _copyToClipboard(setStateDialog),
                                      icon: Icon(
                                        Icons.copy,
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary,
                                        size: 20,
                                      ),
                                      label: Text(
                                        _currentButtonText,
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              actions: <Widget>[
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    "Fechar",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                  ),
                                ),
                              ],
                            );
                          });
                        });
                  },
                ),
                ButtonComponent(
                  title: "Suporte",
                  icon: Icon(Icons.people),
                  description:
                      "Entre em contato diretamente com o desenvolvedor para tirar suas dúvidas e dificuldades.",
                  onPressed: () {
                    
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
