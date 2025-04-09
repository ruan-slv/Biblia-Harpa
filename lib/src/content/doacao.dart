import 'package:biblia_e_harpa/src/config.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class Doacao extends StatefulWidget {
  const Doacao({super.key});

  @override
  State<Doacao> createState() => _DoacaoState();
}

class _DoacaoState extends State<Doacao> {

  String message =
    "Contribua para Manter o Aplicativo Disponível e em Funcionamento!\n\nNosso aplicativo foi criado com dedicação para oferecer uma experiência enriquecedora e acessível a todos. No entanto, ele não gera receita por download na Play Store / Apple Store. A monetização ocorre apenas por meio de anúncios e produtos pagos, sejam eles oferecidos dentro do aplicativo ou na instalação.\n\nSabemos que muitos usuários preferem uma experiência livre de anúncios ou não têm interesse em adquirir produtos. Por isso, as doações voluntárias se tornam essenciais para mantermos o aplicativo funcionando, atualizado e disponível para todos. Sua contribuição, independente do valor, ajuda a cobrir os custos de desenvolvimento, manutenção, servidores e melhorias contínuas.\n\nSe você aprecia o que oferecemos e deseja apoiar esse projeto, considere fazer uma doação. Juntos, podemos garantir que o aplicativo continue sendo uma ferramenta acessível para todos os usuários.\n\nMuito obrigado por fazer parte dessa jornada!";

  String pixKey = "5e32d467-b1e8-4db4-ae93-e6767105b704";
  List <String> buttonText = ["Copiar Chave", "Chave Copiada!"];

  void copyToClipboard() {
    Clipboard.setData(ClipboardData(text: pixKey));
    setState(() {
      buttonText[0] = buttonText[1];
    });

    Future.delayed(const Duration(seconds: 5), () {
      setState(() {
        buttonText[0] = "Copiar Chave";
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: redColor,
        title: const Text("Doação", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text(
                message,
                style: const TextStyle(fontSize: 18),
                textAlign: TextAlign.justify,
              ),
              const SizedBox(height: 40),
              const Text("Chave Pix Aleatória"),
              const SizedBox(height: 10),
              SizedBox(
                width: 200,
                height: 50,
                child: ElevatedButton(
                  onPressed: () => {
                    copyToClipboard()
                  },
                  style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      backgroundColor: redColor),
                  child: Text(
                    buttonText[0],
                    style: const TextStyle(color: Colors.white, fontSize: 16),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
