import 'package:biblia_e_harpa/src/view/component/app_bar_component.dart';
import 'package:biblia_e_harpa/src/utils/config.dart';
import 'package:biblia_e_harpa/src/view_model/settings_view_model.dart';
import 'package:biblia_e_harpa/src/keys/bible_key.dart';
import 'package:biblia_e_harpa/src/view_model/bible_list_view_model.dart';
import 'package:biblia_e_harpa/src/view_model/bible_read_view_model.dart';
import 'package:biblia_e_harpa/src/view/component/bible_version_menu.dart';
import 'package:biblia_e_harpa/src/view/component/feature_search_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'bible_chapter_list_view.dart';

class BibleListView extends StatelessWidget {
  const BibleListView({super.key});

  @override
  Widget build(BuildContext context) {
    final listViewModel = context.watch<BibleListViewModel>();
    final readViewModel = context.watch<BibleReadViewModel>();
    final settings = context.watch<SettingsViewModel>();
    final filteredBible = listViewModel.filterBooks(books);

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: CustomAppBar(
        title: "Biblia Cristã",
        centerTitle: false,
        automaticallyImplyLeading: true,
        actions: [
          SizedBox(
            width: sizeBtnOptions[0],
            height: sizeBtnOptions[1],
            child: Theme(
              data: Theme.of(context).copyWith(
                popupMenuTheme: PopupMenuThemeData(
                  color: Theme.of(context).colorScheme.primary,
                  textStyle: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                ),
              ),
              child: BibleVersionMenu(
                onSelected: (key) => context.read<BibleListViewModel>().setVersionByKey(key),
              ),
            ),
          ),
        ],
      ),
      body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: FeatureSearchField(
                hintText: "Pesquisar livro",
                onChanged: (v) => context.read<BibleListViewModel>().setQuery(v),
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
