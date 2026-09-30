import 'package:flutter/material.dart';

import '../../controllers/notes_controller.dart';
import '../../model/note.dart';

/// Diálogo de criação/edição de anotação.
///
/// Recebe a instância do [NotesController] diretamente (parâmetro), pois
/// diálogos abertos via [showDialog] ficam fora do escopo de rota do Provider.
class NoteEditorDialog extends StatefulWidget {
  final NotesController controller;
  final Note? note;

  const NoteEditorDialog({
    super.key,
    required this.controller,
    this.note,
  });

  @override
  State<NoteEditorDialog> createState() => _NoteEditorDialogState();
}

Future<bool?> showNoteEditorDialog(
  BuildContext context, {
  required NotesController controller,
  Note? note,
}) {
  return showDialog<bool>(
    context: context,
    builder: (dialogContext) => NoteEditorDialog(
      controller: controller,
      note: note,
    ),
  );
}

class _NoteEditorDialogState extends State<NoteEditorDialog> {
  late final TextEditingController _titleController;
  late final TextEditingController _contentController;
  late final TextEditingController _referenceController;

  @override
  void initState() {
    super.initState();
    final note = widget.note;
    _titleController = TextEditingController(text: note?.title ?? '');
    _contentController = TextEditingController(text: note?.content ?? '');
    _referenceController = TextEditingController(text: note?.reference ?? '');
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _referenceController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    final reference = _referenceController.text.trim();

    if (title.isEmpty && content.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Digite um título ou conteúdo.')),
      );
      return;
    }

    final controller = widget.controller;

    if (widget.note == null) {
      await controller.addNote(
        title: title,
        content: content,
        reference: reference.isEmpty ? null : reference,
      );
    } else {
      await controller.updateNote(
        widget.note!.copyWith(
          title: title,
          content: content,
          reference: reference.isEmpty ? null : reference,
        ),
      );
    }
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isEditing = widget.note != null;

    return AlertDialog(
      backgroundColor: colorScheme.surface,
      title: Text(
        isEditing ? 'Editar anotação' : 'Nova anotação',
        style: TextStyle(color: colorScheme.secondary, fontSize: 18),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _titleController,
              decoration: InputDecoration(
                hintText: 'Título',
                hintStyle: TextStyle(
                  color: colorScheme.secondary.withValues(alpha: 0.6),
                ),
              ),
              style: TextStyle(color: colorScheme.secondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: InputDecoration(
                hintText: 'Escreva sua anotação...',
                hintStyle: TextStyle(
                  color: colorScheme.secondary.withValues(alpha: 0.6),
                ),
              ),
              style: TextStyle(color: colorScheme.secondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _referenceController,
              decoration: InputDecoration(
                hintText: 'Referência (ex.: João 3:16)',
                hintStyle: TextStyle(
                  color: colorScheme.secondary.withValues(alpha: 0.6),
                ),
              ),
              style: TextStyle(color: colorScheme.secondary),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Cancelar'),
        ),
        TextButton(
          onPressed: _save,
          child: Text(
            'Salvar',
            style: TextStyle(color: colorScheme.secondary),
          ),
        ),
      ],
    );
  }
}
