import 'package:biblia_e_harpa/src/view/component/app_bar_component.dart';
import 'package:biblia_e_harpa/src/view_model/settings_view_model.dart';
import 'package:biblia_e_harpa/src/view_model/bible_audios_view_model.dart';
import 'package:biblia_e_harpa/src/view/component/feature_search_field.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'bible_audio_chapters_view.dart';

class BibleAudioListView extends StatefulWidget {
  final bool isOffline;

  const BibleAudioListView({super.key, this.isOffline = false});

  @override
  State<BibleAudioListView> createState() => _BibleAudioListViewState();
}

class _BibleAudioListViewState extends State<BibleAudioListView> {
  bool _loaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_loaded) return;
    _loaded = true;
    Future.microtask(() {
      if (mounted) {
        context.read<BibleAudiosViewModel>().load(offlineOnly: widget.isOffline);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<BibleAudiosViewModel>();

    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: widget.isOffline
          ? CustomAppBar(
              automaticallyImplyLeading: true,
              centerTitle: false,
              title: "Áudios Baixados (Offline)",
            )
          : null,
      body: _Content(viewModel: viewModel),
    );
  }
}

class _Content extends StatelessWidget {
  final BibleAudiosViewModel viewModel;

  const _Content({required this.viewModel});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsViewModel>();
    if (viewModel.loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (viewModel.error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Text(
            viewModel.error!,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Theme.of(context).colorScheme.secondary,
              fontSize: settings.fontSize,
            ),
          ),
        ),
      );
    }

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: FeatureSearchField(
            hintText: "Pesquisar livro",
            onChanged: (v) => context.read<BibleAudiosViewModel>().setQuery(v),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: viewModel.filteredBooks.length,
            itemBuilder: (context, index) {
              final book = viewModel.filteredBooks[index];
              return ListTile(
                trailing: Icon(
                  Icons.list,
                  color: Theme.of(context).colorScheme.secondary,
                ),
                title: Text(
                  book.title,
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.secondary,
                    fontSize: settings.fontSize,
                  ),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => BibleAudioChaptersView(book: book),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
