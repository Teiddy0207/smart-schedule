import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class GoogleIcon extends StatelessWidget {
  final double size;

  const GoogleIcon({super.key, this.size = 24});

  @override
  Widget build(BuildContext context) {
    return SvgPicture.string(
      '''
<svg width="533.5" height="544.3" viewBox="0 0 533.5 544.3" xmlns="http://www.w3.org/2000/svg">
  <path fill="#4285F4" d="M533.5 278.4c0-17.4-1.4-34.1-4-50.2H272v95h146.9c-6.3 33.9-25.1 62.6-53.5 81.8v67h86.5c50.6-46.6 81.6-115.4 81.6-193.6z"/>
  <path fill="#34A853" d="M272 544.3c72.6 0 133.5-24.1 178-65.4l-86.5-67c-24.1 16.1-55 25.7-91.5 25.7-70.4 0-130.1-47.6-151.5-111.4h-89v69.9C75.5 475.3 168.1 544.3 272 544.3z"/>
  <path fill="#FBBC04" d="M120.5 326.2c-10.1-30-10.1-62.4 0-92.4v-69.9h-89c-39.2 78.4-39.2 170.8 0 249.2l89-69.9z"/>
  <path fill="#EA4335" d="M272 107.7c39.5-.6 77.7 14.5 106.6 41.8l79.4-79.4C408.6 24.4 343.1-1.1 272 0 168.1 0 75.5 69 31.5 163.9l89 69.9C141.9 155.3 201.6 107.7 272 107.7z"/>
</svg>
      ''',
      width: size,
      height: size,
    );
  }
}

