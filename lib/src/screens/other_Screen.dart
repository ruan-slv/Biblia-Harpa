import 'package:biblia_e_harpa/src/components/button_component.dart';
import 'package:biblia_e_harpa/src/models/carousel_item_model.dart';
import 'package:biblia_e_harpa/src/screens/aboutProjectScreen.dart';
import 'package:biblia_e_harpa/src/screens/informacaoWrapper.dart';
import 'package:carousel_slider/carousel_slider.dart';
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
  // ---------------------------------------------------

  final List<CarouselItemModel> carouselItens = [
    CarouselItemModel(
        "Avalie nosso app",
        "Avalie nosso app e nos ajude a melhorar!",
        Icons.stars,
            () {}),
    CarouselItemModel(
        "Avisos",
        "Fique ligado aos nossos avisos e informações para se manter sempre atualizado!",
        Icons.stars,
            () {}),
    CarouselItemModel(
        "Compartilhe com amigos",
        "Ajude a compartilhar nosso app com amigos e familiares!",
        Icons.share,
            () {}),
    CarouselItemModel("Apoio", "Seja um apoiador do projeto para nos ajudar!",
        Icons.handshake, () {}),
    CarouselItemModel(
        "Suporte",
        "Entre em contato diretamente com o desenvolvedor para tirar suas dúvidas e dificuldades!",
        Icons.code,
            () {}),
    CarouselItemModel(
        "Política de privacidade",
        "Leia sobre a nossa política de privacidade e informações importantes do app!",
        Icons.code,
            () {}),
  ];

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
            Padding(
              padding:
              const EdgeInsets.symmetric(horizontal: 10.0, vertical: 10.0),
              child: CarouselSlider(
                items: carouselItens.map((item) {
                  return Builder(
                    builder: (BuildContext context) {
                      return GestureDetector(
                        onTap: item.onTap,
                        child: Container(
                          width: MediaQuery.of(context).size.width,
                          margin: EdgeInsets.all(10.0),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.primary,
                            borderRadius: BorderRadiusGeometry.circular(20.0),
                            boxShadow: [
                              BoxShadow(
                                color: Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withOpacity(0.4),
                                blurRadius: 10.0,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(10.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  item.icon,
                                  size: 36,
                                  color:
                                  Theme.of(context).colorScheme.secondary,
                                ),
                                const SizedBox(height: 9),
                                Text(
                                  item.title,
                                  style: TextStyle(
                                    fontSize: 18.0,
                                    fontWeight: FontWeight.bold,
                                    color:
                                    Theme.of(context).colorScheme.secondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                                const SizedBox(height: 5),
                                Text(
                                  item.subtitle,
                                  style: TextStyle(
                                    fontSize: 14.0,
                                    color:
                                    Theme.of(context).colorScheme.secondary,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }).toList(),
                options: CarouselOptions(
                  height: 250,
                  autoPlay: true,
                  autoPlayInterval: const Duration(seconds: 4),
                  autoPlayAnimationDuration: const Duration(milliseconds: 900),
                  autoPlayCurve: Curves.fastOutSlowIn,
                  enlargeCenterPage: true,
                  viewportFraction: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 10.0),
            Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ButtonComponent(
                  title: "Avisos",
                  icon: Icon(Icons.info),
                  description:
                  "Canal de informação direto do desenvolvedor para o usuário.",
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => InformacaoWrapper(),
                      ),
                    );
                  },
                ),
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
                                    mainAxisSize: MainAxisSize.min, // Importante para o dialog não ocupar a tela toda
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
                                      SelectableText( // Permite selecionar o texto manualmente também
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
                                          onPressed: () => _copyToClipboard(setStateDialog),
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
                              }
                          );
                        });
                  },
                ),
                ButtonComponent(
                  title: "Suporte",
                  icon: Icon(Icons.people),
                  description:
                  "Entre em contato diretamente com o desenvolvedor para tirar suas dúvidas e dificuldades.",
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          backgroundColor:
                          Theme.of(context).colorScheme.background,
                          title: Text(
                            "Suporte",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary),
                          ),
                          content: Text(
                            "WhatsApp (Ruan): (27) 98804-5322",
                            style: TextStyle(
                                color: Theme.of(context).colorScheme.secondary),
                          ),
                          actions: <Widget>[
                            TextButton(
                              child: Text(
                                "Entre em contato",
                                style: TextStyle(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .secondary),
                              ),
                              onPressed: () => _startSuport(),
                            ),
                          ],
                        );
                      },
                    );
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
