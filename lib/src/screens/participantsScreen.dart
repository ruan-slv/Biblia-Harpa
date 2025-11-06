import 'package:biblia_e_harpa/src/controllers/fontSizeController.dart';
import 'package:flutter/material.dart';

class ParticipantsScreen extends StatelessWidget {
  const ParticipantsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.background,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.primary,
        centerTitle: true,
        automaticallyImplyLeading: true,
        iconTheme:
        IconThemeData(color: Theme.of(context).colorScheme.secondary),
        title: Text(
          "Apoiadores",
          style: TextStyle(
            color: Theme.of(context).colorScheme.secondary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsetsGeometry.only(top: 40, left: 16, right: 16, bottom: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ValueListenableBuilder<double>(
              valueListenable: FontSizeController.fontSizeNotifier,
              builder: (context, fontSize, _) {
                return Text(
                    "Este aplicativo de leitura bíblica foi idealizado e desenvolvido por mim, Ruan, estudante de tecnologia e desenvolvedor principal do projeto. A primeira versão foi criada entre os dias 14 e 16 de dezembro de 2024 e publicada na Play Store em 9 de junho de 2025. Até novembro de 2025, todo o desenvolvimento foi realizado de forma solo, incluindo a versão 1.0.9(+19), última atualização feita exclusivamente por mim.\n\n"
                        "A partir de 1º de novembro de 2025, o projeto passou a contar com o apoio de outros estudantes e da minha mãe, que se disponibilizaram para contribuir com diferentes áreas do aplicativo:\n\n"
                        "- Ruan – Fundador e desenvolvedor principal. Atualmente, além de continuar no desenvolvimento, atuo na coordenação da equipe.\n"
                        "- Glaúcia – Minha mãe, responsável pelo tráfego pago e pela divulgação do aplicativo.\n"
                        "- Débora – Integrante da equipe, atua no suporte geral ao projeto.\n"
                        "- Mateus – Integrante da equipe, atua no suporte geral ao projeto.\n"
                        "- Gabriel – Integrante da equipe, atua no suporte geral ao projeto.\n"
                        "- Hyago – Responsável pela curadoria e fornecimento de conteúdos para expansão da base de dados.\n\n"
                        "Meus sinceros agradecimentos a todos que aceitaram apoiar o projeto e acreditaram na proposta. O envolvimento de cada um será extremamente essencial para a continuidade e crescimento desta iniciativa.",
                  style: TextStyle(fontSize: fontSize),textAlign: TextAlign.justify,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
