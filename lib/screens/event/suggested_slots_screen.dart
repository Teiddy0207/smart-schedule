import 'package:flutter/material.dart';
import '../../services/meeting_service.dart';
import '../../widgets/top_notification.dart';

/// Model for suggested time slot
class SuggestedSlot {
  final String id;
  final DateTime startTime;
  final DateTime endTime;
  final int score;
  final int availableCount;
  final int totalCount;
  bool isSelected;

  SuggestedSlot({
    required this.id,
    required this.startTime,
    required this.endTime,
    this.score = 0,
    this.availableCount = 0,
    this.totalCount = 0,
    this.isSelected = false,
  });

  String get dayOfWeek {
    const days = ['Chủ nhật', 'Thứ 2', 'Thứ 3', 'Thứ 4', 'Thứ 5', 'Thứ 6', 'Thứ 7'];
    return days[startTime.weekday % 7];
  }

  String get formattedDate {
    return '${startTime.day.toString().padLeft(2, '0')}/${startTime.month.toString().padLeft(2, '0')}/${startTime.year}';
  }

  String get formattedTime {
    final startHour = startTime.hour.toString().padLeft(2, '0');
    final startMinute = startTime.minute.toString().padLeft(2, '0');
    final endHour = endTime.hour.toString().padLeft(2, '0');
    final endMinute = endTime.minute.toString().padLeft(2, '0');
    return '${startHour}h$startMinute - ${endHour}h$endMinute';
  }
}

/// Screen to show suggested time slots
class SuggestedSlotsScreen extends StatefulWidget {
  final String eventTitle;
  final int durationMinutes;
  final List<String> participantEmails;
  final List<String> participantIds;
  final String timePreference; // 'morning', 'afternoon', 'evening'

  const SuggestedSlotsScreen({
    super.key,
    required this.eventTitle,
    required this.durationMinutes,
    required this.participantEmails,
    this.participantIds = const [],
    this.timePreference = '',
  });

  @override
  State<SuggestedSlotsScreen> createState() => _SuggestedSlotsScreenState();
}

class _SuggestedSlotsScreenState extends State<SuggestedSlotsScreen> {
  static const _primaryColor = Color(0xFF6C63FF);
  
  List<SuggestedSlot> _slots = [];
  bool _isLoading = true;
  SuggestedSlot? _selectedSlot;
  String? _warning;
  int _connectedCount = 0;
  int _totalParticipants = 0;
  DateTime _selectedDate = DateTime.now();
  bool _workingHoursOnly = true;

  @override
  void initState() {
    super.initState();
    _loadSuggestedSlots();
  }

