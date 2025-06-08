import 'package:flutter/material.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../domain/entities/reminder.dart';

class ReminderDialog extends StatefulWidget {
  final Reminder? reminder;
  final Function(DateTime, RepeatType) onSave;

  const ReminderDialog({
    Key? key,
    this.reminder,
    required this.onSave,
  }) : super(key: key);

  @override
  State<ReminderDialog> createState() => _ReminderDialogState();
}

class _ReminderDialogState extends State<ReminderDialog> {
  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;
  RepeatType _repeatType = RepeatType.none;
  CalendarFormat _calendarFormat = CalendarFormat.month;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.reminder?.reminderTime ?? DateTime.now();
    _selectedTime =
        TimeOfDay.fromDateTime(widget.reminder?.reminderTime ?? DateTime.now());
    _repeatType = widget.reminder?.repeatType ?? RepeatType.none;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TableCalendar(
              firstDay: DateTime.now(),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _selectedDate,
              selectedDayPredicate: (day) => isSameDay(_selectedDate, day),
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDate = selectedDay;
                });
              },
              calendarFormat: _calendarFormat,
              onFormatChanged: (format) {
                setState(() {
                  _calendarFormat = format;
                });
              },
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('Time'),
              trailing: Text(_selectedTime.format(context)),
              onTap: _selectTime,
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<RepeatType>(
              value: _repeatType,
              decoration: const InputDecoration(
                labelText: 'Repeat',
                border: OutlineInputBorder(),
              ),
              items: RepeatType.values.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type.name.toUpperCase()),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _repeatType = value!;
                });
              },
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('CANCEL'),
                ),
                TextButton(
                  onPressed: _saveReminder,
                  child: const Text('SAVE'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectTime() async {
    final TimeOfDay? time = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
    );
    if (time != null) {
      setState(() {
        _selectedTime = time;
      });
    }
  }

  void _saveReminder() {
    final DateTime reminderTime = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
    if (reminderTime.isAfter(DateTime.now().add(const Duration(seconds: 2)))) {
      widget.onSave(reminderTime, _repeatType);
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Thời gian nhắc hẹn phải ở tương lai!')),
      );
    }
  }
}
