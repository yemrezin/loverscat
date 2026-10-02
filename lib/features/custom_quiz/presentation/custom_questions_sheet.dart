import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../quiz/domain/models/question.dart';
import '../../quiz/presentation/controllers/quiz_providers.dart';
import '../../online/controllers/online_controller.dart';
import 'widgets/add_custom_question_sheet.dart';
import 'widgets/custom_question_card.dart';

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

    AddCustomQuestionSheet.show(
      context: context,
      onSave: (text, options, type) async {
        final online = ref.read(onlineProvider);
        if (online.isLoggedIn) {
          await ref.read(onlineProvider.notifier).createCustomQuestion(
            text,
            options,
            type: type,
          );
        } else {
          final newQ = QuizQuestion(
            id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
            text: text,
            type: type,
            options: options,
            isCustom: true,
            author: online.user.username,
          );
          await ref.read(quizRepositoryProvider).saveCustomQuestion(newQ);
        }
        await _loadQuestions();
      },
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
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppColors.player1Badge))
                : _buildManagementList(online),
          ),
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
          for (final q in _myQuestions)
            CustomQuestionCard(
              question: q,
              accentColor: AppColors.player1Badge,
              onDelete: () => _deleteQuestion(q.id),
            ),
        const Divider(height: 28),
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
          for (final q in _partnerQuestions)
            CustomQuestionCard(
              question: q,
              accentColor: AppColors.player2Badge,
            ),
      ],
    );
  }
}
