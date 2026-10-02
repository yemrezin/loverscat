import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../quiz/domain/models/question.dart';

/// Modal bottom sheet for adding a new custom question (either Open-Ended text or 4-Option Multiple Choice).
class AddCustomQuestionSheet extends StatefulWidget {
  final Future<void> Function(String text, List<String> options, QuestionType type) onSave;

  const AddCustomQuestionSheet({
    super.key,
    required this.onSave,
  });

  static Future<void> show({
    required BuildContext context,
    required Future<void> Function(String text, List<String> options, QuestionType type) onSave,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => AddCustomQuestionSheet(onSave: onSave),
    );
  }

  @override
  State<AddCustomQuestionSheet> createState() => _AddCustomQuestionSheetState();
}

class _AddCustomQuestionSheetState extends State<AddCustomQuestionSheet> {
  final _questionCtrl = TextEditingController();
  final _optionCtrls = List.generate(4, (_) => TextEditingController());
  final _formKey = GlobalKey<FormState>();
  QuestionType _selectedType = QuestionType.openEnded;
  bool _isSaving = false;

  @override
  void dispose() {
    _questionCtrl.dispose();
    for (final c in _optionCtrls) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) return;
    final text = _questionCtrl.text.trim();
    final options = _selectedType == QuestionType.multipleChoice
        ? _optionCtrls.map((c) => c.text.trim()).toList()
        : <String>[];

    setState(() => _isSaving = true);
    HapticUtils.medium();
    try {
      await widget.onSave(text, options, _selectedType);
      if (mounted) {
        Navigator.of(context).pop();
      }
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
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
                          setState(() => _selectedType = QuestionType.openEnded);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedType == QuestionType.openEnded
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
                                color: _selectedType == QuestionType.openEnded
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
                          setState(() => _selectedType = QuestionType.multipleChoice);
                        },
                        borderRadius: BorderRadius.circular(12),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 180),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedType == QuestionType.multipleChoice
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
                                color: _selectedType == QuestionType.multipleChoice
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

              // Info banner
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _selectedType == QuestionType.openEnded
                      ? AppColors.pastelMint.withOpacity(0.4)
                      : AppColors.pastelLavender.withOpacity(0.4),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: _selectedType == QuestionType.openEnded
                        ? AppColors.player2Badge.withOpacity(0.3)
                        : AppColors.player1Badge.withOpacity(0.3),
                  ),
                ),
                child: Text(
                  _selectedType == QuestionType.openEnded
                      ? '💬 Açık Uçlu Soru: Oyuncular kendi metin yanıtlarını yazacak ve partnerin tahminini kendisi değerlendirecektir (Doğru / Yanlış kararı sana ait!).'
                      : '💡 Çoktan Seçmeli: Cevaplar oyun sırasında siz ve partneriniz tarafından canlı seçilir.',
                  style: const TextStyle(fontSize: 12, color: AppColors.textPrimary, height: 1.3),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 14),

              // Question Text
              TextFormField(
                controller: _questionCtrl,
                maxLines: 2,
                decoration: InputDecoration(
                  labelText: 'Soru Metni',
                  hintText: _selectedType == QuestionType.openEnded
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
              if (_selectedType == QuestionType.multipleChoice) ...[
                const Text(
                  'Şıklar (4 Seçenek):',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 8),

                for (int i = 0; i < 4; i++) ...[
                  TextFormField(
                    controller: _optionCtrls[i],
                    decoration: InputDecoration(
                      prefixIcon: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Text(
                          String.fromCharCode(65 + i),
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
                onPressed: _isSaving ? null : _handleSave,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _selectedType == QuestionType.openEnded
                      ? AppColors.player2Badge
                      : AppColors.player1Badge,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: _isSaving
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                      )
                    : const Text('Soruyu Kaydet 🐾', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
