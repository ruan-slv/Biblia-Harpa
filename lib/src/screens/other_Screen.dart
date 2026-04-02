import 'package:biblia_e_harpa/src/components/appBarComponent.dart';
import 'package:biblia_e_harpa/src/components/button_component.dart';
import 'package:biblia_e_harpa/src/screens/aboutProjectScreen.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class OtherScreen extends StatefulWidget {
  const OtherScreen({super.key});

  @override
  State<OtherScreen> createState() => _OtherScreenState();
}

class _OtherScreenState extends State<OtherScreen> {
  static const String _pixKey = "5e32d467-b1e8-4db4-ae93-e6767105b704";
  static const String _supportPhone = "5527988045322";

  Future<void> _copyToClipboard() async {
    await Clipboard.setData(const ClipboardData(text: _pixKey));
  }

  Future<void> _openWhatsAppSupport() async {
    const message = "Olá, vim pelo App Bíblia e Harpa e preciso de suporte.";
    final uri = Uri.parse(
      "https://wa.me/$_supportPhone?text=${Uri.encodeComponent(message)}",
    );

    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _showSupportDialog() async {
    final colorScheme = Theme.of(context).colorScheme;

    return showDialog(
      context: context,
      builder: (context) {
        String copyButtonText = "Copiar chave Pix";

        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              backgroundColor: colorScheme.background,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              title: Text(
                "Apoiar o projeto",
                style: TextStyle(
                  color: colorScheme.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sua ajuda contribui com manutenção, melhorias e continuidade do aplicativo.",
                    style: TextStyle(
                      color: colorScheme.secondary.withOpacity(0.82),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    "Chave Pix (Ruan)",
                    style: TextStyle(
                      color: colorScheme.secondary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SelectableText(
                    _pixKey,
                    style: TextStyle(
                      color: colorScheme.secondary,
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    await _copyToClipboard();
                    setStateDialog(() {
                      copyButtonText = "Chave copiada";
                    });
                    Future.delayed(const Duration(seconds: 3), () {
                      if (context.mounted) {
                        setStateDialog(() {
                          copyButtonText = "Copiar chave Pix";
                        });
                      }
                    });
                  },
                  child: Text(
                    copyButtonText,
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
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.background,
      appBar: const CustomAppBar(
        title: "Mais opções",
        centerTitle: false,
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  colorScheme.primary,
                  colorScheme.surface,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Central do projeto",
                  style: TextStyle(
                    color: colorScheme.secondary,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  "Acesse informações importantes, apoio financeiro e canal direto com o desenvolvedor.",
                  style: TextStyle(
                    color: colorScheme.secondary.withOpacity(0.8),
                    height: 1.45,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          ButtonComponent(
            title: "Sobre e privacidade",
            icon: const Icon(Icons.info_outline_rounded),
            description:
                "Leia a proposta do aplicativo e a política de privacidade em uma tela dedicada.",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const Aboutprojectscreen(),
                ),
              );
            },
          ),
          ButtonComponent(
            title: "Apoio",
            icon: const Icon(Icons.volunteer_activism_outlined),
            description:
                "Abra a chave Pix do projeto e faça uma contribuição voluntária, se desejar.",
            onPressed: _showSupportDialog,
          ),
          ButtonComponent(
            title: "Suporte",
            icon: const Icon(Icons.support_agent_outlined),
            description:
                "Entre em contato com o desenvolvedor pelo WhatsApp para dúvidas e feedbacks.",
            onPressed: _openWhatsAppSupport,
          ),
        ],
      ),
    );
  }
}
