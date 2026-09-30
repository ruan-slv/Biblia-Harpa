import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../controllers/notes_controller.dart';
import '../model/note.dart';
import 'component/app_bar_component.dart';
import 'component/note_editor_dialog.dart';

/// Tela dedicada (tela cheia) de uma anotação.
///
/// Mostra todos os dados da nota (título, conteúdo completo, referência e
/// datas) para facilitar a leitura. O [NotesController] é recebido por
/// parâmetro porque o provider é escopado à rota da lista de anotações.
class NoteDetailView extends StatelessWidget {
  final NotesController controller;
  final Note note;

  const NoteDetailView({
    super.key,
    required this.controller,
    required this.note,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<NotesController>.value(
      value: controller,
      child: _NoteDetailBody(noteId: note.id),
    );
  }
}

class _NoteDetailBody extends StatelessWidget {
  final int? noteId;

  const _NoteDetailBody({required this.noteId});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final controller = context.watch<NotesController>();

    final note = noteId == null
        ? null
        : controller.notes.where((n) => n.id == noteId).firstOrNull;

    if (note == null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: CustomAppBar(
          title: 'Anotação',
          centerTitle: false,
          automaticallyImplyLeading: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.note_outlined,
                size: 72,
                color: colorScheme.secondary.withValues(alpha: 0.35),
              ),
              const SizedBox(height: 16),
              Text(
                'Anotação não encontrada.',
                style: TextStyle(
                  color: colorScheme.secondary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Ela pode ter sido excluída.',
                style: TextStyle(
                  color: colorScheme.secondary.withValues(alpha: 0.7),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title: note.title.isEmpty ? 'Anotação' : note.title,
        centerTitle: false,
        automaticallyImplyLeading: true,
        actions: [
          IconButton(
            icon: Icon(
              Icons.edit_note,
              color: colorScheme.secondary,
            ),
            tooltip: 'Editar',
            onPressed: () => showNoteEditorDialog(
              context,
              controller: controller,
              note: note,
            ),
          ),
          IconButton(
            icon: Icon(
              Icons.delete_outline,
              color: colorScheme.secondary.withValues(alpha: 0.8),
            ),
            tooltip: 'Excluir',
            onPressed: () => _confirmDelete(context, controller, note),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (note.title.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  note.title,
                  style: TextStyle(
                    color: colorScheme.secondary,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            if (note.reference != null && note.reference!.isNotEmpty)
              Container(
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.menu_book_rounded,
                      size: 18,
                      color: colorScheme.secondary,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      note.reference!,
                      style: TextStyle(
                        color: colorScheme.secondary,
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            if (note.content.isNotEmpty)
              Text(
                note.content,
                style: TextStyle(
                  color: colorScheme.secondary,
                  fontSize: 18,
                  height: 1.7,
                ),
              )
            else
              Text(
                'Sem conteúdo.',
                style: TextStyle(
                  color: colorScheme.secondary.withValues(alpha: 0.6),
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            const Divider(height: 40),
            Row(
              children: [
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: colorScheme.secondary.withValues(alpha: 0.6),
                ),
                const SizedBox(width: 6),
                Text(
                  'Criada em ${note.dateFormatted}',
                  style: TextStyle(
                    color: colorScheme.secondary.withValues(alpha: 0.6),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
            if (note.createdAt != note.updatedAt)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Row(
                  children: [
                    Icon(
                      Icons.update,
                      size: 16,
                      color: colorScheme.secondary.withValues(alpha: 0.6),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Editada em ${note.dateFormatted}',
                      style: TextStyle(
                        color: colorScheme.secondary.withValues(alpha: 0.6),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    NotesController controller,
    Note note,
  ) async {
    final colorScheme = Theme.of(context).colorScheme;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir anotação?'),
        content: Text(
          note.title.isEmpty
              ? 'Esta anotação será excluída.'
              : '"${note.title}" será excluída.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              'Excluir',
              style: TextStyle(color: colorScheme.secondary),
            ),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await controller.deleteNote(note);
      if (context.mounted) {
        Navigator.of(context).pop();
      }
    }
  }
}
