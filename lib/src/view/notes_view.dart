import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/notes_controller.dart';
import '../l10n/app_localizations.dart';
import '../model/note.dart';
import 'component/app_bar_component.dart';
import 'component/note_editor_dialog.dart';
import 'note_detail_view.dart';

class NotesView extends StatefulWidget {
  const NotesView({super.key});

  @override
  State<NotesView> createState() => _NotesViewState();
}

class _NotesViewState extends State<NotesView> {
  final NotesController _controller = NotesController();

  @override
  void initState() {
    super.initState();
    _controller.loadNotes();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: CustomAppBar(
          title: context.l10n.t('Anotações'),
          centerTitle: false,
          automaticallyImplyLeading: true,
        ),
        body: const _NotesBody(),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () => showNoteEditorDialog(
            context,
            controller: _controller,
          ),
          icon: const Icon(Icons.note_add_outlined),
          label: Text(context.l10n.t('Nova anotação')),
        ),
      ),
    );
  }
}

class _NotesBody extends StatelessWidget {
  const _NotesBody();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = context.watch<NotesController>();

    if (controller.loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (controller.notes.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.notes_rounded,
                size: 72,
                color: colorScheme.onSurface.withValues(alpha: 0.35),
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.t('Nenhuma anotação ainda'),
                style: TextStyle(
                  color: colorScheme.onSurface,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                context.l10n.t('Toque em "Nova anotação" para começar.'),
                style: TextStyle(
                  color: colorScheme.onSurface.withValues(alpha: 0.7),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: controller.notes.length,
      itemBuilder: (context, index) {
        final note = controller.notes[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(
              color: colorScheme.onSurface.withValues(alpha: 0.1),
            ),
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => NoteDetailView(
                  controller: controller,
                  note: note,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          note.title.isEmpty
                              ? context.l10n.t('Sem título')
                              : note.title,
                          style: TextStyle(
                            color: colorScheme.onSurface,
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: Icon(
                          Icons.delete_outline,
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                        tooltip: context.l10n.t('Excluir'),
                        onPressed: () => _confirmDelete(context, note),
                      ),
                    ],
                  ),
                  if (note.content.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        note.content,
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.85),
                          fontSize: 15,
                          height: 1.4,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  if (note.reference != null && note.reference!.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        '📖 ${note.reference}',
                        style: TextStyle(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 13,
                        ),
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.only(top: 10),
                    child: Text(
                      note.dateFormatted,
                      style: TextStyle(
                        color: colorScheme.onSurface.withValues(alpha: 0.5),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, Note note) async {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = context.read<NotesController>();
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(context.l10n.t('Excluir anotação?')),
        content: Text(
          note.title.isEmpty
              ? context.l10n.t('Esta anotação será excluída.')
              : context.l10n.t(
                  '"{title}" será excluída.',
                  {'title': note.title},
                ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(context.l10n.t('Cancelar')),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              context.l10n.t('Excluir'),
              style: TextStyle(color: colorScheme.onSurface),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.deleteNote(note);
    }
  }
}
