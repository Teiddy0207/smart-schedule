import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Gradient AppBar widget with consistent styling
class GradientAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? leading;
  final List<Widget>? actions;
  final LinearGradient? gradient;

  const GradientAppBar({
    super.key,
    required this.title,
    this.leading,
    this.actions,
    this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: gradient ?? AppConstants.appBarGradient,
        ),
      ),
      elevation: 0,
      leading: leading,
      title: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 18,
        ),
      ),
      actions: actions,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

/// Icon button with circular white background for use in AppBar
class AppBarIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;
  final Color iconColor;
  final Color backgroundColor;
  final double size;

  const AppBarIconButton({
    super.key,
    required this.icon,
    required this.onPressed,
    this.iconColor = AppConstants.gradientEnd,
    this.backgroundColor = Colors.white,
    this.size = AppConstants.iconSizeSmall,
  });

  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          shape: BoxShape.circle,
        ),
        padding: const EdgeInsets.all(AppConstants.spacingS),
        child: Icon(icon, color: iconColor, size: size),
      ),
      onPressed: onPressed,
    );
  }
}
