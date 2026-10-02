import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../domain/models/question.dart';
import '../controllers/quiz_providers.dart';
import '../../../online/controllers/online_controller.dart';

/// Screen allowing users to create their own couple quiz questions
/// (Multiple-choice 4 options or Open-ended short text).
class QuizBuilderScreen extends ConsumerStatefulWidget {
  const QuizBuilderScreen({super.key});

  @override
  ConsumerState<QuizBuilderScreen> createState() => _QuizBuilderScreenState();
}

class _QuizBuilderScreenState extends ConsumerState<QuizBuilderScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  QuestionType _selectedType = QuestionType.multipleChoice;
  bool _isSaving = false;

  @override
  void dispose() {
    _questionController.dispose();
    for (final c in _optionControllers) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _saveQuestion() async {
    final questionText = _questionController.text.trim();
    if (questionText.isEmpty) {
      _showToast(AppStrings.emptyQuestionError);
      return;
    }

    List<String> options = [];
    if (_selectedType == QuestionType.multipleChoice) {
      options = _optionControllers.map((c) => c.text.trim()).toList();
      if (options.any((opt) => opt.isEmpty)) {
        _showToast(AppStrings.emptyOptionsError);
        return;
      }
    }

    setState(() => _isSaving = true);
    HapticUtils.medium();

    try {
      final online = ref.read(onlineProvider);

      if (online.isLoggedIn) {
        final currentQuestions = await ref.read(onlineProvider.notifier).fetchCustomQuestions(online.user.username);
        if (currentQuestions.length >= 5) {
          _showToast('Her kullanıcı en fazla 5 soru ekleyebilir!');
          setState(() => _isSaving = false);
          return;
        }

        final success = await ref.read(onlineProvider.notifier).createCustomQuestion(questionText, options);
        if (!success) {
          _showToast(ref.read(onlineProvider).lastError ?? 'Soru kaydedilemedi.');
          setState(() => _isSaving = false);
          return;
        }
      }

      final newQuestion = QuizQuestion(
        id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
        text: questionText,
        type: _selectedType,
        options: options,
        isCustom: true,
        author: online.user.username,
      );

      final repo = ref.read(quizRepositoryProvider);
      await repo.saveCustomQuestion(newQuestion);

      // Refresh providers
      ref.invalidate(allQuestionsProvider);
      ref.read(quizGameProvider.notifier).loadGame();

      if (mounted) {
        _showToast(AppStrings.questionSavedSuccess);
        _questionController.clear();
        for (final c in _optionControllers) {
          c.clear();
        }
      }
    } catch (e) {
      if (mounted) {
        _showToast('Kaydedilirken hata oluştu: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }

  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(fontWeight: FontWeight.w600, color: Colors.white),
        ),
        backgroundColor: AppColors.textPrimary,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          AppStrings.builderTitle,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top explanatory banner
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.pastelMint.withOpacity(0.4),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: AppColors.pastelMint, width: 1.5),
                  ),
                  child: const Row(
                    children: [
                      Text('✍️', style: TextStyle(fontSize: 28)),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Kendi ilişkinize özel sorular ekleyerek oyunu daha da eğlenceli ve samimi hale getirin!',
                          style: TextStyle(
                            fontSize: 13,
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Question Type Selector
                const Text(
                  AppStrings.questionTypeLabel,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Expanded(
                      child: _buildTypeOption(
                        label: 'Çoktan Seçmeli',
                        icon: Icons.list_rounded,
                        isSelected: _selectedType == QuestionType.multipleChoice,
                        onTap: () {
                          setState(() => _selectedType = QuestionType.multipleChoice);
                        },
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildTypeOption(
                        label: 'Açık Uçlu',
                        icon: Icons.edit_note_rounded,
                        isSelected: _selectedType == QuestionType.openEnded,
                        onTap: () {
                          setState(() => _selectedType = QuestionType.openEnded);
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                // Question Text Field
                const Text(
                  'Soru Metni',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                TextFormField(
                  controller: _questionController,
                  maxLines: 3,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 15),
                  decoration: const InputDecoration(
                    hintText: AppStrings.questionInputHint,
                  ),
                ),
                const SizedBox(height: 20),

                // Multiple Choice Options Inputs
                if (_selectedType == QuestionType.multipleChoice) ...[
                  const Text(
                    'Seçenekler (4 Şık)',
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(4, (index) {
                    final letters = ['A', 'B', 'C', 'D'];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10.0),
                      child: TextFormField(
                        controller: _optionControllers[index],
                        style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                        decoration: InputDecoration(
                          prefixIcon: Container(
                            width: 32,
                            height: 32,
                            margin: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.pastelPink.withOpacity(0.5),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                letters[index],
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.player1Badge,
                                ),
                              ),
                            ),
                          ),
                          hintText: '${letters[index]} Şıkkını girin...',
                        ),
                      ),
                    );
                  }),
                  const SizedBox(height: 12),
                ],

                // Save Question Button
                ElevatedButton(
                  onPressed: _isSaving ? null : _saveQuestion,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.player1Badge,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: _isSaving
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                          ),
                        )
                      : const Text(
                          AppStrings.saveQuestionButton,
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                ),
                const SizedBox(height: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTypeOption({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: () {
        HapticUtils.light();
        onTap();
      },
      borderRadius: BorderRadius.circular(20),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.player1Badge.withOpacity(0.15) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.player1Badge : AppColors.borderSubtle,
            width: isSelected ? 2.0 : 1.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 20,
              color: isSelected ? AppColors.player1Badge : AppColors.textSecondary,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.player1Badge : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
