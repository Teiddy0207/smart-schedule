import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

/// Widget hiển thị dashboard năm với grid 12 tháng và navigation giữa các năm
class YearViewWidget extends StatefulWidget {
  final int initialYear;
  final int? selectedMonth;
  final Function(int month, int year)? onMonthSelected;
  final VoidCallback? onBack;

  const YearViewWidget({
    super.key,
    required this.initialYear,
    this.selectedMonth,
    this.onMonthSelected,
    this.onBack,
  });

  @override
  State<YearViewWidget> createState() => _YearViewWidgetState();
}

class _YearViewWidgetState extends State<YearViewWidget> {
  late int _currentYear;

  // Tên các tháng tiếng Việt
  static const List<String> _monthNames = [
    'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4',
    'Tháng 5', 'Tháng 6', 'Tháng 7', 'Tháng 8',
    'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12',
  ];

  @override
  void initState() {
    super.initState();
    _currentYear = widget.initialYear;
  }

  void _previousYear() {
    setState(() {
      _currentYear--;
    });
  }

  void _nextYear() {
    setState(() {
      _currentYear++;
    });
  }

  void _goToCurrentYear() {
    setState(() {
      _currentYear = DateTime.now().year;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header với năm và navigation
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.spacingL,
            AppConstants.spacingXXL,
            AppConstants.spacingL,
            AppConstants.spacingL,
          ),
          child: Row(
            children: [
              if (widget.onBack != null)
                InkWell(
                  onTap: widget.onBack,
                  borderRadius: BorderRadius.circular(AppConstants.radiusM),
                  child: const Padding(
                    padding: EdgeInsets.all(AppConstants.spacingS),
                    child: Icon(
                      Icons.chevron_left,
                      color: AppConstants.primaryColor,
                      size: AppConstants.spacing3XL,
                    ),
                  ),
                ),
              if (widget.onBack == null) const SizedBox(width: 6),
              if (widget.onBack != null) const SizedBox(width: 6),

              // Year navigation: < 2026 >
              _buildYearNavigator(),

              const Spacer(),

              // Go to current year button
              InkWell(
                onTap: _goToCurrentYear,
                borderRadius: BorderRadius.circular(AppConstants.radiusCircle),
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.spacingM),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.today,
                    color: AppConstants.primaryColor,
                    size: AppConstants.iconSizeMedium,
                  ),
                ),
              ),
            ],
          ),
        ),

        // Grid 12 tháng (3x4)
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                childAspectRatio: 1.1,
                crossAxisSpacing: AppConstants.spacingM,
                mainAxisSpacing: AppConstants.spacingM,
              ),
              itemCount: 12,
              itemBuilder: (context, index) {
                final month = index + 1;
                final isCurrentMonth = month == currentMonth && _currentYear == currentYear;

                return InkWell(
                  onTap: () {
                    widget.onMonthSelected?.call(month, _currentYear);
                  },
                  borderRadius: BorderRadius.circular(AppConstants.radiusL),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: isCurrentMonth
                          ? AppConstants.dashboardAppBarGradient
                          : null,
                      color: isCurrentMonth
                          ? null
                          : AppConstants.primaryColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppConstants.radiusL),
                    ),
                    child: Center(
                      child: Text(
                        _monthNames[index],
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: isCurrentMonth
                              ? FontWeight.bold
                              : FontWeight.w700,
                          color: isCurrentMonth
                              ? Colors.white
                              : Colors.black87,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  /// Build year navigator with prev/next buttons
  Widget _buildYearNavigator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Previous year button
        InkWell(
          onTap: _previousYear,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(
              Icons.arrow_back_ios,
              color: AppConstants.primaryColor,
              size: 18,
            ),
          ),
        ),
        const SizedBox(width: 8),

        // Year text
        Text(
          '$_currentYear',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppConstants.primaryColor,
          ),
        ),

        const SizedBox(width: 8),
        // Next year button
        InkWell(
          onTap: _nextYear,
          borderRadius: BorderRadius.circular(AppConstants.radiusM),
          child: const Padding(
            padding: EdgeInsets.all(4),
            child: Icon(
              Icons.arrow_forward_ios,
              color: AppConstants.primaryColor,
              size: 18,
            ),
          ),
        ),
      ],
    );
  }
}