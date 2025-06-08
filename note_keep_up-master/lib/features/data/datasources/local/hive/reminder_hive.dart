import 'package:hive/hive.dart';
part 'reminder_hive.g.dart';

@HiveType(typeId: 1)
class ReminderHive {
  @HiveField(0)
  DateTime reminderTime;

  @HiveField(1)
  int repeatType; // Lưu dưới dạng int nếu dùng enum

  ReminderHive({
    required this.reminderTime,
    required this.repeatType,
  }) {
    print(
        'DEBUG HIVE: ReminderHive tạo với reminderTime = $reminderTime, repeatType = $repeatType');
  }
}
