import 'package:biblia_e_harpa/src/models/avisoModel.dart';
import 'package:flutter/material.dart';

class CardAvisoComponent extends StatelessWidget {
  final AvisoModel aviso;
  const CardAvisoComponent({super.key, required this.aviso});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(
        horizontal: 16.0,
        vertical: 8.0,
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget> [
            Center(
              child: ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(8.0),
                child: Image.network(
                  aviso.imagemURL,
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      height: 150,
                      width: double.infinity,
                      color: Colors.grey.shade300,
                      child: Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey.shade600,
                      ),
                    );
                  },
                ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              aviso.titulo,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.secondary,
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              aviso.descricao,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
              ),
              overflow: TextOverflow.ellipsis, // Adiciona "..." se o texto for muito longo
            ),
            const SizedBox(height: 8.0),
            Text(
              aviso.dataPublicacao,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.7),
              ),
              maxLines: 3, // Limita o número de linhas para a descrição
              overflow: TextOverflow.ellipsis, // Adiciona "..." se o texto for muito longo
            ),
          ],
        ),
      ),
    );
  }
}
