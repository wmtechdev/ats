import 'package:intl/intl.dart';

String appDateTimeFormatter(DateTime timestamp) {
  final datePart = DateFormat(
    'EEE MMM dd yyyy',
  ).format(timestamp); // Wed Jul 23 2025
  final timePart = DateFormat('h:mm a').format(timestamp); // 10:00 PM
  return '$datePart - $timePart';
}
