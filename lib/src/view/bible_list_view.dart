/// Implementa a interface e os fluxos de apresentação deste recurso.
///
/// Este módulo integra a arquitetura interna do aplicativo Bíblia e Harpa.
library;

import 'package:biblia_e_harpa/src/view/component/app_bar_component.dart';
import 'package:biblia_e_harpa/src/controllers/settings_controller.dart';
import 'package:biblia_e_harpa/src/controllers/bible_list_controller.dart';
import 'package:biblia_e_harpa/src/controllers/bible_read_controller.dart';
import 'package:biblia_e_harpa/src/view/component/bible_version_selector_dialog.dart';
import 'package:biblia_e_harpa/src/view/component/feature_search_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'bible_chapter_list_view.dart';

class BibleListView extends StatelessWidget {
  const BibleListView({super.key});

  @override
  Widget build(BuildContext context) {
    final listViewModel = context.watch<BibleListController>();
    final readViewModel = context.watch<BibleReadController>();
    final settings = context.watch<SettingsController>();
    final filteredBible = listViewModel.filterBooks();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(
        title: "Biblia Cristã",
        centerTitle: false,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: Icon(Icons.translate, color: Theme.of(context).colorScheme.secondary),
            tooltip: 'Selecionar versão',
            onPressed: () async {
              await showDialog(
                context: context,
                builder: (context) => BibleVersionSelectorDialog(
                  currentVersionKey: listViewModel.selectedVersionKey,
                  onSelected: (version) {
                    context.read<BibleListController>().setVersionByKey(version.key);
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: !listViewModel.initialized
          ? const Center(child: CircularProgressIndicator())
          : Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: FeatureSearchField(
                hintText: "Pesquisar livro",
                onChanged: (v) => context.read<BibleListController>().setQuery(v),
              ),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.only(top: 10, bottom: 4, left: 10, right: 10),
                itemCount: filteredBible.length,
                itemBuilder: (context, index) {
                  final bookName = filteredBible[index];
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      leading: Icon(Icons.menu_book_rounded,
                          color: Theme.of(context).colorScheme.secondary),
                      title: Text(
                        bookName,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.secondary,
                          fontSize: settings.fontSize,
                        ),
                      ),
                      trailing: Builder(
                        builder: (_) {
                          final bool hasAnyReadChapter = readViewModel.readIds.any(
                            (id) =>
                                id.startsWith("${bookName}_") ||
                                id.startsWith("$bookName "),
                          );
                          return Icon(
                            hasAnyReadChapter
                                ? Icons.check_circle
                                : Icons.check_circle_outline,
                            color: hasAnyReadChapter
                                ? Colors.green
                                : Theme.of(context)
                                    .colorScheme
                                    .secondary
                                    .withValues(alpha: 0.35),
                          );
                        },
                      ),
                      onTap: () {
                        final audioChapters =
                            listViewModel.findAudioChaptersForBook(bookName);
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => BibleChapterListView(
                              name: bookName,
                              jsonPath: listViewModel.jsonAssetPath,
                              audioChapters: audioChapters,
                            ),
                          ),
                        );
                      },
                    ),
                  );
                },
              ),
            ),
          ],
        ),

    );
  }
}
