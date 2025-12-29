import 'package:flutter/material.dart';

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

  const SuggestedSlotsScreen({
    super.key,
    required this.eventTitle,
    required this.durationMinutes,
    required this.participantEmails,
  });

  @override
  State<SuggestedSlotsScreen> createState() => _SuggestedSlotsScreenState();
}

class _SuggestedSlotsScreenState extends State<SuggestedSlotsScreen> {
  static const _primaryColor = Color(0xFF6C63FF);
  
  List<SuggestedSlot> _slots = [];
  bool _isLoading = true;
  SuggestedSlot? _selectedSlot;

  @override
  void initState() {
    super.initState();
    _loadSuggestedSlots();
  }

  Future<void> _loadSuggestedSlots() async {
    setState(() => _isLoading = true);

    // TODO: Call backend API to get suggested slots
    // For now, generate mock data
    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();
    final mockSlots = <SuggestedSlot>[];

    // Generate slots for next 7 days
    for (int i = 1; i <= 7; i++) {
      final date = now.add(Duration(days: i));
      
      // Skip weekends if preference set
      if (date.weekday == DateTime.saturday || date.weekday == DateTime.sunday) {
        continue;
      }

      // Add morning slot
      mockSlots.add(SuggestedSlot(
        id: 'slot_${i}_morning',
        startTime: DateTime(date.year, date.month, date.day, 8, 30),
        endTime: DateTime(date.year, date.month, date.day, 9, 30),
        score: 100 - i * 10,
        availableCount: widget.participantEmails.length,
        totalCount: widget.participantEmails.length,
      ));

      // Add afternoon slot
      mockSlots.add(SuggestedSlot(
        id: 'slot_${i}_afternoon',
        startTime: DateTime(date.year, date.month, date.day, 14, 0),
        endTime: DateTime(date.year, date.month, date.day, 15, 0),
        score: 90 - i * 10,
        availableCount: widget.participantEmails.length,
        totalCount: widget.participantEmails.length,
      ));
    }

    // Sort by score
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

  void _confirmSelection() {
    if (_selectedSlot == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng chọn một khung giờ'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Return selected slot to previous screen
    Navigator.pop(context, _selectedSlot);
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

          const SizedBox(height: 20),

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
