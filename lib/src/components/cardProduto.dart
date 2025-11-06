import 'package:biblia_e_harpa/src/controllers/fontSizeController.dart';
import 'package:biblia_e_harpa/src/models/produtoModel.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class CardProduto extends StatelessWidget {
  final ProdutoModel produto;
  const CardProduto({super.key, required this.produto});

  Future<void> _abrirLinkProduto(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // Em um app real, seria bom mostrar um snackbar ou logar o erro.
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      clipBehavior: Clip.antiAlias, // Garante que o conteúdo respeite as bordas arredondadas
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: InkWell( // Adiciona efeito de toque no card inteiro
        onTap: () => _abrirLinkProduto(produto.linkProduto),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Imagem
            AspectRatio(
              aspectRatio: 1 / 1, // Proporção quadrada para a imagem
              child: Image.network(
                produto.imagemURL,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade200,
                    child: Icon(
                      Icons.shopping_bag_outlined,
                      size: 40,
                      color: Colors.grey.shade400,
                    ),
                  );
                },
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return Center(
                    child: CircularProgressIndicator(
                      value: loadingProgress.expectedTotalBytes != null
                          ? loadingProgress.cumulativeBytesLoaded /
                          loadingProgress.expectedTotalBytes!
                          : null,
                      strokeWidth: 2,
                    ),
                  );
                },
              ),
            ),

            // Conteúdo de texto e preço
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Nome do Produto
                  ValueListenableBuilder<double>(
                    valueListenable: FontSizeController.fontSizeNotifier,
                    builder: (context, fontSize, _) {
                      return Text(
                        produto.nome,
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: fontSize - 2, // Fonte um pouco menor para caber
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
