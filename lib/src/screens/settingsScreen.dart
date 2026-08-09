import 'package:biblia_e_harpa/src/controllers/fontSizeController.dart';
import 'package:biblia_e_harpa/src/controllers/theme_controller.dart';
import 'package:biblia_e_harpa/src/screens/aboutProjectScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

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

  @override
  void initState() {
    super.initState();
  }

  Future<void> _startSupport() async {
    // Corrigi o erro de digitação de "Suport" para "Support"
    const email = "suporte.biblia.noads@gmail.com";
    const subject =
        "Suporte - Aplicativo Bíblia"; // Opcional: Assunto do e-mail
    const body = "Olá, gostaria de ajuda com..."; // Opcional: Corpo do e-mail

    // Criamos a URI usando o esquema mailto
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: email,
      query: encodeQueryParameters(<String, String>{
        'subject': subject,
        'body': body,
      }),
    );

    try {
      // Para mailto, o modo externalApplication é o mais recomendado
      await launchUrl(emailLaunchUri, mode: LaunchMode.externalApplication);
    } catch (e) {
      // Caso o dispositivo não tenha app de e-mail configurado
      debugPrint("Não foi possível abrir o e-mail: $e");
    }

    if (context.mounted) Navigator.of(context).pop();
  }

// Função auxiliar para codificar corretamente espaços e caracteres especiais na URL
  String? encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeNotifier,
      builder: (context, currentTheme, _) {
        final isDark = currentTheme == ThemeMode.dark;
        return Scaffold(
          backgroundColor: Theme.of(context).colorScheme.background,
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
                          borderRadius: BorderRadius.circular(20)),
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
                                            .background,
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
                                            .background,
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
                      borderRadius: BorderRadius.circular(20)),
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
                                Theme.of(context).colorScheme.background,
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
                      borderRadius: BorderRadius.circular(20)),
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
                                Theme.of(context).colorScheme.background,
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
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Verificar Atualizações e avaliar app",
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
                              "Avalie nosso app ou Verifique se há novas atualizações disponíveis na Play store.",
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
                                Theme.of(context).colorScheme.background,
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
                      borderRadius: BorderRadius.circular(20)),
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
                                Theme.of(context).colorScheme.background,
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
                      borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Suporte",
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
                              "Entre em contato para solicitar suporte ou nos dar um feedback.",
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
                            showDialog(
                              context: context,
                              builder: (BuildContext context) {
                                return AlertDialog(
                                  backgroundColor:
                                      Theme.of(context).colorScheme.background,
                                  title: Text(
                                    "Suporte",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
                                  ),
                                  content: Text(
                                    "E-mail: suporte.biblia.noads@gmail.com",
                                    style: TextStyle(
                                        color: Theme.of(context)
                                            .colorScheme
                                            .secondary),
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
                                      onPressed: () => _startSupport(),
                                    ),
                                  ],
                                );
                              },
                            );
                          },
                          icon: Icon(
                            Icons.help,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 20,
                          ),
                          label: Text(
                            "Solicitar suporte",
                            style: TextStyle(
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                Theme.of(context).colorScheme.background,
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
