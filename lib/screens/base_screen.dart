import 'package:flutter/material.dart';
import 'widgets/bottom_nav_bar.dart';
import '../utils/navigation_helper.dart';

class BaseScreen extends StatefulWidget {
  final Widget body;
  final PreferredSizeWidget? appBar;
  final int initialBottomNavIndex;
  final Function(int)? onBottomNavTap; // Optional: để override navigation nếu cần

  const BaseScreen({
    super.key,
    required this.body,
    this.appBar,
    this.initialBottomNavIndex = 0,
    this.onBottomNavTap,
  });

  @override
  State<BaseScreen> createState() => _BaseScreenState();
}

class _BaseScreenState extends State<BaseScreen> {
  late int _currentBottomNavIndex;

  @override
  void initState() {
    super.initState();
    _currentBottomNavIndex = widget.initialBottomNavIndex;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: widget.appBar,
      body: widget.body,
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentBottomNavIndex,
        onTap: (index) {
          // Lưu currentIndex trước khi setState
          final previousIndex = _currentBottomNavIndex;
          
          setState(() {
            _currentBottomNavIndex = index;
          });
          
          // Nếu có custom callback, dùng nó; nếu không, dùng navigation helper mặc định
          if (widget.onBottomNavTap != null) {
            widget.onBottomNavTap!(index);
          } else {
            // Navigation tự động dựa trên index (dùng previousIndex để check)
            NavigationHelper.navigateToScreen(context, index, previousIndex);
          }
        },
      ),
    );
  }
}

