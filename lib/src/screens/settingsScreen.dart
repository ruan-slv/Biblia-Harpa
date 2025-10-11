import 'package:biblia_e_harpa/src/controllers/fontSizeController.dart';
import 'package:biblia_e_harpa/src/controllers/theme_controller.dart';
import 'package:biblia_e_harpa/src/screens/aboutProjectScreen.dart';
import 'package:biblia_e_harpa/src/screens/transparenciaScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import "package:in_app_review/in_app_review.dart";

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Color newPrimaryColor = Colors.grey.shade300;
  Color newSecondaryColor = Colors.grey.shade900;
  Color newBackgroundColor = Colors.grey.shade400;
  final Uri play_store_url = Uri.parse(
      "https://play.google.com/store/apps/details?id=com.bibleAplication.app&pcampaignid=web_share");

  final String _pixKey =
      "5e32d467-b1e8-4db4-ae93-e6767105b704"; // Nome com underscore e final
  final List<String> _buttonTexts = [
    "Copiar Chave",
    "Chave Copiada!"
  ]; // Nome com underscore e final
  String _currentButtonText = "Copiar Chave"; // Estado atual do texto do botão

  @override
  void initState() {
    super.initState();
    _currentButtonText = _buttonTexts[0]; // Inicializa o texto do botão
  }

  void _copyToClipboard() {
    // Nome com underscore para método privado
    Clipboard.setData(ClipboardData(text: _pixKey));
    setState(() {
      _currentButtonText = _buttonTexts[1]; // Usa o estado atual
    });

    Future.delayed(const Duration(seconds: 3), () {
      // Reduzido o tempo para feedback mais rápido
      if (mounted) {
        // Verifica se o widget ainda está montado
        setState(() {
          _currentButtonText = _buttonTexts[0];
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeNotifier,
      builder: (context, currentTheme, _) {
        final isDark = currentTheme == ThemeMode.dark;
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
          appBar: AppBar(
            backgroundColor: Theme.of(context).colorScheme.primary,
            centerTitle: true,
            automaticallyImplyLeading: true,
            iconTheme:
                IconThemeData(color: Theme.of(context).colorScheme.secondary),
            title: Text(
              "Configurações",
              style: TextStyle(
                color: Theme.of(context).colorScheme.secondary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SingleChildScrollView(
            padding:
                const EdgeInsets.only(top: 40, left: 16, right: 16, bottom: 16),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ValueListenableBuilder<double>(
                  valueListenable: FontSizeController.fontSizeNotifier,
                  builder: (context, fontSize, _) {
                    return Card(
                      color: Theme.of(context).colorScheme.primary,
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Tamanho da Fonte",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            ValueListenableBuilder<double>(
                              valueListenable:
                                  FontSizeController.fontSizeNotifier,
                              builder: (context, fontSize, _) {
                                return Text(
                                  "Ajuste o tamanho das letras para melhor leitura.",
                                  style: TextStyle(
                                    fontSize: fontSize,
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                  textAlign: TextAlign.start,
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Tamanho atual: ${fontSize.toStringAsFixed(0)} pt",
                                  style: TextStyle(
                                    color:
                                        Theme.of(context).colorScheme.secondary,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        double newSize =
                                            (fontSize - 2).clamp(16.0, 30.0);
                                        FontSizeController.setFontSize(newSize);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      child: Text(
                                        "A-",
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    ElevatedButton(
                                      onPressed: () {
                                        double newSize =
                                            (fontSize + 2).clamp(16.0, 30.0);
                                        FontSizeController.setFontSize(newSize);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Theme.of(context)
                                            .colorScheme
                                            .primary,
                                      ),
                                      child: Text(
                                        "A+",
                                        style: TextStyle(
                                          color: Theme.of(context)
                                              .colorScheme
                                              .secondary,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
                Card(
                  color: Theme.of(context).colorScheme.primary,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Tema do Aplicativo",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ValueListenableBuilder<double>(
                          valueListenable: FontSizeController.fontSizeNotifier,
                          builder: (context, fontSize, _) {
                            return Text(
                              "Altere entre o modo claro e escuro conforme sua preferência.",
                              style: TextStyle(
                                fontSize: fontSize,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => ThemeController.toggleTheme(),
                          icon: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            transitionBuilder: (child, animation) {
                              return RotationTransition(
                                turns: Tween(begin: 0.0, end: 1.0)
                                    .animate(animation),
                                child: child,
                              );
                            },
                            child: isDark
                                ? const Icon(Icons.sunny,
                                    key: Key("sunny"),
                                    color: Colors.yellow,
                                    size: 20)
                                : Icon(Icons.brightness_4,
                                    key: const Key("moon"),
                                    color: Colors.grey[800],
                                    size: 20),
                          ),
                          label: Text(
                            Theme.of(context).brightness == Brightness.dark
                                ? "claro"
                                : "escuro",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                        ),

                        // Theme(
                        //   data: Theme.of(context).copyWith(
                        //     popupMenuTheme: PopupMenuThemeData(
                        //       color: Theme.of(context).colorScheme.primary,
                        //       textStyle: TextStyle(
                        //         color: Theme.of(context).colorScheme.secondary,
                        //       ),
                        //     ),
                        //   ),
                        //   child: PopupMenuButton<String>(
                        //     child: Container(
                        //       height: 40,
                        //       width: 200,
                        //       decoration: BoxDecoration(
                        //         color: Theme.of(context).colorScheme.primary,
                        //         borderRadius: BorderRadius.circular(20),
                        //       ),
                        //       child: Row(
                        //         crossAxisAlignment: CrossAxisAlignment.center,
                        //         mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        //         children: [
                        //           Icon(
                        //             Icons.palette,
                        //             color:
                        //                 Theme.of(context).colorScheme.secondary,
                        //           ),
                        //           Text(
                        //             "Selecione um tema",
                        //             style: TextStyle(
                        //               color:
                        //                   Theme.of(context).colorScheme.secondary,
                        //             ),
                        //           ),
                        //         ],
                        //       ),
                        //     ),
                        //     onSelected: (value) async {
                        //       if (value == "light") {
                        //         await ThemeController.updateCustomColors(
                        //           primary: Colors.grey.shade300,
                        //           secondary: Colors.grey.shade900,
                        //           background: Colors.grey.shade100,
                        //         );
                        //       } else if (value == "dark") {
                        //         ThemeController.updateCustomColors(
                        //             primary: Colors.grey.shade700,
                        //             secondary: Colors.grey.shade100,
                        //             background: Colors.grey.shade900,
                        //         );
                        //       } else if (value == "quente") {
                        //         await ThemeController.updateCustomColors(
                        //           primary: Colors.deepOrange.shade300,
                        //           secondary: Colors.redAccent.shade700,
                        //           background: Colors.orange.shade100,
                        //         );
                        //       } else if (value == "frio") {
                        //         await ThemeController.updateCustomColors(
                        //           primary: Colors.blue.shade600,
                        //           secondary: Colors.white,
                        //           background: Colors.blueGrey.shade400,
                        //         );
                        //       }
                        //     },
                        //     itemBuilder: (context) => [
                        //       PopupMenuItem(
                        //         value: "light",
                        //         child: Text(
                        //           "Tema claro",
                        //           style: TextStyle(
                        //             color:
                        //                 Theme.of(context).colorScheme.secondary,
                        //           ),
                        //         ),
                        //       ),
                        //       PopupMenuItem(
                        //         value: "dark",
                        //         child: Text(
                        //           "Tema escuro",
                        //           style: TextStyle(
                        //             color:
                        //                 Theme.of(context).colorScheme.secondary,
                        //           ),
                        //         ),
                        //       ),
                        //       PopupMenuItem(
                        //         value: "quente",
                        //         child: Text(
                        //           "Tema quente",
                        //           style: TextStyle(
                        //             color:
                        //                 Theme.of(context).colorScheme.secondary,
                        //           ),
                        //         ),
                        //       ),
                        //       PopupMenuItem(
                        //         value: "frio",
                        //         child: Text(
                        //           "Tema frio",
                        //           style: TextStyle(
                        //             color:
                        //                 Theme.of(context).colorScheme.secondary,
                        //           ),
                        //         ),
                        //       )
                        //     ],
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: Theme.of(context).colorScheme.primary,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Compartilhar App",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ValueListenableBuilder<double>(
                          valueListenable: FontSizeController.fontSizeNotifier,
                          builder: (context, fontSize, _) {
                            return Text(
                              "Compartilhe o nosso app com familiares e amigos a fim de alcançar mais pessoas.",
                              style: TextStyle(
                                fontSize: fontSize,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            Share.share(
                              "📖✨ Descubra uma nova forma de se conectar com a Palavra de Deus!\n\n"
                              "Baixe agora nosso aplicativo gratuito de leitura bíblica e tenha acesso a versiculos, harpa e muito mais, tudo na palma da sua mão de forma ofline e sem anúncios.\n\n"
                              "🔗 Acesse aqui: $play_store_url",
                            );
                          },
                          icon: Icon(
                            Icons.share,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 20,
                          ),
                          label: Text(
                            "Compartilhar",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: Theme.of(context).colorScheme.primary,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Verificar Atualizações",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ValueListenableBuilder<double>(
                          valueListenable: FontSizeController.fontSizeNotifier,
                          builder: (context, fontSize, _) {
                            return Text(
                              "Verifique se há novas atualizações disponíveis na Play store.",
                              style: TextStyle(
                                fontSize: fontSize,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () async {
                            if (!await launchUrl(play_store_url,
                                mode: LaunchMode.externalApplication)) {
                              throw Exception(
                                  "Não foi possivel abrir a Play Store");
                            }
                          },
                          icon: Icon(
                            Icons.update,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 20,
                          ),
                          label: Text(
                            "Verificar",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: Theme.of(context).colorScheme.primary,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Apoiar o projeto",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ValueListenableBuilder<double>(
                          valueListenable: FontSizeController.fontSizeNotifier,
                          builder: (context, fontSize, _) {
                            return Text(
                              "Faça parte do projeto com uma doação para ajudar no desenvolvimento e manutenção do aplicativo.",
                              style: TextStyle(
                                fontSize: fontSize,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 10),
                        ValueListenableBuilder<double>(
                          valueListenable: FontSizeController.fontSizeNotifier,
                          builder: (context, fontSize, _) {
                            return Text(
                              "Esta é a única chave pix para doações\n$_pixKey",
                              style: TextStyle(
                                fontSize: fontSize,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () => _copyToClipboard(),
                          icon: Icon(
                            Icons.copy,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 20,
                          ),
                          label: Text(
                            _currentButtonText,
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: Theme.of(context).colorScheme.primary,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sobre o app e política de privacidade",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ValueListenableBuilder<double>(
                          valueListenable: FontSizeController.fontSizeNotifier,
                          builder: (context, fontSize, _) {
                            return Text(
                              "Confira informações sobre o aplicativo e nossa política de privacidade.",
                              style: TextStyle(
                                fontSize: fontSize,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const Aboutprojectscreen(),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.info,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 20,
                          ),
                          label: Text(
                            "Conferir",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: Theme.of(context).colorScheme.primary,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Avaliação do app",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ValueListenableBuilder<double>(
                          valueListenable: FontSizeController.fontSizeNotifier,
                          builder: (context, fontSize, _) {
                            return Text(
                              "Nos ajude a alcançar boas notas na Playstore para alcançarmos mais pessoas atraves de uma avaliação.",
                              style: TextStyle(
                                fontSize: fontSize,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () async {
                            final InAppReview inAppReview =
                                InAppReview.instance;
                            if (await inAppReview.isAvailable()) {
                              inAppReview.openStoreListing(
                                appStoreId: "com.bibleAplication.app",
                              );
                            }
                          },
                          icon: Icon(
                            Icons.star,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 20,
                          ),
                          label: Text(
                            "Avaliar app",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  color: Theme.of(context).colorScheme.primary,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Transparência de contribuições do app",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                            color: Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 4),
                        ValueListenableBuilder<double>(
                          valueListenable: FontSizeController.fontSizeNotifier,
                          builder: (context, fontSize, _) {
                            return Text(
                              "Veja como a sua contribuição está sendo direcionada",
                              style: TextStyle(
                                fontSize: fontSize,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        ElevatedButton.icon(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    const TransparenciaScreen(),
                              ),
                            );
                          },
                          icon: Icon(
                            Icons.info,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 20,
                          ),
                          label: Text(
                            "Acessar Transparência",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.primary,
                          ),
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
    );
  }
}
