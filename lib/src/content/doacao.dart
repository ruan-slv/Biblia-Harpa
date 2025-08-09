import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:share_plus/share_plus.dart';
import "package:url_launcher/url_launcher.dart";

class DataModel {
  final String message;

  DataModel({required this.message});

  factory DataModel.fromJson(Map<String, dynamic> json) {
    return DataModel(
        message: json["message"] ??
            "Mensagem não encontrada."); // Adiciona um fallback
  }
}

class Doacao extends StatefulWidget {
  const Doacao({super.key});

  @override
  State<Doacao> createState() => _DoacaoState();
}

class _DoacaoState extends State<Doacao> {
  final String _jsonPath = "assets/json/apoio.json";
  String? _message; // Torna anulável para indicar estado de carregamento
  bool _isLoading = true; // Flag para controlar o estado de carregamento

  final String _pixKey =
      "5e32d467-b1e8-4db4-ae93-e6767105b704"; // Nome com underscore e final
  final List<String> _buttonTexts = [
    "Copiar Chave",
    "Chave Copiada!"
  ]; // Nome com underscore e final
  String _currentButtonText = "Copiar Chave"; // Estado atual do texto do botão

  final Uri play_store_url = Uri.parse(
      "https://play.google.com/store/apps/details?id=com.bibleAplication.app&pcampaignid=web_share");

  @override
  void initState() {
    super.initState();
    _currentButtonText = _buttonTexts[0]; // Inicializa o texto do botão
    loadMessage();
  }

  Future<void> loadMessage() async {
    setState(() {
      _isLoading = true; // Começa o carregamento
    });
    try {
      final String response =
          await rootBundle.loadString(_jsonPath); // Uso direto do rootBundle
      final List<dynamic> data = json.decode(response);
      if (data.isNotEmpty && data[0] is Map<String, dynamic>) {
        setState(() {
          _message =
              DataModel.fromJson(data[0] as Map<String, dynamic>).message;
          _isLoading = false; // Termina o carregamento
        });
      } else {
        setState(() {
          _message = "Formato de JSON inválido ou lista vazia.";
          _isLoading = false;
        });
      }
    } catch (e) {
      print("Erro ao carregar mensagem de apoio: $e");
      setState(() {
        _message = "Erro ao carregar a mensagem. Tente novamente mais tarde.";
        _isLoading = false; // Termina o carregamento mesmo com erro
      });
    }
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
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        title: Text("Apoio",
            style: TextStyle(color: Theme.of(context).colorScheme.secondary)),
        iconTheme:
            IconThemeData(color: Theme.of(context).colorScheme.secondary),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.center, // Centraliza o conteúdo da coluna
            children: [
              if (_isLoading)
                const Center(child: CircularProgressIndicator())
              else if (_message != null)
                Text(
                  _message!,
                  style: TextStyle(
                      fontSize: 18,
                      color: Theme.of(context).colorScheme.secondary,
                      height: 1.5),
                  textAlign: TextAlign.justify,
                )
              else // Caso _message seja nulo mesmo após o carregamento (pouco provável com o try-catch)
                Text(
                  "Não foi possível carregar a mensagem.",
                  style: TextStyle(
                      fontSize: 18, color: Theme.of(context).colorScheme.error),
                  textAlign: TextAlign.center,
                ),
              const SizedBox(height: 40),
              Text(
                "Está é a única chave Pix oficial",
                style: TextStyle(
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.secondary),
              ),
              Text(
                "Chave Pix Aleatória",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.secondary),
              ),
              const SizedBox(height: 5),
              Text(
                _pixKey, // Mostra a chave pix para o usuário (opcional)
                style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.8)),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              Column(
                children: [
                  SizedBox(
                    width:
                        220, // Aumentado um pouco para caber "Chave Copiada!"
                    height: 50,
                    child: ElevatedButton.icon(
                      icon: Icon(
                        _currentButtonText == _buttonTexts[1]
                            ? Icons.check_circle_outline
                            : Icons.copy_all_outlined,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      label: Text(
                        _currentButtonText,
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.secondary,
                            fontSize: 16),
                      ),
                      onPressed: _copyToClipboard,
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor: Theme.of(context)
                            .colorScheme
                            .secondary, // Cor do ícone e texto quando pressionado/hover
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 220,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Share.share(
                          "📖✨ Descubra uma nova forma de se conectar com a Palavra de Deus!\n\n"
                          "Baixe agora nosso aplicativo gratuito de leitura bíblica e tenha acesso a versículos, harpa e muito mais, tudo na palma da sua mão de forma ofline e sem anúncios.\n\n"
                          "🔗 Acesse aqui: $play_store_url",
                        );
                      },
                      icon: Icon(
                        Icons.share,
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                      label: Text(
                        "Compartilhar App",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    width: 220,
                    height: 50,
                    child: ElevatedButton.icon(
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
                      ),
                      label: Text(
                        "Verificar Atualização",
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        backgroundColor: Theme.of(context).colorScheme.primary,
                        foregroundColor:
                            Theme.of(context).colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Text(
                "Ao contribuir, você nos ajuda a manter e aprimorar este aplicativo, levando a Palavra a mais corações.",
                style: TextStyle(
                    fontSize: 14,
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withOpacity(0.7)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
