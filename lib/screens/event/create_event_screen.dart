import 'package:flutter/material.dart';
import '../../widgets/user_search_widget.dart';
import '../../services/user_search_service.dart';
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
        const SnackBar(
          content: Text('Vui lòng nhập tiêu đề cuộc họp'),
          backgroundColor: Colors.orange,
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã chọn: ${selectedSlot.dayOfWeek} ${selectedSlot.formattedDate} ${selectedSlot.formattedTime}'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  void _handleAddEvent() {
    if (_formKey.currentState!.validate()) {
      // Collect event data
      final eventData = {
        'title': _titleController.text,
        'location': _locationController.text,
        'duration': _selectedDuration,
        'priority': _selectedPriority,
        'group': _groupController.text,
        'participants': _selectedParticipants.map((u) => u.email).toList(),
        'participant_ids': _selectedParticipants.map((u) => u.id).toList(),
        'url': _urlController.text,
        'notes': _notesController.text,
        'timeOptions': _timeOptions,
      };

      // TODO: Call API to create event
      debugPrint('Creating event: $eventData');

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sự kiện đã được tạo thành công!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.pop(context);
    }
  }
}
