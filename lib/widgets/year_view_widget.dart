import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

/// Widget hiển thị dashboard năm với grid 12 tháng
class YearViewWidget extends StatelessWidget {
  final int year;
  final int? selectedMonth;
  final Function(int)? onMonthSelected;
  final VoidCallback? onBack;

  const YearViewWidget({
    super.key,
    required this.year,
    this.selectedMonth,
    this.onMonthSelected,
    this.onBack,
  });

  // Tên các tháng tiếng Việt
  static const List<String> _monthNames = [
    'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4',
    'Tháng 5', 'Tháng 6', 'Tháng 7', 'Tháng 8',
    'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12',
  ];

  @override
  Widget build(BuildContext context) {
    final currentMonth = DateTime.now().month;
    final currentYear = DateTime.now().year;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header với năm
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppConstants.spacingL,
            AppConstants.spacingXXL,
            AppConstants.spacingL,
            AppConstants.spacingL,
          ),
          child: Row(
            children: [
              if (onBack != null)
                InkWell(
                  onTap: onBack,
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
              // Placeholder để căn thẳng hàng với các views có nút back
              if (onBack == null)
                const SizedBox(width: 6),
              if (onBack != null) const SizedBox(width: 6),
              Text(
                '$year',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppConstants.primaryColor,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: () {
                  // Refresh về năm hiện tại
                },
                borderRadius: BorderRadius.circular(AppConstants.radiusCircle),
                child: Container(
                  padding: const EdgeInsets.all(AppConstants.spacingM),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.refresh,
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
                final isCurrentMonth = month == currentMonth && year == currentYear;

                return InkWell(
                  onTap: () {
                    onMonthSelected?.call(month);
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
}
