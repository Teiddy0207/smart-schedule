import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';

/// Widget hiển thị lịch tháng với grid layout
class MonthCalendarWidget extends StatefulWidget {
  final DateTime? selectedDate;
  final Function(DateTime)? onDateSelected;
  final VoidCallback? onBack;

  const MonthCalendarWidget({
    super.key,
    this.selectedDate,
    this.onDateSelected,
    this.onBack,
  });


  @override
  State<MonthCalendarWidget> createState() => _MonthCalendarWidgetState();
}

class _MonthCalendarWidgetState extends State<MonthCalendarWidget> {
  late DateTime _currentMonth;
  late DateTime _selectedDate;

  // Tên các ngày trong tuần (tiếng Việt)
  final List<String> _weekDays = ['T2', 'T3', 'T4', 'T5', 'T6', 'T7', 'CN'];

  @override
  void initState() {
    super.initState();
    final initialDate = widget.selectedDate ?? DateTime.now();
    _currentMonth = initialDate;
    _selectedDate = initialDate;
  }



  // Lấy tên tháng tiếng Việt
  String _getMonthName(DateTime date) {
    const months = [
      'Tháng 1', 'Tháng 2', 'Tháng 3', 'Tháng 4',
      'Tháng 5', 'Tháng 6', 'Tháng 7', 'Tháng 8',
      'Tháng 9', 'Tháng 10', 'Tháng 11', 'Tháng 12'
    ];
    return months[date.month - 1];
  }

  // Lấy danh sách ngày trong tháng
  List<DateTime?> _getDaysInMonth(DateTime month) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    
    // Tìm ngày đầu tiên của tuần (Thứ 2)
    int weekdayOfFirst = firstDayOfMonth.weekday; // 1 = Monday, 7 = Sunday
    int daysToSubtract = weekdayOfFirst - 1; // Số ngày cần lùi để đến Thứ 2
    
    final startDate = firstDayOfMonth.subtract(Duration(days: daysToSubtract));
    
    List<DateTime?> days = [];
    DateTime current = startDate;
    
    // Tạo 6 tuần (42 ngày)
    for (int i = 0; i < 42; i++) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }
    
    return days;
  }

  // Chuyển tháng trước
  void _previousMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
    });
  }

  // Chuyển tháng sau
  void _nextMonth() {
    setState(() {
      _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
    });
  }

  // Refresh về tháng hiện tại
  void _refreshToToday() {
    setState(() {
      _currentMonth = DateTime.now();
      _selectedDate = DateTime.now();
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = _getDaysInMonth(_currentMonth);
    
    return Column(
      children: [
        // Header với tên tháng và nút điều hướng
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
              if (widget.onBack == null)
                InkWell(
                  onTap: _previousMonth,
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
              const SizedBox(width: 6),
              Text(
                _getMonthName(_currentMonth),
                style: AppConstants.headingSmall.copyWith(
                  color: AppConstants.primaryColor,
                ),
              ),
              const Spacer(),
              InkWell(
                onTap: _refreshToToday,
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
        
        // Calendar Grid
        Container(
          margin: const EdgeInsets.symmetric(horizontal: AppConstants.spacingL),
          padding: const EdgeInsets.all(AppConstants.spacingL),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(AppConstants.radiusL),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Header với tên các ngày trong tuần
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: _weekDays.map((day) {
                  return SizedBox(
                    width: 44,
                    child: Center(
                      child: Text(
                        day,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppConstants.spacingL),
              
              // Grid các ngày
              ...List.generate(6, (weekIndex) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: AppConstants.spacingM),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: List.generate(7, (dayIndex) {
                      final index = weekIndex * 7 + dayIndex;
                      final date = days[index];
                      
                      if (date == null) {
                        return const SizedBox(width: 44, height: 52);
                      }
                      
                      final isCurrentMonth = date.month == _currentMonth.month;
                      final isToday = date.year == DateTime.now().year &&
                          date.month == DateTime.now().month &&
                          date.day == DateTime.now().day;
                      
                      return InkWell(
                        onTap: () {
                          setState(() {
                            _selectedDate = date;
                          });
                          widget.onDateSelected?.call(date);
                        },
                        borderRadius: BorderRadius.circular(AppConstants.radiusS),
                        child: Container(
                          width: 44,
                          height: 52,
                          decoration: BoxDecoration(
                            color: isToday
                                ? AppConstants.primaryColor
                                : Colors.transparent,
                            borderRadius: BorderRadius.circular(AppConstants.radiusS),
                          ),
                          child: Center(
                            child: Text(
                              '${date.day}',
                              style: TextStyle(
                                fontSize: 17,
                                fontWeight: isToday
                                    ? FontWeight.bold
                                    : FontWeight.w600,
                                color: isToday
                                    ? Colors.white
                                    : isCurrentMonth
                                        ? Colors.black87
                                        : Colors.grey[400],
                              ),
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }
}
