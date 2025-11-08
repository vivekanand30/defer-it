import 'package:intl/intl.dart';

/// Domain model representing a captured piece of content the user wants to revisit.
class DeferredItemModel {
  DeferredItemModel({
    required this.id,
    required this.title,
    required this.content,
    required this.type,
    required this.remindAt,
    required this.isDone,
    this.notes,
  });

  final int id;
  final String title;
  final String content;
  final String type;
  final DateTime? remindAt;
  final bool isDone;
  final String? notes;

  /// Friendly formatted reminder string for UI widgets.
  String get remindAtLabel {
    if (remindAt == null) {
      return 'No reminder';
    }
    final now = DateTime.now();
    final formatter = remindAt!.day == now.day
        ? DateFormat.jm()
        : DateFormat.yMMMd().add_jm();
    return formatter.format(remindAt!.toLocal());
  }
}
