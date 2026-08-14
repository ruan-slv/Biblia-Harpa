/// Define componentes visuais reutilizáveis da interface do aplicativo.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import "package:flutter/material.dart";

class ListViewMd<T> extends StatelessWidget {

  final List<T> items;
  final Widget Function(BuildContext context, T item, int index) itemBuilder;
  final EdgeInsetsGeometry? padding;
  final ScrollPhysics? physics;

  const ListViewMd({super.key, required this.items, required this.itemBuilder, this.padding, this.physics});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: padding ?? const EdgeInsets.symmetric(vertical: 10),
      physics: physics,
      itemCount: items.length,
      itemBuilder: (conext, index) {
        return itemBuilder(context, items[index], index);
      }
    );
  }
}
