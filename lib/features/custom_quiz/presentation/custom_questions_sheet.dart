import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../quiz/domain/models/question.dart';
import '../../quiz/presentation/controllers/quiz_providers.dart';
import '../../online/controllers/online_controller.dart';

/// "Özel Sorularınız" Screen / Modal Sheet
/// Allows couples to:
/// 1. Add up to 5 custom questions (Multiple Choice or Open-Ended text).
/// 2. View partner's added questions.
/// 3. Manage and delete questions.
class CustomQuestionsSheet extends ConsumerStatefulWidget {
  const CustomQuestionsSheet({super.key});

  @override
  ConsumerState<CustomQuestionsSheet> createState() => _CustomQuestionsSheetState();
}

class _CustomQuestionsSheetState extends ConsumerState<CustomQuestionsSheet> {
  bool _isLoading = true;
  List<QuizQuestion> _myQuestions = [];
  List<QuizQuestion> _partnerQuestions = [];

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  Future<void> _loadQuestions() async {
    setState(() => _isLoading = true);
    final online = ref.read(onlineProvider);
    final onlineCtrl = ref.read(onlineProvider.notifier);

    try {
      if (online.isLoggedIn) {
        final myQ = await onlineCtrl.fetchCustomQuestions(online.user.username);
        List<QuizQuestion> partnerQ = [];
        if (online.partner != null) {
          partnerQ = await onlineCtrl.fetchCustomQuestions(online.partner!.username);
        }

        if (mounted) {
          setState(() {
            _myQuestions = myQ;
            _partnerQuestions = partnerQ;
            _isLoading = false;
          });
        }
      } else {
        final repo = ref.read(quizRepositoryProvider);
        final all = await repo.getQuestions();
        final myQ = all.where((q) => q.isCustom).toList();

        if (mounted) {
          setState(() {
            _myQuestions = myQ;
            _partnerQuestions = [];
            _isLoading = false;
          });
        }
      }
    } catch (_) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showAddQuestionDialog() {
    if (_myQuestions.length >= 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Her kullanıcı en fazla 5 soru ekleyebilir!'),
          backgroundColor: AppColors.angryRed,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    final questionCtrl = TextEditingController();
    final optionCtrls = List.generate(4, (_) => TextEditingController());
    final formKey = GlobalKey<FormState>();
    QuestionType selectedType = QuestionType.openEnded; // Default to openEnded as user requested

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Container(
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
          ),
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('✍️', style: TextStyle(fontSize: 22)),
                      SizedBox(width: 8),
                      Text(
                        'Yeni Soru Ekle',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Question Type Selector
                  Container(
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: AppColors.backgroundWarm,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              HapticUtils.light();
                              setDialogState(() {
                                selectedType = QuestionType.openEnded;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selectedType == QuestionType.openEnded
                                    ? AppColors.player2Badge
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  '📝 Açık Uçlu (Metin)',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: selectedType == QuestionType.openEnded
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: InkWell(
                            onTap: () {
                              HapticUtils.light();
                              setDialogState(() {
                                selectedType = QuestionType.multipleChoice;
                              });
                            },
                            borderRadius: BorderRadius.circular(12),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 180),
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              decoration: BoxDecoration(
                                color: selectedType == QuestionType.multipleChoice
                                    ? AppColors.player1Badge
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Center(
                                child: Text(
                                  '🔤 4 Şıklı Test',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: selectedType == QuestionType.multipleChoice
                                        ? Colors.white
                                        : AppColors.textSecondary,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Info message based on type
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: selectedType == QuestionType.openEnded
                          ? AppColors.pastelMint.withOpacity(0.4)
                          : AppColors.pastelLavender.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                        color: selectedType == QuestionType.openEnded
                            ? AppColors.player2Badge.withOpacity(0.3)
                            : AppColors.player1Badge.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      selectedType == QuestionType.openEnded
                          ? '💬 Açık Uçlu Soru: Oyuncular kendi metin yanıtlarını yazacak ve partnerin tahminini kendisi değerlendirecektir (Doğru / Yanlış kararı sana ait!).'
                          : '💡 Çoktan Seçmeli: Cevaplar oyun sırasında siz ve partneriniz tarafından canlı seçilir.',
                      style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.3),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Question Text
                  TextFormField(
                    controller: questionCtrl,
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Soru Metni',
                      hintText: selectedType == QuestionType.openEnded
                          ? 'Örn: Birlikte gitmek istediğimiz en çılgın tatil yeri neresi?'
                          : 'Örn: Pazar sabahı ilk ne yapmak isterdin?',
                      filled: true,
                      fillColor: AppColors.backgroundWarm,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(16),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Lütfen bir soru metni girin.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Option Fields if Multiple Choice
                  if (selectedType == QuestionType.multipleChoice) ...[
                    const Text(
                      'Şıklar (4 Seçenek):',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                    ),
                    const SizedBox(height: 8),

                    for (int i = 0; i < 4; i++) ...[
                      TextFormField(
                        controller: optionCtrls[i],
                        decoration: InputDecoration(
                          prefixIcon: Padding(
                            padding: const EdgeInsets.all(12),
                            child: Text(
                              String.fromCharCode(65 + i), // A, B, C, D
                              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.player1Badge),
                            ),
                          ),
                          hintText: '${i + 1}. Seçenek',
                          filled: true,
                          fillColor: AppColors.backgroundWarm,
                          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(14),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        validator: (val) {
                          if (val == null || val.trim().isEmpty) {
                            return 'Tüm şıkları doldurmalısınız.';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 8),
                    ],
                  ],
                  const SizedBox(height: 12),

                  ElevatedButton(
                    onPressed: () async {
                      if (!formKey.currentState!.validate()) return;
                      final text = questionCtrl.text.trim();
                      final options = selectedType == QuestionType.multipleChoice
                          ? optionCtrls.map((c) => c.text.trim()).toList()
                          : <String>[];

                      Navigator.of(ctx).pop();
                      HapticUtils.medium();

                      final online = ref.read(onlineProvider);
                      if (online.isLoggedIn) {
                        await ref.read(onlineProvider.notifier).createCustomQuestion(
                          text,
                          options,
                          type: selectedType,
                        );
                      } else {
                        final newQ = QuizQuestion(
                          id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
                          text: text,
                          type: selectedType,
                          options: options,
                          isCustom: true,
                          author: online.user.username,
                        );
                        await ref.read(quizRepositoryProvider).saveCustomQuestion(newQ);
                      }

                      await _loadQuestions();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedType == QuestionType.openEnded
                          ? AppColors.player2Badge
                          : AppColors.player1Badge,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: const Text('Soruyu Kaydet 🐾', style: TextStyle(fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _deleteQuestion(String id) async {
    HapticUtils.light();
    final online = ref.read(onlineProvider);
    if (online.isLoggedIn) {
      await ref.read(onlineProvider.notifier).deleteCustomQuestion(id);
    } else {
      await ref.read(quizRepositoryProvider).deleteCustomQuestion(id);
    }
    await _loadQuestions();
  }

  @override
  Widget build(BuildContext context) {
    final online = ref.watch(onlineProvider);

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.88,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: const BoxDecoration(
        color: AppColors.backgroundWarm,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Column(
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
          const SizedBox(height: 12),

          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Row(
                children: [
                  Text('📝', style: TextStyle(fontSize: 24)),
                  SizedBox(width: 8),
                  Text(
                    'Özel Sorularınız',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ],
              ),
              IconButton(
                icon: const Icon(Icons.refresh_rounded, color: AppColors.textSecondary),
                onPressed: _loadQuestions,
                tooltip: 'Yenile',
              ),
            ],
          ),
          const SizedBox(height: 6),

          // Info Banner
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.pastelYellow.withOpacity(0.6),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFFFFE066), width: 1.5),
            ),
            child: const Text(
              '🎯 Her test 10 sorudur. Sen ve partnerin en fazla 5\'er soru ekleyebilirsiniz (Açık Uçlu veya Test). İstemeyen soru eklemezse kalan sorular oyun tarafından sorulur!',
              style: TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.3),
            ),
          ),
          const SizedBox(height: 12),

          // Questions List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.player1Badge))
                : _buildManagementList(online),
          ),

          // Bottom Action: Add Question or Close
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _myQuestions.length < 5 ? _showAddQuestionDialog : null,
                  icon: const Icon(Icons.add_circle_outline_rounded, size: 20),
                  label: Text(
                    _myQuestions.length < 5 ? 'Yeni Soru Ekle (${_myQuestions.length}/5)' : 'Soru Limiti Doldu (5/5)',
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.player1Badge,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              OutlinedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
                  side: const BorderSide(color: AppColors.borderSubtle),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                ),
                child: const Text('Kapat', style: TextStyle(fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildManagementList(OnlineState online) {
    return ListView(
      physics: const BouncingScrollPhysics(),
      children: [
        // Section 1: My Questions
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Senin Soruların (${_myQuestions.length} / 5)',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: _myQuestions.length < 5
                    ? AppColors.player1Badge.withOpacity(0.15)
                    : AppColors.angryRed.withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                _myQuestions.length < 5 ? '${5 - _myQuestions.length} hak kaldı' : 'Limit Doldu',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: _myQuestions.length < 5 ? AppColors.player1Badge : AppColors.angryRed,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),

        if (_myQuestions.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Column(
              children: [
                const Text('📝 Henüz soru eklemedin.', style: TextStyle(color: AppColors.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: _showAddQuestionDialog,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pastelMint,
                    foregroundColor: AppColors.textPrimary,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('+ Açık Uçlu veya Şıklı Soru Ekle'),
                ),
              ],
            ),
          )
        else
          for (final q in _myQuestions) ...[
            _buildQuestionCard(
              q: q,
              accentColor: AppColors.player1Badge,
              onDelete: () => _deleteQuestion(q.id),
            ),
          ],

        const Divider(height: 28),

        // Section 2: Partner's Questions
        Text(
          online.partner != null
              ? '${online.partner!.formattedUsername} Eklediği Sorular (${_partnerQuestions.length} / 5)'
              : 'Partnerinin Eklediği Sorular',
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),

        if (online.partner == null)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: const Text(
              '🤝 Bir partner ile eşleştiğinizde, partnerinizin eklediği en fazla 5 soru otomatik olarak bu teste dahil edilecektir.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          )
        else if (_partnerQuestions.isEmpty)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.borderSubtle),
            ),
            child: Text(
              '💌 @${online.partner!.username} henüz soru eklemedi. Kalan eksikler oyun tarafından tamamlanır.',
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
              textAlign: TextAlign.center,
            ),
          )
        else
          for (final q in _partnerQuestions) ...[
            _buildQuestionCard(
              q: q,
              accentColor: AppColors.player2Badge,
              onDelete: null,
            ),
          ],
      ],
    );
  }

  Widget _buildQuestionCard({
    required QuizQuestion q,
    required Color accentColor,
    VoidCallback? onDelete,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: accentColor.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Badge for question type
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: q.isOpenEnded
                      ? AppColors.player2Badge.withOpacity(0.15)
                      : AppColors.player1Badge.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  q.isOpenEnded ? '📝 Açık Uçlu (Metin)' : '🔤 4 Şıklı Test',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: q.isOpenEnded ? AppColors.player2Badge : AppColors.player1Badge,
                  ),
                ),
              ),
              const Spacer(),
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.angryRed, size: 20),
                  onPressed: onDelete,
                  tooltip: 'Sil',
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            q.text,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: AppColors.textPrimary),
          ),
          if (q.isMultipleChoice && q.options.isNotEmpty) ...[
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: q.options.map((opt) {
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.backgroundWarm,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.borderSubtle),
                  ),
                  child: Text(
                    opt,
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }
}
