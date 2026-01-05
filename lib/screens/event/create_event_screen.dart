import 'package:flutter/material.dart';
import '../../widgets/user_search_widget.dart';
import '../../services/user_search_service.dart';
import '../../services/api_service.dart';
import 'suggested_slots_screen.dart';

class CreateEventScreen extends StatefulWidget {
  const CreateEventScreen({super.key});

  @override
  State<CreateEventScreen> createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _locationController = TextEditingController();
  final _groupController = TextEditingController();
  final _urlController = TextEditingController();
  final _notesController = TextEditingController();

  // Selected participants
  List<UserSearchResult> _selectedParticipants = [];

  // Primary color - đồng bộ với app
  static const _primaryColor = Color(0xFF6C63FF);
  static const _primaryDark = Color(0xFF5B54E8);

  String _selectedDuration = '30 phút';
  String _selectedPriority = 'Không ưu tiên';

  final List<String> _durationOptions = [
    '30 phút',
    '1 giờ',
    '1.5 giờ',
    '2 giờ',
    '3 giờ',
  ];

  final List<String> _priorityOptions = [
    'Không ưu tiên',
    'Sáng',
    'Chiều',
    'Tối',
  ];

  final Map<String, bool> _timeOptions = {
    'Giờ hành chính': false,
    'Cuối tuần': false,
  };

