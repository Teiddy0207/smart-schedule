import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../constants/app_constants.dart';
import '../../services/calendar_service.dart';

class GroupUserBusyBottomSheet extends StatefulWidget {
  final String userId;
  final String userName;

  const GroupUserBusyBottomSheet({
    super.key,
    required this.userId,
    required this.userName,
  });

  @override
  State<GroupUserBusyBottomSheet> createState() => _GroupUserBusyBottomSheetState();
}

class _GroupUserBusyBottomSheetState extends State<GroupUserBusyBottomSheet> {
  DateTime _startTime = DateTime.now().toUtc();
  DateTime _endTime = DateTime.now().add(const Duration(days: 2)).toUtc();
  List<_BusySlot> _busy = [];
  bool _loading = false;
  String? _error;

  Future<void> _pickStartDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _startTime.toLocal(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_startTime.toLocal()),
    );
    if (time == null) return;
    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute).toUtc();
    setState(() {
      _startTime = dt;
      if (_endTime.isBefore(_startTime)) {
        _endTime = _startTime.add(const Duration(hours: 1));
      }
    });
  }

  Future<void> _pickEndDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _endTime.toLocal(),
      firstDate: DateTime.now().subtract(const Duration(days: 365)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_endTime.toLocal()),
    );
    if (time == null) return;
    final dt = DateTime(date.year, date.month, date.day, time.hour, time.minute).toUtc();
    setState(() {
      _endTime = dt.isAfter(_startTime) ? dt : _startTime.add(const Duration(hours: 1));
    });
  }

  Future<void> _loadBusy() async {
    setState(() {
      _loading = true;
      _error = null;
      _busy = [];
    });
    try {
      final res = await CalendarService.getUserBusy(
        userId: widget.userId,
        startTime: _startTime.toIso8601String(),
        endTime: _endTime.toIso8601String(),
      );
      final data = res['data'] as Map<String, dynamic>?;
      final List<_BusySlot> slots = [];
      if (data != null) {
        if (data['busy'] is List) {
          final list = (data['busy'] as List);
          for (final item in list) {
            if (item is Map<String, dynamic>) {
              final s = item['start']?.toString();
              final e = item['end']?.toString();
              if (s != null && e != null) {
                slots.add(_BusySlot(DateTime.parse(s), DateTime.parse(e)));
              }
            }
          }
        } else if (data['free_busy'] is Map) {
          final fb = data['free_busy'] as Map;
          final entry = fb[widget.userId];
          if (entry is Map && entry['busy'] is List) {
            final list = entry['busy'] as List;
            for (final item in list) {
              if (item is Map && item['start'] != null && item['end'] != null) {
                slots.add(_BusySlot(DateTime.parse(item['start'].toString()), DateTime.parse(item['end'].toString())));
              }
            }
          }
        }
      }
      setState(() {
        _busy = slots;
        _loading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString().replaceFirst('Exception: ', '');
        _loading = false;
      });
    }
  }

  String _fmt(DateTime dt) {
    return DateFormat('dd/MM/yyyy HH:mm').format(dt.toLocal());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Đóng',
                    style: TextStyle(
                      color: AppConstants.primaryColor,
                      fontSize: 16,
                    ),
                  ),
                ),
                Text(
                  'Lịch bận: ${widget.userName}',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'Lexend',
                  ),
                ),
                ElevatedButton(
                  onPressed: _loadBusy,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.primaryColor,
                    foregroundColor: Colors.white,
                    elevation: 0,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text(
                    'Tải lịch bận',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Column(
              children: [
                _RangeTile(
                  label: 'Bắt đầu',
                  value: _fmt(_startTime),
                  onTap: _pickStartDateTime,
                ),
                const SizedBox(height: 8),
                _RangeTile(
                  label: 'Kết thúc',
                  value: _fmt(_endTime),
                  onTap: _pickEndDateTime,
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _error != null
                    ? _ErrorState(error: _error!, onRetry: _loadBusy)
                    : _busy.isEmpty
                        ? _EmptyState()
                        : ListView.builder(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            itemCount: _busy.length,
                            itemBuilder: (context, index) {
                              final slot = _busy[index];
                              return Container(
                                margin: const EdgeInsets.only(bottom: 8),
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  gradient: AppConstants.appBarGradient,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Row(
                                  children: [
                                    const Icon(Icons.event_busy, color: Colors.white, size: 22),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            '${_fmt(slot.start)} - ${_fmt(slot.end)}',
                                            style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
    );
  }
}

class _RangeTile extends StatelessWidget {
  final String label;
  final String value;
  final VoidCallback onTap;

  const _RangeTile({
    required this.label,
    required this.value,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F6F8),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            const Icon(Icons.calendar_today, color: AppConstants.primaryColor, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$label: $value',
                style: TextStyle(
                  color: Colors.grey[700],
                  fontSize: 16,
                  fontFamily: 'Lexend',
                ),
              ),
            ),
            Icon(Icons.edit, size: 18, color: Colors.grey[500]),
          ],
        ),
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;

  const _ErrorState({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 12),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: onRetry,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppConstants.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Thử lại'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 48, color: Colors.grey[400]),
          const SizedBox(height: 12),
          Text(
            'Không có khoảng thời gian bận',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontFamily: 'Lexend',
            ),
          ),
        ],
      ),
    );
  }
}

class _BusySlot {
  final DateTime start;
  final DateTime end;
  _BusySlot(this.start, this.end);
}
