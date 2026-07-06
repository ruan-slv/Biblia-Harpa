import 'package:biblia_e_harpa/src/view/component/app_section_card.dart';
import 'package:biblia_e_harpa/src/view_model/settings_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

class SettingsView extends StatelessWidget {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    return _SettingsContent();
  }
}

class _SettingsContent extends StatelessWidget {
  _SettingsContent();

  /*static const String _supportEmail = "suporte.biblia.noads@gmail.com";
  static const String _apoiaSeURL = "https://apoia.se/friendapp";
  static const String _playStoreURL =
      "https://play.google.com/store/apps/details?id=com.bibleAplication.app&pcampaignid=web_share";
  static const String _pixKey = "5e32d467-b1e8-4db4-ae93-e6767105b704";*/

  static final String _supportEmail = dotenv.env["SUPPORT_EMAIL"] ?? "Email de suporte não encontrado!";
  static final String _apoiaSeURL = dotenv.env["APOIASE_URL"] ?? "Link de apoio não encontrado!";
  static final String _playStoreURL = dotenv.env["PLAYSTORE_URL"] ?? "";
  static final String _pixKey = dotenv.env["PIX_KEY"] ?? "";




  final Uri _playStoreUrl = Uri.parse(_playStoreURL);
  final Uri _apoiase = Uri.parse(_apoiaSeURL);

  void copyPixKey(BuildContext context) {
    Clipboard.setData(ClipboardData(text: _pixKey));
    Navigator.pop(context);
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Chave PIX copiada com sucesso!"),
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  Future<void> _startSupport(BuildContext context) async {
    const subject = "Pedido de suporte";

    final uri = Uri(
      scheme: 'mailto',
      path: _supportEmail,
      query: _encodeQueryParameters({
        'subject': subject,
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

  Future<void> _showSupportDialog(BuildContext context) async {
    final colorScheme = Theme.of(context).colorScheme;

    return showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: colorScheme.surface,
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
              onPressed: () => _startSupport(context),
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

  Future<void> _openExternal(Uri url) async {
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      throw Exception("Não foi possível abrir a Play Store");
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Consumer<SettingsViewModel>(
      builder: (context, viewModel, _) {
        return Scaffold(
          backgroundColor: colorScheme.surface,
          body: ListView(
            padding:
                const EdgeInsets.symmetric(vertical: 15.0, horizontal: 25.0),
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
                          "Tamanho atual: ${viewModel.fontSize.toStringAsFixed(0)} pt",
                          style: TextStyle(color: colorScheme.secondary),
                        ),
                        const SizedBox(height: 12),
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            ElevatedButton(
                              onPressed: viewModel.decreaseFontSize,
                              child: const Text("A-"),
                            ),
                            ElevatedButton(
                              onPressed: viewModel.increaseFontSize,
                              child: const Text("A+"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppSectionCard(
                    icon: viewModel.isDarkMode
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
                          width: 280,
                          child: Text(
                            viewModel.isDarkMode
                                ? "Modo escuro ativo"
                                : "Modo claro ativo",
                            style: TextStyle(
                              color: colorScheme.secondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: viewModel.toggleTheme,
                          icon: Icon(viewModel.isDarkMode
                              ? Icons.sunny
                              : Icons.brightness_2),
                          label: Text(viewModel.isDarkMode
                              ? "Usar claro"
                              : "Usar escuro"),
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
                      onPressed: () async => await _openExternal(_playStoreUrl),
                      icon: const Icon(Icons.open_in_new_rounded),
                      label: const Text("Abrir Play Store"),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppSectionCard(
                    icon: Icons.coffee_rounded,
                    title: "Apoiar projeto",
                    subtitle:
                        "Apoie este projeto voluntário da forma que preferir.",
                    child: ElevatedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              backgroundColor: colorScheme.surface,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              title: Text(
                                "Apoio",
                                style: TextStyle(
                                  color: colorScheme.secondary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              content: Text(
                                "Nos apoie compartilhando este aplicativo com cinco conhecidos. Nossa prioridade é alcançar mais pessoas. Caso queira contribuir com a manutenção da infraestrutura e com a expansão do app para Desktop e iOS, considere fazer uma doação. (sugestão: Não doe valores acima de R\$ 5 reais, pois desejamos apenas o mínimo para funcionamento.).",
                                style: TextStyle(color: colorScheme.secondary),
                              ),
                              actions: [
                                TextButton(
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
                                  child: Text(
                                    "Compartilhar app",
                                    style:
                                        TextStyle(color: colorScheme.secondary),
                                  ),
                                ),
                                TextButton(
                                  // Dispara uma janela externa para Apoia.se
                                  onPressed: () async =>
                                      await _openExternal(_apoiase),
                                  child: Text(
                                    "Apoio mensal",
                                    style:
                                        TextStyle(color: colorScheme.secondary),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => copyPixKey(context),
                                  child: Text(
                                    "Apoio único",
                                    style:
                                        TextStyle(color: colorScheme.secondary),
                                  ),
                                ),
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text(
                                    "Fechar",
                                    style:
                                        TextStyle(color: colorScheme.secondary),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                      },
                      icon: const Icon(Icons.info_outline_rounded),
                      label: const Text("Ver mais"),
                    ),
                  ),
                  const SizedBox(height: 16),
                  AppSectionCard(
                    icon: Icons.support_agent_rounded,
                    title: "Suporte",
                    subtitle:
                        "Entre em contato por e-mail para pedir ajuda ou enviar feedback.",
                    child: ElevatedButton.icon(
                      onPressed: () => _showSupportDialog(context),
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
  }
}
