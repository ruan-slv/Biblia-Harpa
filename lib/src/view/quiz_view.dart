import 'package:biblia_e_harpa/src/view/component/app_bar_component.dart';
import 'package:biblia_e_harpa/src/view_model/quiz_view_model.dart';
import 'package:biblia_e_harpa/src/view_model/settings_view_model.dart';
import 'package:biblia_e_harpa/src/model/quiz_hive_model.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class QuizView extends StatelessWidget {
  /// Cria a tela do quiz, podendo retomar a partir de [initialQuestionIndex].
  const QuizView({super.key, this.initialQuestionIndex = 0});

  /// Índice inicial usado ao retomar um quiz salvo.
  final int initialQuestionIndex;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QuizViewModel(initialQuestionIndex: initialQuestionIndex)
        ..loadQuestions(),
      child: const _QuizViewContent(),
    );
  }
}

class _QuizViewContent extends StatelessWidget {
  const _QuizViewContent();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final viewModel = context.watch<QuizViewModel>();

    if (viewModel.loading) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        body: Center(
          child: CircularProgressIndicator(color: colorScheme.secondary),
        ),
      );
    }

    if (viewModel.errorMessage != null) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: const CustomAppBar(
          title: 'Quizz Bíblico',
          centerTitle: false,
          automaticallyImplyLeading: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        height: 64,
                        width: 64,
                        decoration: BoxDecoration(
                          color: colorScheme.surface,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Icon(
                          Icons.error_outline_rounded,
                          color: colorScheme.secondary,
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        viewModel.errorMessage!,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: colorScheme.secondary,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Tente recarregar para buscar as perguntas novamente.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: colorScheme.secondary.withValues(alpha: 0.72),
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 22),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed:
                              context.read<QuizViewModel>().loadQuestions,
                          icon: const Icon(Icons.refresh_rounded),
                          label: const Text('Tentar novamente'),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (viewModel.questions.isEmpty) {
      return Scaffold(
        backgroundColor: colorScheme.surface,
        appBar: const CustomAppBar(
          title: 'Quizz Bíblico',
          centerTitle: false,
          automaticallyImplyLeading: true,
        ),
        body: Center(
          child: Card(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 28),
              child: Text(
                'Nenhuma pergunta disponivel.',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                  color: colorScheme.secondary,
                ),
              ),
            ),
          ),
        ),
      );
    }

    if (viewModel.completed) {
      return _buildCompletedState(context);
    }

    return _buildQuestionState(context);
  }

  Widget _buildCompletedState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final viewModel = context.watch<QuizViewModel>();
    final total = viewModel.questions.length;
    final percent = total == 0 ? 0.0 : viewModel.score / total;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomAppBar(
        title: 'Resultado do Quiz',
        centerTitle: false,
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(22),
                    child: Column(
                      children: [
                        Container(
                          height: 76,
                          width: 76,
                          decoration: BoxDecoration(
                            color: colorScheme.surface,
                            borderRadius: BorderRadius.circular(24),
                          ),
                          child: Icon(
                            Icons.workspace_premium_rounded,
                            color: colorScheme.secondary,
                            size: 38,
                          ),
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Quiz concluído',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Voce acertou ${viewModel.score} de $total perguntas.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 16,
                            color:
                                colorScheme.secondary.withValues(alpha: 0.75),
                            height: 1.45,
                          ),
                        ),
                        const SizedBox(height: 18),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: percent,
                            minHeight: 12,
                            backgroundColor: colorScheme.surface,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.secondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 18),
                        Wrap(
                          spacing: 12,
                          runSpacing: 12,
                          alignment: WrapAlignment.center,
                          children: [
                            _SummaryChip(
                              icon: Icons.check_circle_outline_rounded,
                              label: 'Acertos',
                              value: '${viewModel.score}',
                            ),
                            _SummaryChip(
                              icon: Icons.menu_book_rounded,
                              label: 'Perguntas',
                              value: '$total',
                            ),
                            _SummaryChip(
                              icon: Icons.percent_rounded,
                              label: 'Desempenho',
                              value: '${(percent * 100).round()}%',
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 44,
                              width: 44,
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Icon(
                                Icons.fact_check_outlined,
                                color: colorScheme.secondary,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Resumo das perguntas',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.secondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        ...List.generate(viewModel.questions.length, (index) {
                          final question = viewModel.questions[index];
                          return Container(
                            margin: EdgeInsets.only(
                              bottom: index == viewModel.questions.length - 1
                                  ? 0
                                  : 12,
                            ),
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: colorScheme.secondary
                                    .withValues(alpha: 0.08),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Pergunta ${index + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.secondary
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  question.question,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.secondary,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Referência: ${question.reference}',
                                  style: TextStyle(
                                    color: colorScheme.secondary
                                        .withValues(alpha: 0.74),
                                    height: 1.35,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: context.read<QuizViewModel>().loadQuestions,
                  icon: const Icon(Icons.replay_rounded),
                  label: const Text('Reiniciar quiz'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionState(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final viewModel = context.watch<QuizViewModel>();
    final settings = context.watch<SettingsViewModel>();
    final question = viewModel.questions[viewModel.current];
    final progress = (viewModel.current + 1) / viewModel.questions.length;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: CustomAppBar(
        title:
            'Quizz Bíblico ${viewModel.current + 1}/${viewModel.questions.length}',
        centerTitle: false,
        automaticallyImplyLeading: true,
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 920),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
              children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.surface,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Pergunta ${viewModel.current + 1}',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: colorScheme.secondary,
                                ),
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '${viewModel.score} acertos',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                                color: colorScheme.secondary
                                    .withValues(alpha: 0.72),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 16),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(999),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 10,
                            backgroundColor: colorScheme.surface,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              colorScheme.secondary,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          question.question,
                          style: TextStyle(
                            fontSize: settings.fontSize + 7,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.secondary,
                            height: 1.35,
                          ),
                        ),
                        if (viewModel.selected != null) ...[
                          const SizedBox(height: 18),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: colorScheme.surface,
                              borderRadius: BorderRadius.circular(18),
                              border: Border.all(
                                color: colorScheme.secondary
                                    .withValues(alpha: 0.08),
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Referência bíblica',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: colorScheme.secondary
                                        .withValues(alpha: 0.6),
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  question.reference,
                                  style: TextStyle(
                                    fontSize: settings.fontSize,
                                    color: colorScheme.secondary,
                                    height: 1.4,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                ...List.generate(question.options.length, (index) {
                  return Padding(
                    padding: EdgeInsets.only(
                      bottom: index == question.options.length - 1 ? 0 : 12,
                    ),
                    child: _AnswerOptionCard(
                      optionId: question.options[index].id,
                      optionText: question.options[index].text,
                      fontSize: settings.fontSize,
                      state: _resolveAnswerState(viewModel, question, index),
                      onTap: () => context.read<QuizViewModel>().answer(index),
                    ),
                  );
                }),
                if (viewModel.selected != null) ...[
                  const SizedBox(height: 20),
                  ElevatedButton.icon(
                    onPressed: context.read<QuizViewModel>().next,
                    icon: Icon(
                      viewModel.current == viewModel.questions.length - 1
                          ? Icons.emoji_events_outlined
                          : Icons.arrow_forward_rounded,
                    ),
                    label: Text(
                      viewModel.current == viewModel.questions.length - 1
                          ? 'Ver resultado'
                          : 'Próxima pergunta',
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  _AnswerState _resolveAnswerState(
    QuizViewModel viewModel,
    QuizQuestionHive question,
    int index,
  ) {
    if (viewModel.selected == null) return _AnswerState.idle;

    if (question.options[index].id == question.answer) {
      return _AnswerState.correct;
    }

    if (viewModel.selected == index) {
      return _AnswerState.wrong;
    }

    return _AnswerState.disabled;
  }
}

enum _AnswerState {
  idle,
  correct,
  wrong,
  disabled,
}

class _SummaryChip extends StatelessWidget {
  const _SummaryChip({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.secondary.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: colorScheme.secondary),
          const SizedBox(width: 8),
          Text(
            '$label: $value',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              color: colorScheme.secondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _AnswerOptionCard extends StatelessWidget {
  const _AnswerOptionCard({
    required this.optionId,
    required this.optionText,
    required this.fontSize,
    required this.state,
    required this.onTap,
  });

  final String optionId;
  final String optionText;
  final double fontSize;
  final _AnswerState state;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final optionStyle = _styleForState(colorScheme);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(24),
        onTap: state == _AnswerState.idle ? onTap : null,
        child: Ink(
          decoration: BoxDecoration(
            color: optionStyle.backgroundColor,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: optionStyle.borderColor,
              width: optionStyle.borderWidth,
            ),
            boxShadow: [
              BoxShadow(
                color: optionStyle.shadowColor,
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: 42,
                  width: 42,
                  decoration: BoxDecoration(
                    color: optionStyle.badgeColor,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Center(
                    child: _buildLeadingIcon(optionStyle.foregroundColor),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Text(
                      '$optionId. $optionText',
                      style: TextStyle(
                        fontSize: fontSize,
                        fontWeight: FontWeight.w600,
                        color: optionStyle.foregroundColor,
                        height: 1.4,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLeadingIcon(Color color) {
    switch (state) {
      case _AnswerState.correct:
        return const Icon(Icons.check_rounded, color: Colors.white);
      case _AnswerState.wrong:
        return const Icon(Icons.close_rounded, color: Colors.white);
      case _AnswerState.disabled:
      case _AnswerState.idle:
        return Text(
          optionId,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w800,
          ),
        );
    }
  }

  _OptionStyle _styleForState(ColorScheme colorScheme) {
    switch (state) {
      case _AnswerState.correct:
        return _OptionStyle(
          backgroundColor: Colors.green.withValues(alpha: 0.16),
          borderColor: Colors.green.withValues(alpha: 0.42),
          badgeColor: Colors.green,
          foregroundColor: colorScheme.secondary,
          shadowColor: Colors.green.withValues(alpha: 0.08),
          borderWidth: 1.4,
        );
      case _AnswerState.wrong:
        return _OptionStyle(
          backgroundColor: Colors.red.withValues(alpha: 0.12),
          borderColor: Colors.red.withValues(alpha: 0.32),
          badgeColor: Colors.red,
          foregroundColor: colorScheme.secondary,
          shadowColor: Colors.red.withValues(alpha: 0.05),
          borderWidth: 1.2,
        );
      case _AnswerState.disabled:
        return _OptionStyle(
          backgroundColor: colorScheme.primary.withValues(alpha: 0.45),
          borderColor: colorScheme.secondary.withValues(alpha: 0.06),
          badgeColor: colorScheme.surface,
          foregroundColor: colorScheme.secondary.withValues(alpha: 0.52),
          shadowColor: Colors.transparent,
          borderWidth: 1,
        );
      case _AnswerState.idle:
        return _OptionStyle(
          backgroundColor: colorScheme.primary,
          borderColor: colorScheme.secondary.withValues(alpha: 0.08),
          badgeColor: colorScheme.surface,
          foregroundColor: colorScheme.secondary,
          shadowColor: colorScheme.secondary.withValues(alpha: 0.06),
          borderWidth: 1,
        );
    }
  }
}

class _OptionStyle {
  const _OptionStyle({
    required this.backgroundColor,
    required this.borderColor,
    required this.badgeColor,
    required this.foregroundColor,
    required this.shadowColor,
    required this.borderWidth,
  });

  final Color backgroundColor;
  final Color borderColor;
  final Color badgeColor;
  final Color foregroundColor;
  final Color shadowColor;
  final double borderWidth;
}
