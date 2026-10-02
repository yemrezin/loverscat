import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/utils/haptic_utils.dart';
import '../../../pet/domain/models/pet_avatar.dart';

/// Form component for new user registration and pet avatar selection.
class AuthRegisterForm extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final TextEditingController confirmPasswordController;
  final PetType selectedPet;
  final ValueChanged<PetType> onPetChanged;
  final bool isConnecting;
  final VoidCallback onSubmit;

  const AuthRegisterForm({
    super.key,
    required this.usernameController,
    required this.passwordController,
    required this.confirmPasswordController,
    required this.selectedPet,
    required this.onPetChanged,
    required this.isConnecting,
    required this.onSubmit,
  });

  @override
  State<AuthRegisterForm> createState() => _AuthRegisterFormState();
}

class _AuthRegisterFormState extends State<AuthRegisterForm> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Yeni Hesap Oluştur',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Kullanıcı adınız benzersiz olmalı ve sadece size ait olacaktır.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),

        // Pet Selection
        const Text(
          'Karakterini / Rumuzunu Seç:',
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: PetType.values.map((type) {
            final isSelected = widget.selectedPet == type;
            return Expanded(
              child: GestureDetector(
                onTap: () {
                  HapticUtils.light();
                  widget.onPetChanged(type);
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? type.primaryColor.withOpacity(0.2) : Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected ? type.primaryColor : AppColors.borderSubtle,
                      width: isSelected ? 2.5 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Image.asset(type.headAssetPath, width: 34, height: 34),
                      const SizedBox(height: 2),
                      Text(
                        type.displayName.split(' ')[0],
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
        const SizedBox(height: 16),

        // Username
        TextField(
          controller: widget.usernameController,
          decoration: InputDecoration(
            labelText: 'Benzersiz Kullanıcı Adı',
            hintText: 'örn: tilki_reis',
            prefixText: '@ ',
            prefixIcon: const Icon(Icons.alternate_email_rounded, color: AppColors.player2Badge, size: 20),
            filled: true,
            fillColor: AppColors.backgroundWarm.withOpacity(0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.borderSubtle)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.borderSubtle)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.player2Badge, width: 2)),
          ),
          autocorrect: false,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),

        // Password
        TextField(
          controller: widget.passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Şifre (En az 4 karakter)',
            prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.player2Badge, size: 20),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword ? Icons.visibility_off_rounded : Icons.visibility_rounded,
                color: AppColors.textSecondary,
                size: 20,
              ),
              onPressed: () {
                setState(() {
                  _obscurePassword = !_obscurePassword;
                });
              },
            ),
            filled: true,
            fillColor: AppColors.backgroundWarm.withOpacity(0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.borderSubtle)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.borderSubtle)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.player2Badge, width: 2)),
          ),
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 12),

        // Confirm Password
        TextField(
          controller: widget.confirmPasswordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Şifre Tekrar',
            prefixIcon: const Icon(Icons.lock_clock_rounded, color: AppColors.player2Badge, size: 20),
            filled: true,
            fillColor: AppColors.backgroundWarm.withOpacity(0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.borderSubtle)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.borderSubtle)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.player2Badge, width: 2)),
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => widget.onSubmit(),
        ),
        const SizedBox(height: 22),

        // Submit Button
        ElevatedButton(
          onPressed: widget.isConnecting ? null : widget.onSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.player2Badge,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(vertical: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            elevation: 2,
          ),
          child: widget.isConnecting
              ? const SizedBox(
                  height: 20,
                  width: 20,
                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                )
              : const Text(
                  'Kayıt Ol ve Başla ✨',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }
}
