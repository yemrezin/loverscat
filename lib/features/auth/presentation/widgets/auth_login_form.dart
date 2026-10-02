import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

/// Form component for user login credentials.
class AuthLoginForm extends StatefulWidget {
  final TextEditingController usernameController;
  final TextEditingController passwordController;
  final bool isConnecting;
  final VoidCallback onSubmit;

  const AuthLoginForm({
    super.key,
    required this.usernameController,
    required this.passwordController,
    required this.isConnecting,
    required this.onSubmit,
  });

  @override
  State<AuthLoginForm> createState() => _AuthLoginFormState();
}

class _AuthLoginFormState extends State<AuthLoginForm> {
  bool _obscurePassword = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Hesabına Giriş Yap',
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Kullanıcı adınızı ve şifrenizi girerek bağlanın.',
          style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 18),

        // Username
        TextField(
          controller: widget.usernameController,
          decoration: InputDecoration(
            labelText: 'Kullanıcı Adı',
            hintText: 'örn: kedi_asigi',
            prefixText: '@ ',
            prefixIcon: const Icon(Icons.alternate_email_rounded, color: AppColors.player1Badge, size: 20),
            filled: true,
            fillColor: AppColors.backgroundWarm.withOpacity(0.5),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.borderSubtle)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.borderSubtle)),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.player1Badge, width: 2)),
          ),
          autocorrect: false,
          textInputAction: TextInputAction.next,
        ),
        const SizedBox(height: 14),

        // Password
        TextField(
          controller: widget.passwordController,
          obscureText: _obscurePassword,
          decoration: InputDecoration(
            labelText: 'Şifre',
            prefixIcon: const Icon(Icons.lock_rounded, color: AppColors.player1Badge, size: 20),
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
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppColors.player1Badge, width: 2)),
          ),
          textInputAction: TextInputAction.done,
          onSubmitted: (_) => widget.onSubmit(),
        ),
        const SizedBox(height: 22),

        // Submit Button
        ElevatedButton(
          onPressed: widget.isConnecting ? null : widget.onSubmit,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.player1Badge,
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
                  'Giriş Yap 🐾',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
        ),
      ],
    );
  }
}
