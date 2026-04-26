import 'package:biblia_e_harpa/src/components/app_section_card.dart';
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
  static const String _supportEmail = "suporte.biblia.noads@gmail.com";

  final Uri _playStoreUrl = Uri.parse(
    "https://play.google.com/store/apps/details?id=com.bibleAplication.app&pcampaignid=web_share",
  );

  Future<void> _startSupport() async {
    const subject = "Suporte - Aplicativo Bíblia";
    const body = "Olá, gostaria de ajuda com...";

    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      query: _encodeQueryParameters({
        'subject': subject,
        'body': body,
      }),
    );

    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      debugPrint("Não foi possível abrir o e-mail: $e");
    }

    if (context.mounted) {
      Navigator.of(context).pop();
    }
  }

  String _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map(
          (entry) =>
              '${Uri.encodeComponent(entry.key)}=${Uri.encodeComponent(entry.value)}',
        )
        .join('&');
  }

  Future<void> _showSupportDialog() async {
    final colorScheme = Theme.of(context).colorScheme;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colorScheme.background,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          title: Text(
            "Suporte",
            style: TextStyle(
              color: colorScheme.secondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          content: Text(
            "E-mail: $_supportEmail",
            style: TextStyle(color: colorScheme.secondary),
          ),
          actions: [
            TextButton(
              onPressed: _startSupport,
              child: Text(
                "Entrar em contato",
                style: TextStyle(color: colorScheme.secondary),
              ),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                "Fechar",
                style: TextStyle(color: colorScheme.secondary),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _openStore() async {
    if (!await launchUrl(_playStoreUrl, mode: LaunchMode.externalApplication)) {
      throw Exception("Não foi possível abrir a Play Store");
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeNotifier,
      builder: (context, currentTheme, _) {
        final isDark = currentTheme == ThemeMode.dark;
        final colorScheme = Theme.of(context).colorScheme;

        return ValueListenableBuilder<double>(
          valueListenable: FontSizeController.fontSizeNotifier,
          builder: (context, fontSize, _) {
            return Scaffold(
              backgroundColor: colorScheme.surface,
              body: ListView(
                padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 25.0),
                children: [
                   Column(
                      children: [
                        AppSectionCard(
                          icon: Icons.format_size_rounded,
                          title: "Tamanho da fonte",
                          subtitle:
                              "Defina um tamanho confortável para leitura em todas as telas de texto.",
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Tamanho atual: ${fontSize.toStringAsFixed(0)} pt",
                                style: TextStyle(color: colorScheme.secondary),
                              ),
                              const SizedBox(height: 12),
                              Wrap(
                                spacing: 8,
                                runSpacing: 8,
                                children: [
                                  ElevatedButton(
                                    onPressed: () {
                                      FontSizeController.setFontSize(
                                        (fontSize - 2).clamp(16.0, 30.0),
                                      );
                                    },
                                    child: const Text("A-"),
                                  ),
                                  ElevatedButton(
                                    onPressed: () {
                                      FontSizeController.setFontSize(
                                        (fontSize + 2).clamp(16.0, 30.0),
                                      );
                                    },
                                    child: const Text("A+"),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppSectionCard(
                          icon: isDark
                              ? Icons.dark_mode_rounded
                              : Icons.light_mode_rounded,
                          title: "Tema do aplicativo",
                          subtitle:
                              "Alterne entre os modos claro e escuro conforme o ambiente e sua preferência.",
                          child: Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            crossAxisAlignment: WrapCrossAlignment.center,
                            children: [
                              SizedBox(
                                width:  280,
                                child: Text(
                                  isDark
                                      ? "Modo escuro ativo"
                                      : "Modo claro ativo",
                                  style: TextStyle(
                                    color: colorScheme.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                onPressed: ThemeController.toggleTheme,
                                icon:
                                    Icon(isDark ? Icons.sunny : Icons.brightness_2),
                                label: Text(isDark ? "Usar claro" : "Usar escuro"),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppSectionCard(
                          icon: Icons.share_outlined,
                          title: "Compartilhar app",
                          subtitle:
                              "Envie o aplicativo para familiares e amigos e ajude mais pessoas a alcançarem esse conteúdo.",
                          child: ElevatedButton.icon(
                            onPressed: () {
                              SharePlus.instance.share(
                                ShareParams(
                                  text:
                                      "📖✨ Descubra uma nova forma de se conectar com a Palavra de Deus!\n\n"
                                      "Baixe agora nosso aplicativo gratuito de leitura bíblica e tenha acesso a versiculos, harpa e muito mais, tudo na palma da sua mão de forma ofline e sem anúncios.\n\n"
                                      "🔗 Acesse aqui: $_playStoreUrl",
                                ),
                              );
                            },
                            icon: const Icon(Icons.share),
                            label: const Text("Compartilhar"),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppSectionCard(
                          icon: Icons.system_update_alt_rounded,
                          title: "Atualizações e avaliação",
                          subtitle:
                              "Abra a Play Store para verificar novas versões e avaliar o aplicativo.",
                          child: ElevatedButton.icon(
                            onPressed: _openStore,
                            icon: const Icon(Icons.open_in_new_rounded),
                            label: const Text("Abrir Play Store"),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppSectionCard(
                          icon: Icons.privacy_tip_outlined,
                          title: "Sobre o app e privacidade",
                          subtitle:
                              "Veja informações do projeto e leia a política de privacidade em uma tela dedicada.",
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => const Aboutprojectscreen(),
                                ),
                              );
                            },
                            icon: const Icon(Icons.info_outline_rounded),
                            label: const Text("Abrir informações"),
                          ),
                        ),
                        const SizedBox(height: 16),
                        AppSectionCard(
                          icon: Icons.support_agent_rounded,
                          title: "Suporte",
                          subtitle:
                              "Entre em contato por e-mail para pedir ajuda ou enviar feedback.",
                          child: ElevatedButton.icon(
                            onPressed: _showSupportDialog,
                            icon: const Icon(Icons.mail_outline_rounded),
                            label: const Text("Solicitar suporte"),
                          ),
                        ),
                      ],
                    ),

                ],
              ),
            );
          },
        );
      },
    );
  }
}
