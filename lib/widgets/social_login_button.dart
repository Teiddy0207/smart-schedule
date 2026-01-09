import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Social login button widget with consistent styling
class SocialLoginButton extends StatelessWidget {
  final Widget icon;
  final VoidCallback onPressed;

  const SocialLoginButton({
    super.key,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 14),
        side: BorderSide(color: Colors.grey[300]!),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
        ),
        backgroundColor: Colors.white,
      ),
      child: icon,
    );
  }
}