  void _showDatePicker() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(primary: _primaryColor),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedSlot = null;
      });
      _loadSuggestedSlots();
    }
  }

  Future<void> _loadSuggestedSlots() async {
    setState(() => _isLoading = true);

    try {
      // Format selected date for API (YYYY-MM-DD)
      final dateStr = '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
      
      // Call backend API to get suggested slots with status
      final response = await MeetingService.getSuggestedSlotsWithStatus(
        userIds: widget.participantIds,
        durationMinutes: widget.durationMinutes,
        daysAhead: 1, // Only search for the selected day
        workingHoursOnly: _workingHoursOnly,
        startDate: dateStr,
        timePreference: widget.timePreference,
      );

      final slotsData = response['slots'] as List<dynamic>? ?? [];
      final loadedSlots = <SuggestedSlot>[];
      for (int i = 0; i < slotsData.length; i++) {
        final data = slotsData[i] as Map<String, dynamic>;
        loadedSlots.add(SuggestedSlot(
          id: 'slot_$i',
          startTime: DateTime.parse(data['start_time'] as String).toLocal(),
          endTime: DateTime.parse(data['end_time'] as String).toLocal(),
          score: data['score'] as int? ?? 0,
          availableCount: data['available_count'] as int? ?? 0,
          totalCount: data['total_count'] as int? ?? 1,
        ));
      }

      setState(() {
        _slots = loadedSlots;
        _warning = response['warning'] as String?;
        _connectedCount = response['connected_count'] as int? ?? 0;
        _totalParticipants = response['total_participants'] as int? ?? 0;
        _isLoading = false;
      });
    } catch (e) {
      // Fallback to mock data if API fails
      debugPrint('API failed, using mock data: $e');
      _loadMockSlots();
    }
  }

  void _loadMockSlots() {
    final now = DateTime.now();
    final mockSlots = <SuggestedSlot>[];

    for (int i = 1; i <= 7; i++) {
      final date = now.add(Duration(days: i));
      if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
        continue;
      }

      mockSlots.add(SuggestedSlot(
        id: 'slot_${i}_morning',
        startTime: DateTime(date.year, date.month, date.day, 8, 30),
        endTime: DateTime(date.year, date.month, date.day, 8, 30).add(Duration(minutes: widget.durationMinutes)),
        score: 100 - i * 10,
        availableCount: widget.participantEmails.length,
        totalCount: widget.participantEmails.length,
      ));

      mockSlots.add(SuggestedSlot(
        id: 'slot_${i}_afternoon',
        startTime: DateTime(date.year, date.month, date.day, 14, 0),
        endTime: DateTime(date.year, date.month, date.day, 14, 0).add(Duration(minutes: widget.durationMinutes)),
        score: 90 - i * 10,
        availableCount: widget.participantEmails.length,
        totalCount: widget.participantEmails.length,
      ));
    }

    mockSlots.sort((a, b) => b.score.compareTo(a.score));

    setState(() {
      _slots = mockSlots.take(8).toList();
      _isLoading = false;
    });
  }

  void _selectSlot(SuggestedSlot slot) {
    setState(() {
      _selectedSlot = slot;
      for (var s in _slots) {
        s.isSelected = s.id == slot.id;
      }
    });
  }

  Future<void> _confirmSelection() async {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn một khung giờ'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => const Center(child: CircularProgressIndicator()),
    );

    try {
      // Create event with selected slot - this will also create invitations for attendees
      final result = await MeetingService.createCalendarEvent(
        title: widget.eventTitle,
        startTime: _selectedSlot!.startTime.toIso8601String(),
        endTime: _selectedSlot!.endTime.toIso8601String(),
        attendees: widget.participantEmails,
      );

      // Close loading dialog
      if (mounted) Navigator.pop(context);

      // ApiService returns data directly when success (no 'success' wrapper)
      // Check if event_id exists to confirm success
      if ((result['event_id'] != null || result['data'] != null)) {
        // Pop all screens back to MainScreen (dashboard) first
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
        
        // Show top notification after navigation
        TopNotification.success(context, 'Đã tạo sự kiện và gửi lời mời thành công!');
      } else {
        TopNotification.error(context, 'Lỗi: ${result['message'] ?? 'Không thể tạo sự kiện'}');
      }
    } catch (e) {
      // Close loading dialog
      if (mounted) Navigator.pop(context);
      
      TopNotification.error(context, 'Lỗi: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Huỷ',
            style: TextStyle(
              color: _primaryColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        leadingWidth: 80,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: ElevatedButton(
              onPressed: _selectedSlot != null ? _confirmSelection : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey[300],
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
              child: const Text(
                'Thêm',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Padding(
            padding: EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Text(
              'Lịch phù hợp',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: _primaryColor,
                fontFamily: 'Lexend',
              ),
            ),
          ),

          // Event info
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Text(
              '${widget.eventTitle} • ${widget.durationMinutes} phút',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
                fontFamily: 'Lexend',
              ),
            ),
          ),

          // Date picker row
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: GestureDetector(
              onTap: _showDatePicker,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, color: _primaryColor, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          '${_selectedDate.day.toString().padLeft(2, '0')}/${_selectedDate.month.toString().padLeft(2, '0')}/${_selectedDate.year}',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Lexend',
                          ),
                        ),
                      ],
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
                  ],
                ),
              ),
            ),
          ),

          // Working hours toggle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(
                        _workingHoursOnly ? Icons.work_outline : Icons.schedule,
                        color: _primaryColor,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        _workingHoursOnly ? 'Giờ làm việc (8h-18h)' : 'Cả ngày (6h-23h)',
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ],
                  ),
                  Switch(
                    value: !_workingHoursOnly,
                    onChanged: (value) {
                      setState(() {
                        _workingHoursOnly = !value;
                        _selectedSlot = null;
                      });
                      _loadSuggestedSlots();
                    },
                    activeColor: _primaryColor,
                  ),
                ],
              ),
            ),
          ),

          // Connection status info
          if (_totalParticipants > 0)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Text(
                '$_connectedCount/$_totalParticipants người đã kết nối lịch',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[500],
                  fontFamily: 'Lexend',
                ),
              ),
            ),

          // Warning banner for disconnected users
          if (_warning != null && _warning!.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.orange[200]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber_rounded, color: Colors.orange[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _warning!,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.orange[900],
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: 8),

          // Slots list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _slots.isEmpty
                    ? _buildEmptyState()
                    : ScrollConfiguration(
                        behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
                        child: ListView.builder(
                          physics: const ClampingScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: _slots.length,
                          itemBuilder: (context, index) {
                            return _buildSlotCard(_slots[index]);
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
          const SizedBox(height: 16),
          Text(
            'Không tìm thấy khung giờ phù hợp',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontFamily: 'Lexend',
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Hãy thử mở rộng phạm vi tìm kiếm',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
              fontFamily: 'Lexend',
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSlotCard(SuggestedSlot slot) {
    final isSelected = slot.isSelected;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _selectSlot(slot),
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? _primaryColor : Colors.transparent,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              children: [
                // Calendar icon
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: _primaryColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.calendar_today,
                    color: _primaryColor,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),

                // Date and time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${slot.dayOfWeek} - ${slot.formattedDate}',
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Lexend',
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        slot.formattedTime,
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey[600],
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ],
                  ),
                ),

                // Checkmark
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isSelected 
                        ? const Color(0xFF10B981) 
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(12),
                    border: isSelected 
                        ? null 
                        : Border.all(
                            color: const Color(0xFF10B981).withValues(alpha: 0.5),
                            width: 2,
                          ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color: Colors.white,
                          size: 28,
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
