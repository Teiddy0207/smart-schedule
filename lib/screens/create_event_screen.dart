import 'package:flutter/material.dart';

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
  final _personController = TextEditingController();
  final _urlController = TextEditingController();
  final _notesController = TextEditingController();

  String _selectedDuration = '0.5 giờ';
  String _selectedPriority = 'Sáng';

  final Map<String, bool> _timeOptions = {
    'Sáng': false,
    'Chiều': false,
    'Tối': false,
    'Cuối tuần': false,
    'Giờ hành chính': false,
  };

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _groupController.dispose();
    _personController.dispose();
    _urlController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Huỷ',
            style: TextStyle(
              color: Color(0xFF7C3AED),
              fontSize: 16,
            ),
          ),
        ),
        title: const Text(
          'Tạo sự kiện',
          style: TextStyle(
            color: Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Implement suggest schedule
            },
            child: const Text(
              'Đề xuất lịch',
              style: TextStyle(
                color: Color(0xFF7C3AED),
                fontSize: 16,
              ),
            ),
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Nếu màn hình rộng (tablet/desktop) thì dùng Row
          if (constraints.maxWidth > 600) {
            return Row(
              children: [
                // Main form area (left)
                Expanded(
                  flex: 2,
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          _buildFormCard(),
                          const SizedBox(height: 16),
                          _buildFooterButtons(),
                        ],
                      ),
                    ),
                  ),
                ),
                // Side panel (right)
                Expanded(
                  child: _buildTimeOptionsPanel(),
                ),
              ],
            );
          } else {
            // Mobile: dùng Column (stack vertically)
            return SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildFormCard(),
                    const SizedBox(height: 16),
                    const SizedBox(height: 16),
                    _buildFooterButtons(),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }

  Widget _buildFormCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Title
          _buildTextField(
            controller: _titleController,
            hintText: 'Tiêu đề',
          ),
          const SizedBox(height: 16),
          // Location
          _buildTextField(
            controller: _locationController,
            hintText: 'Vị trí',
          ),
          const SizedBox(height: 24),
          // Duration and Priority row
          Row(
            children: [
              Expanded(
                child: _buildDropdown(
                  label: 'Thời lượng',
                  value: _selectedDuration,
                  items: const ['0.5 giờ', '1 giờ', '1.5 giờ', '2 giờ', '3 giờ'],
                  onChanged: (value) {
                    setState(() {
                      _selectedDuration = value!;
                    });
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildDropdown(
                  label: 'Ưu tiên',
                  value: _selectedPriority,
                  items: const ['Sáng', 'Chiều', 'Tối', 'Không ưu tiên'],
                  onChanged: (value) {
                    setState(() {
                      _selectedPriority = value!;
                    });
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Invited group
          _buildTextField(
            controller: _groupController,
            hintText: 'Nhóm được mời',
          ),
          const SizedBox(height: 16),
          // Invited person
          _buildTextField(
            controller: _personController,
            hintText: 'Người được mời',
          ),
          const SizedBox(height: 24),
          // URL
          _buildTextField(
            controller: _urlController,
            hintText: 'URL',
          ),
          const SizedBox(height: 16),
          // Notes
          _buildTextField(
            controller: _notesController,
            hintText: 'Ghi chú',
            maxLines: 4,
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hintText,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(
            color: Color(0xFF7C3AED),
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
      ),
    );
  }

  Widget _buildDropdown({
    required String label,
    required String value,
    required List<String> items,
    required Function(String?) onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xFF7C3AED),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(item),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }

  Widget _buildTimeOptionsPanel() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            'Thời gian',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ..._timeOptions.entries.map((entry) {
            return CheckboxListTile(
              title: Text(entry.key),
              value: entry.value,
              onChanged: (value) {
                setState(() {
                  _timeOptions[entry.key] = value ?? false;
                });
              },
              activeColor: const Color(0xFF7C3AED),
              contentPadding: EdgeInsets.zero,
            );
          }).toList(),
        ],
      ),
    );
  }

  Widget _buildFooterButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Huỷ',
            style: TextStyle(
              color: Color(0xFF7C3AED),
              fontSize: 16,
            ),
          ),
        ),
        const SizedBox(width: 16),
        ElevatedButton(
          onPressed: _handleAddEvent,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF7C3AED),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(
              horizontal: 32,
              vertical: 12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          child: const Text(
            'Thêm',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  void _handleAddEvent() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implement add event logic
      // Save event data
      final eventData = {
        'title': _titleController.text,
        'location': _locationController.text,
        'duration': _selectedDuration,
        'priority': _selectedPriority,
        'group': _groupController.text,
        'person': _personController.text,
        'url': _urlController.text,
        'notes': _notesController.text,
        'timeOptions': _timeOptions,
      };

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sự kiện đã được thêm thành công!'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate back
      Navigator.pop(context);
    }
  }
}