  // Date/Time for events without participants
  DateTime? _selectedDate;
  TimeOfDay? _selectedStartTime;
  TimeOfDay? _selectedEndTime;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _groupController.dispose();
    _urlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black54, size: 28),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tạo sự kiện',
          style: TextStyle(
            color: Colors.black87,
            fontSize: 20,
            fontWeight: FontWeight.bold,
            fontFamily: 'Lexend',
          ),
        ),
        centerTitle: true,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 12),
            child: ElevatedButton.icon(
              onPressed: _handleSuggestSchedule,
              icon: const Icon(Icons.auto_awesome, size: 18),
              label: const Text(
                'Đề xuất',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: _primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Scrollable content
          Expanded(
            child: ScrollConfiguration(
              behavior: ScrollConfiguration.of(context).copyWith(overscroll: false),
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildFormCard(),
                      const SizedBox(height: 16),
                      _buildTimeOptionsCard(),
                      const SizedBox(height: 16),
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Fixed footer buttons
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: _buildFooterButtons(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          _buildTextField(
            controller: _titleController,
            label: 'Tiêu đề cuộc họp',
            hintText: 'Nhập tiêu đề...',
            prefixIcon: Icons.title,
            isRequired: true,
          ),
          const SizedBox(height: 20),

          // Location
          _buildTextField(
            controller: _locationController,
            label: 'Địa điểm',
            hintText: 'Online hoặc địa chỉ...',
            prefixIcon: Icons.location_on_outlined,
          ),
          const SizedBox(height: 20),

          // Duration and Priority row - FIX OVERFLOW
          Row(
            children: [
              Expanded(
                child: _buildDropdownField(
                  label: 'Thời lượng',
                  value: _selectedDuration,
                  items: _durationOptions,
                  icon: Icons.schedule,
                  onChanged: (value) {
                    setState(() => _selectedDuration = value!);
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildDropdownField(
                  label: 'Ưu tiên',
                  value: _selectedPriority,
                  items: _priorityOptions,
                  icon: Icons.priority_high,
                  onChanged: (value) {
                    setState(() => _selectedPriority = value!);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Participants section
          const Text(
            'Người tham dự',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
              fontFamily: 'Lexend',
            ),
          ),
          const SizedBox(height: 12),

          // Group
          _buildTextField(
            controller: _groupController,
            hintText: 'Chọn nhóm...',
            prefixIcon: Icons.group_outlined,
          ),
          const SizedBox(height: 12),

          // Person - User Search Widget
          UserSearchWidget(
            selectedUsers: _selectedParticipants,
            onChanged: (users) {
              setState(() => _selectedParticipants = users);
            },
            hintText: 'Tìm kiếm người tham dự...',
          ),
          const SizedBox(height: 20),

          // Date/Time section - only show when no participants
          if (_selectedParticipants.isEmpty) ...[
            const Text(
              'Thời gian sự kiện',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
                fontFamily: 'Lexend',
              ),
            ),
            const SizedBox(height: 12),
            _buildDateTimePickers(),
            const SizedBox(height: 20),
          ],

          // Hint for Smart Scheduler when has participants
          if (_selectedParticipants.isNotEmpty) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: _primaryColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: _primaryColor.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.auto_awesome, color: _primaryColor, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Bấm "Đề xuất" để tìm thời gian phù hợp với ${_selectedParticipants.length} người tham dự',
                      style: TextStyle(
                        color: _primaryColor,
                        fontSize: 13,
                        fontFamily: 'Lexend',
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],

          // URL
          _buildTextField(
            controller: _urlController,
            label: 'Link cuộc họp',
            hintText: 'Google Meet, Zoom...',
            prefixIcon: Icons.link,
          ),
          const SizedBox(height: 20),

          // Notes
          _buildTextField(
            controller: _notesController,
            label: 'Ghi chú',
            hintText: 'Thêm mô tả hoặc ghi chú...',
            prefixIcon: Icons.note_outlined,
            maxLines: 3,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    String? label,
    required String hintText,
    IconData? prefixIcon,
    int maxLines = 1,
    bool isRequired = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (label != null) ...[
          Row(
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                  fontFamily: 'Lexend',
                ),
              ),
              if (isRequired)
                const Text(
                  ' *',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
            ],
          ),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: const TextStyle(
            fontSize: 16,
            fontFamily: 'Lexend',
          ),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: TextStyle(
              color: Colors.grey[400],
              fontSize: 16,
              fontFamily: 'Lexend',
            ),
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: _primaryColor, size: 22)
                : null,
            filled: true,
            fillColor: const Color(0xFFF5F6F8),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _primaryColor, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
          validator: isRequired
              ? (value) {
                  if (value == null || value.isEmpty) {
                    return 'Vui lòng nhập $label';
                  }
                  return null;
                }
              : null,
        ),
      ],
    );
  }

  Widget _buildDropdownField({
    required String label,
    required String value,
    required List<String> items,
    required IconData icon,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
            fontFamily: 'Lexend',
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF5F6F8),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            isExpanded: true, // FIX OVERFLOW
            icon: Icon(Icons.keyboard_arrow_down, color: Colors.grey[600]),
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              fontFamily: 'Lexend',
            ),
            decoration: InputDecoration(
              prefixIcon: Icon(icon, color: _primaryColor, size: 20),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 12,
              ),
            ),
            dropdownColor: Colors.white,
            borderRadius: BorderRadius.circular(12),
            items: items.map((item) {
              return DropdownMenuItem<String>(
                value: item,
                child: Text(
                  item,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 15),
                ),
              );
            }).toList(),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildDateTimePickers() {
    return Column(
      children: [
        // Date picker
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: _selectedDate ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime.now().add(const Duration(days: 365)),
              builder: (context, child) {
                return Theme(
                  data: Theme.of(context).copyWith(
                    colorScheme: const ColorScheme.light(
                      primary: _primaryColor,
                    ),
                  ),
                  child: child!,
                );
              },
            );
            if (date != null) {
              setState(() => _selectedDate = date);
            }
          },
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F6F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today, color: _primaryColor, size: 22),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Chọn ngày...',
                    style: TextStyle(
                      color: _selectedDate != null ? Colors.black87 : Colors.grey[400],
                      fontSize: 16,
                      fontFamily: 'Lexend',
                    ),
                  ),
                ),
                Icon(Icons.arrow_drop_down, color: Colors.grey[600]),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),

        // Time pickers row
        Row(
          children: [
            // Start time
            Expanded(
              child: InkWell(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _selectedStartTime ?? TimeOfDay.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: _primaryColor,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (time != null) {
                    setState(() {
                      _selectedStartTime = time;
                      // Auto set end time based on duration
                      if (_selectedEndTime == null) {
                        int durationMinutes = 60;
                        if (_selectedDuration.contains('30')) durationMinutes = 30;
                        else if (_selectedDuration.contains('1.5')) durationMinutes = 90;
                        else if (_selectedDuration.contains('2')) durationMinutes = 120;
                        else if (_selectedDuration.contains('3')) durationMinutes = 180;
                        
                        final endMinutes = time.hour * 60 + time.minute + durationMinutes;
                        _selectedEndTime = TimeOfDay(
                          hour: (endMinutes ~/ 60) % 24,
                          minute: endMinutes % 60,
                        );
                      }
                    });
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time, color: _primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _selectedStartTime != null
                            ? '${_selectedStartTime!.hour.toString().padLeft(2, '0')}:${_selectedStartTime!.minute.toString().padLeft(2, '0')}'
                            : 'Bắt đầu',
                        style: TextStyle(
                          color: _selectedStartTime != null ? Colors.black87 : Colors.grey[400],
                          fontSize: 15,
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.arrow_forward, color: Colors.grey, size: 20),
            ),
            // End time
            Expanded(
              child: InkWell(
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: _selectedEndTime ?? TimeOfDay.now(),
                    builder: (context, child) {
                      return Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.light(
                            primary: _primaryColor,
                          ),
                        ),
                        child: child!,
                      );
                    },
                  );
                  if (time != null) {
                    setState(() => _selectedEndTime = time);
                  }
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F6F8),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.access_time_filled, color: _primaryColor, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        _selectedEndTime != null
                            ? '${_selectedEndTime!.hour.toString().padLeft(2, '0')}:${_selectedEndTime!.minute.toString().padLeft(2, '0')}'
                            : 'Kết thúc',
                        style: TextStyle(
                          color: _selectedEndTime != null ? Colors.black87 : Colors.grey[400],
                          fontSize: 15,
                          fontFamily: 'Lexend',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildTimeOptionsCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.access_time, color: _primaryColor, size: 22),
              SizedBox(width: 8),
              Text(
                'Ràng buộc thời gian',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Lexend',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: _timeOptions.entries.map((entry) {
              final isSelected = entry.value;
              return FilterChip(
                label: Text(
                  entry.key,
                  style: TextStyle(
                    color: isSelected ? Colors.white : Colors.black87,
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                selected: isSelected,
                onSelected: (value) {
                  setState(() {
                    _timeOptions[entry.key] = value;
                  });
                },
                backgroundColor: const Color(0xFFF5F6F8),
                selectedColor: _primaryColor,
                checkmarkColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildFooterButtons() {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => Navigator.pop(context),
            style: OutlinedButton.styleFrom(
              foregroundColor: _primaryColor,
              side: const BorderSide(color: _primaryColor, width: 2),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Huỷ',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                fontFamily: 'Lexend',
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          flex: 2,
          child: ElevatedButton(
            onPressed: _handleAddEvent,
            style: ElevatedButton.styleFrom(
              backgroundColor: _primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Tạo sự kiện',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.w600,
                fontFamily: 'Lexend',
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleSuggestSchedule() async {
    if (_titleController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Vui lòng nhập tiêu đề cuộc họp'),
          backgroundColor: Colors.orange,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(
            bottom: MediaQuery.of(context).size.height - 250,
            left: 16,
            right: 16,
          ),
        ),
      );
      return;
    }

    // Parse duration to minutes
    int durationMinutes = 60;
    if (_selectedDuration.contains('30')) {
      durationMinutes = 30;
    } else if (_selectedDuration.contains('1.5')) {
      durationMinutes = 90;
    } else if (_selectedDuration.contains('2')) {
      durationMinutes = 120;
    } else if (_selectedDuration.contains('3')) {
      durationMinutes = 180;
    }

    // Navigate to suggested slots screen
    final selectedSlot = await Navigator.push<SuggestedSlot>(
      context,
      MaterialPageRoute(
        builder: (context) => SuggestedSlotsScreen(
          eventTitle: _titleController.text,
          durationMinutes: durationMinutes,
          participantEmails: _selectedParticipants.map((p) => p.email).toList(),
        ),
      ),
    );

    // Handle returned slot
    if (selectedSlot != null && mounted) {
      // Call API to create event with selected slot
      try {
        final eventData = {
          'title': _titleController.text,
          'description': _notesController.text,
          'address': _locationController.text,
          'start_date': selectedSlot.startTime.toUtc().toIso8601String(),
          'end_date': selectedSlot.endTime.toUtc().toIso8601String(),
          'meeting_link': _urlController.text,
        };

        debugPrint('Creating event with slot: $eventData');

        final response = await ApiService.post(
          '/api/v1/private/events/personal',
          body: eventData,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Đã tạo sự kiện: ${selectedSlot.dayOfWeek} ${selectedSlot.formattedDate} ${selectedSlot.formattedTime}'),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height - 250,
                left: 16,
                right: 16,
              ),
            ),
          );
          Navigator.pop(context); // Close create event screen
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi: ${e.toString().replaceFirst("Exception: ", "")}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height - 250,
                left: 16,
                right: 16,
              ),
            ),
          );
        }
      }
    }
  }

  void _handleAddEvent() async {
    if (_formKey.currentState!.validate()) {
      // Two-flow logic
      if (_selectedParticipants.isEmpty) {
        // Flow 1: No participants - require date/time
        if (_selectedDate == null || _selectedStartTime == null || _selectedEndTime == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Vui lòng chọn ngày và giờ cho sự kiện'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height - 250,
                left: 16,
                right: 16,
              ),
            ),
          );
          return;
        }

        // Create DateTime from selected values
        final startDateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedStartTime!.hour,
          _selectedStartTime!.minute,
        );
        final endDateTime = DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedEndTime!.hour,
          _selectedEndTime!.minute,
        );

        // Validate end time is after start time
        if (endDateTime.isBefore(startDateTime) || endDateTime.isAtSameMomentAs(startDateTime)) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Thời gian kết thúc phải sau thời gian bắt đầu'),
              backgroundColor: Colors.orange,
              behavior: SnackBarBehavior.floating,
              margin: EdgeInsets.only(
                bottom: MediaQuery.of(context).size.height - 250,
                left: 16,
                right: 16,
              ),
            ),
          );
          return;
        }

        // Collect event data with specific time
        final eventData = {
          'title': _titleController.text,
          'description': _notesController.text,
          'address': _locationController.text,
          'start_date': startDateTime.toUtc().toIso8601String(),
          'end_date': endDateTime.toUtc().toIso8601String(),
          'meeting_link': _urlController.text,
        };

        debugPrint('=== Creating Personal Event ===');
        debugPrint('eventData: $eventData');

        // Call API to create personal event
        try {
          final response = await ApiService.post(
            '/api/v1/private/events/personal',
            body: eventData,
          );

          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Sự kiện đã được tạo thành công!'),
                backgroundColor: Colors.green,
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height - 250,
                  left: 16,
                  right: 16,
                ),
              ),
            );
            Navigator.pop(context);
          }
        } catch (e) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi: ${e.toString().replaceFirst("Exception: ", "")}'),
                backgroundColor: Colors.red,
                behavior: SnackBarBehavior.floating,
                margin: EdgeInsets.only(
                  bottom: MediaQuery.of(context).size.height - 250,
                  left: 16,
                  right: 16,
                ),
              ),
            );
          }
        }
      } else {
        // Flow 2: Has participants - redirect to Smart Scheduler
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Bấm nút "Đề xuất" để tìm thời gian phù hợp với ${_selectedParticipants.length} người tham dự'),
            backgroundColor: _primaryColor,
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height - 250,
              left: 16,
              right: 16,
            ),
          ),
        );
      }
    }
  }
}
