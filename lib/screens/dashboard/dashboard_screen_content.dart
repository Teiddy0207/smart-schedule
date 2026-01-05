import 'package:flutter/material.dart';
import '../../constants/app_constants.dart';
import '../../widgets/month_calendar_widget.dart';
import '../../widgets/daily_schedule_widget.dart';
import '../../widgets/year_view_widget.dart';

enum DashboardView { daily, monthly, yearly }

class DashboardScreenContent extends StatefulWidget {
  const DashboardScreenContent({super.key});

  @override
  State<DashboardScreenContent> createState() => _DashboardScreenContentState();
}

class _DashboardScreenContentState extends State<DashboardScreenContent> {
  DashboardView _currentView = DashboardView.daily;
  DateTime _selectedDate = DateTime.now();

  void _showDailyView() {
    setState(() {
      _currentView = DashboardView.daily;
    });
  }

  void _showMonthlyView() {
    setState(() {
      _currentView = DashboardView.monthly;
    });
  }

  void _showYearlyView() {
    setState(() {
      _currentView = DashboardView.yearly;
    });
  }

  void _onDateSelected(DateTime date) {
    setState(() {
      _selectedDate = date;
      _currentView = DashboardView.daily;
    });
  }

  void _onMonthSelected(int month) {
    setState(() {
      // Giữ ngày hiện tại, nhưng clamp về ngày cuối tháng nếu tháng mới có ít ngày hơn
      final year = _selectedDate.year;
      final currentDay = _selectedDate.day;
      
      // Tìm ngày cuối cùng của tháng mới
      final lastDayOfMonth = DateTime(year, month + 1, 0).day;
      
      // Chọn ngày nhỏ hơn giữa ngày hiện tại và ngày cuối tháng
      final validDay = currentDay <= lastDayOfMonth ? currentDay : lastDayOfMonth;
      
      _selectedDate = DateTime(year, month, validDay);
      _currentView = DashboardView.monthly;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppConstants.backgroundColor,
      child: _buildCurrentView(),
    );
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      case DashboardView.daily:
        return DailyScheduleWidget(
          selectedDate: _selectedDate,
          onShowMonthView: _showMonthlyView,
        );
      case DashboardView.monthly:
        return MonthCalendarWidget(
          selectedDate: _selectedDate,
          onDateSelected: _onDateSelected,
          onBack: _showYearlyView,
        );
      case DashboardView.yearly:
        return YearViewWidget(
          year: _selectedDate.year,
          selectedMonth: _selectedDate.month,
          onMonthSelected: _onMonthSelected,
          onBack: null, // Không có back từ year view
        );
    }
  }
}
