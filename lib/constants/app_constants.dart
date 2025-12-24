import 'package:flutter/material.dart';

/// Application-wide constants for colors, styles, and other values
class AppConstants {
  // Private constructor to prevent instantiation
  AppConstants._();

  // ============ Colors ============
  
  /// Primary brand color
  static const Color primaryColor = Color(0xFF6B5CE6);
  
  /// Secondary brand color
  static const Color secondaryColor = Color(0xFF9B7EDE);
  
  /// Light purple accent
  static const Color lightPurple = Color(0xFFB8A9E8);
  
  /// Gradient start color
  static const Color gradientStart = Color(0xFF9C88FF);
  
  /// Gradient end color
  static const Color gradientEnd = Color(0xFF7C3AED);
  
  /// Dashboard gradient start
  static const Color dashboardGradientStart = Color(0xFF7E6DF7);
  
  /// Background color
  static const Color backgroundColor = Color(0xFFF5F5F7);
  
  /// Input field background
  static const Color inputBackground = Color(0xFFF0F4F8);
  
  /// Google blue color
  static const Color googleBlue = Color(0xFF4285F4);
  
  /// Microsoft blue color
  static const Color microsoftBlue = Color(0xFF0078D4);
  
  /// Icon gray color
  static const Color iconGray = Color(0xFFB4BAC7);

  // ============ Gradients ============
  
  /// Primary gradient for buttons and headers
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [secondaryColor, primaryColor],
  );
  
  /// Login screen gradient
  static const LinearGradient loginGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [secondaryColor, primaryColor],
  );
  
  /// AppBar gradient
  static const LinearGradient appBarGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [gradientStart, gradientEnd],
  );
  
  /// Dashboard AppBar gradient
  static const LinearGradient dashboardAppBarGradient = LinearGradient(
    colors: [dashboardGradientStart, primaryColor],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ============ Spacing ============
  
  static const double spacingXS = 4.0;
  static const double spacingS = 8.0;
  static const double spacingM = 12.0;
  static const double spacingL = 16.0;
  static const double spacingXL = 20.0;
  static const double spacingXXL = 24.0;
  static const double spacing3XL = 32.0;
  static const double spacing4XL = 40.0;

  // ============ Border Radius ============
  
  static const double radiusS = 8.0;
  static const double radiusM = 12.0;
  static const double radiusL = 20.0;
  static const double radiusXL = 24.0;
  static const double radiusCircle = 50.0;

  // ============ Text Styles ============
  
  static const TextStyle headingLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  static const TextStyle headingMedium = TextStyle(
    fontSize: 26,
    fontWeight: FontWeight.bold,
    color: Colors.white,
  );
  
  static const TextStyle headingSmall = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w700,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    color: Colors.white,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    color: Colors.black87,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: Colors.black87,
  );
  
  static const TextStyle buttonText = TextStyle(
    color: Colors.white,
    fontSize: 16,
    fontWeight: FontWeight.w600,
  );

  // ============ Sizes ============
  
  static const double iconSizeSmall = 20.0;
  static const double iconSizeMedium = 24.0;
  static const double iconSizeLarge = 26.0;
  static const double iconSizeXL = 50.0;
  static const double iconSizeXXL = 64.0;
  
  static const double logoSize = 80.0;
  static const double avatarSize = 40.0;

  // ============ Animation ============
  
  static const Duration animationDuration = Duration(milliseconds: 300);
  static const Duration shortAnimationDuration = Duration(milliseconds: 200);

  // ============ Strings ============
  
  static const String appName = 'Smart Meet';
  static const String appTagline = 'Tự động tìm lịch thông minh';
}
