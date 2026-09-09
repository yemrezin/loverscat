import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../quiz/domain/models/question.dart';
import '../../quiz/presentation/controllers/quiz_providers.dart';
import '../../quiz/presentation/screens/quiz_play_screen.dart';

/// Interactive modal sheet allowing users to view, select custom/default questions,
/// and launch a customized quiz game consisting ONLY of selected questions.
class CustomQuestionsSheet extends ConsumerStatefulWidget {
  const CustomQuestionsSheet({super.key});

  @override
  ConsumerState<CustomQuestionsSheet> createState() => _CustomQuestionsSheetState();
}

class _CustomQuestionsSheetState extends ConsumerState<CustomQuestionsSheet> {
  final Set<String> _selectedQuestionIds = {};
  bool _showAllQuestions = false; // false = custom only, true = all questions

  void _toggleSelection(String questionId) {
    HapticUtils.light();
    setState(() {
      if (_selectedQuestionIds.contains(questionId)) {
        _selectedQuestionIds.remove(questionId);
      } else {
        _selectedQuestionIds.add(questionId);
      }
    });
  }

  void _selectAll(List<QuizQuestion> questions) {
    HapticUtils.light();
    setState(() {
      _selectedQuestionIds.addAll(questions.map((q) => q.id));
    });
  }

  void _clearSelection() {
    HapticUtils.light();
    setState(() {
      _selectedQuestionIds.clear();
    });
  }

  void _startSelectedGame(List<QuizQuestion> allAvailable) {
    if (_selectedQuestionIds.isEmpty) return;

    final selectedQuestions = allAvailable
        .where((q) => _selectedQuestionIds.contains(q.id))
        .toList();

    if (selectedQuestions.isEmpty) return;

    HapticUtils.medium();
    ref.read(quizGameProvider.notifier).startCustomGame(selectedQuestions);

    // Close bottom sheet
    Navigator.of(context).pop();

    // Launch game screen
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const QuizPlayScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final questionsAsync = ref.watch(allQuestionsProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.82,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: const BoxDecoration(
        color: AppColors.backgroundWarm,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Drag handle
          Center(
            child: Container(
              width: 44,
              height: 5,
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withOpacity(0.3),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
          const SizedBox(height: 14),

          // Header Title
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              Text('📚', style: TextStyle(fontSize: 22)),
              SizedBox(width: 8),
              Text(
                'Kaydedilen Sorular & Seçim',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Filter Segment: Özel Eklenenler vs Tüm Sorular
          Row(
            children: [
              Expanded(
                child: _buildFilterChip(
                  label: 'Özel Eklenenler',
                  isSelected: !_showAllQuestions,
                  onTap: () => setState(() => _showAllQuestions = false),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildFilterChip(
                  label: 'Tüm Sorular (Varsayılan + Özel)',
                  isSelected: _showAllQuestions,
                  onTap: () => setState(() => _showAllQuestions = true),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          // Questions List
          Expanded(
            child: questionsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(color: AppColors.player1Badge),
              ),
              error: (err, _) => Center(
                child: Text('Hata: $err', textAlign: TextAlign.center),
              ),
              data: (allQuestions) {
                final displayList = _showAllQuestions
                    ? allQuestions
                    : allQuestions.where((q) => q.isCustom).toList();

                if (displayList.isEmpty) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('📝', style: TextStyle(fontSize: 44)),
                          const SizedBox(height: 12),
                          const Text(
                            AppStrings.noCustomQuestions,
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          TextButton(
                            onPressed: () => setState(() => _showAllQuestions = true),
                            child: const Text('Varsayılan Soruları Göster ✨'),
                          ),
                        ],
                      ),
                    ),
                  );
                }

                return Column(
                  children: [
                    // Selection action bar
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${_selectedQuestionIds.length} / ${displayList.length} Seçildi',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                            color: AppColors.player1Badge,
                          ),
                        ),
                        Row(
                          children: [
                            TextButton(
                              onPressed: () => _selectAll(displayList),
                              child: const Text('Hepsini Seç', style: TextStyle(fontSize: 12)),
                            ),
                            TextButton(
                              onPressed: _clearSelection,
                              child: const Text('Temizle', style: TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),

                    // Scrollable List
                    Expanded(
                      child: ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        itemCount: displayList.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (context, index) {
                          final item = displayList[index];
                          final isSelected = _selectedQuestionIds.contains(item.id);

                          return InkWell(
                            onTap: () => _toggleSelection(item.id),
                            borderRadius: BorderRadius.circular(18),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.pastelPink.withOpacity(0.35) : Colors.white,
                                borderRadius: BorderRadius.circular(18),
                                border: Border.all(
                                  color: isSelected ? AppColors.player1Badge : AppColors.borderSubtle,
                                  width: isSelected ? 2.0 : 1.0,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Checkbox icon
                                  Icon(
                                    isSelected
                                        ? Icons.check_box_rounded
                                        : Icons.check_box_outline_blank_rounded,
                                    color: isSelected ? AppColors.player1Badge : AppColors.textSecondary,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),

                                  // Question Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          item.text,
                                          style: TextStyle(
                                            fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                                            color: AppColors.textPrimary,
                                            fontSize: 14,
                                            height: 1.25,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: item.isCustom
                                                    ? AppColors.pastelMint
                                                    : AppColors.pastelLavender,
                                                borderRadius: BorderRadius.circular(8),
                                              ),
                                              child: Text(
                                                item.isCustom ? 'Özel Soru' : 'Varsayılan',
                                                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                                              ),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(
                                              item.isMultipleChoice ? '4 Şıklı' : 'Açık Uçlu',
                                              style: const TextStyle(
                                                color: AppColors.textSecondary,
                                                fontSize: 11,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),

                                  // Delete button for custom questions
                                  if (item.isCustom)
                                    IconButton(
                                      icon: const Icon(Icons.delete_outline_rounded, color: AppColors.angryRed, size: 20),
                                      onPressed: () async {
                                        HapticUtils.light();
                                        final repo = ref.read(quizRepositoryProvider);
                                        await repo.deleteCustomQuestion(item.id);
                                        setState(() {
                                          _selectedQuestionIds.remove(item.id);
                                        });
                                        ref.invalidate(allQuestionsProvider);
                                        ref.read(quizGameProvider.notifier).loadGame();
                                      },
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          const SizedBox(height: 14),

          // Bottom Action Button: "Seçilen Sorularla Oyuna Başla"
          questionsAsync.maybeWhen(
            data: (allQuestions) {
              final count = _selectedQuestionIds.length;
              final isEnabled = count > 0;

              return ElevatedButton.icon(
                onPressed: isEnabled ? () => _startSelectedGame(allQuestions) : null,
                icon: const Text('🎮', style: TextStyle(fontSize: 18)),
                label: Text(
                  isEnabled
                      ? 'Seçilen Sorularla Oyuna Başla ($count Soru)'
                      : 'Lütfen En Az 1 Soru Seçin',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.player1Badge,
                  disabledBackgroundColor: AppColors.player1Badge.withOpacity(0.3),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            },
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticUtils.light();
        onTap();
      },
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.player1Badge : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.player1Badge : AppColors.borderSubtle,
          ),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: isSelected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }
}
