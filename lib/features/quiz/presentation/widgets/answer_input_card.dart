import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../domain/models/question.dart';

/// Card providing choice selection for multiple-choice questions
/// or a textfield for open-ended questions.
class AnswerInputCard extends StatefulWidget {
  final QuizQuestion question;
  final String buttonLabel;
  final ValueChanged<String> onSubmit;
  final Color accentColor;
  final VoidCallback? onSkip;

  const AnswerInputCard({
    super.key,
    required this.question,
    required this.buttonLabel,
    required this.onSubmit,
    required this.accentColor,
    this.onSkip,
  });

  @override
  State<AnswerInputCard> createState() => _AnswerInputCardState();
}

class _AnswerInputCardState extends State<AnswerInputCard> {
  String? _selectedOption;
  final TextEditingController _textController = TextEditingController();

  @override
  void didUpdateWidget(covariant AnswerInputCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.question.id != widget.question.id) {
      setState(() {
        _selectedOption = null;
        _textController.clear();
      });
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  void _submit() {
    if (widget.question.isMultipleChoice) {
      if (_selectedOption == null) return;
      HapticUtils.light();
      widget.onSubmit(_selectedOption!);
      setState(() {
        _selectedOption = null;
      });
    } else {
      final text = _textController.text.trim();
      if (text.isEmpty) return;
      HapticUtils.light();
      widget.onSubmit(text);
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (widget.question.isMultipleChoice) ...[
          ...widget.question.options.asMap().entries.map((entry) {
            final index = entry.key;
            final optionText = entry.value;
            final isSelected = _selectedOption == optionText;
            final optionLetters = ['A', 'B', 'C', 'D'];
            final letter = index < optionLetters.length ? optionLetters[index] : '${index + 1}';

            return Padding(
              padding: const EdgeInsets.only(bottom: 12.0),
              child: InkWell(
                onTap: () {
                  HapticUtils.light();
                  setState(() {
                    _selectedOption = optionText;
                  });
                },
                borderRadius: BorderRadius.circular(20),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
                  decoration: BoxDecoration(
                    color: isSelected ? widget.accentColor.withOpacity(0.18) : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isSelected ? widget.accentColor : AppColors.borderSubtle,
                      width: isSelected ? 2.5 : 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: isSelected
                            ? widget.accentColor.withOpacity(0.2)
                            : const Color(0x0A4A4453),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: isSelected ? widget.accentColor : AppColors.borderSubtle.withOpacity(0.6),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            letter,
                            style: TextStyle(
                              color: isSelected ? Colors.white : AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          optionText,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                            color: AppColors.textPrimary,
                            height: 1.3,
                          ),
                        ),
                      ),
                      if (isSelected)
                        Icon(
                          Icons.check_circle_rounded,
                          color: widget.accentColor,
                          size: 22,
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
        ] else ...[
          // Open ended text input
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x0A4A4453),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: TextField(
              controller: _textController,
              maxLines: 3,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
              decoration: InputDecoration(
                hintText: 'Cevabını buraya yaz...',
                hintStyle: TextStyle(
                  color: AppColors.textLight.withOpacity(0.8),
                  fontSize: 14,
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.all(18),
              ),
              onChanged: (_) => setState(() {}),
            ),
          ),
          const SizedBox(height: 12),
        ],
        const SizedBox(height: 16),
        // Submit Button
        ElevatedButton(
          onPressed: ((widget.question.isMultipleChoice && _selectedOption != null) ||
                  (widget.question.isOpenEnded && _textController.text.trim().isNotEmpty))
              ? _submit
              : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: widget.accentColor,
            disabledBackgroundColor: widget.accentColor.withOpacity(0.35),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
            ),
          ),
          child: Text(
            widget.buttonLabel,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.2,
            ),
          ),
        ),
        if (widget.onSkip != null) ...[
          const SizedBox(height: 8),
          Center(
            child: TextButton.icon(
              onPressed: () {
                HapticUtils.light();
                widget.onSkip!();
              },
              icon: const Icon(Icons.timer_off_outlined, size: 16, color: AppColors.textSecondary),
              label: const Text(
                'Boş Bırak / Pas Geç',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }
}
