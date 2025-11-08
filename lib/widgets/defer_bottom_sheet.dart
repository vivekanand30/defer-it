import 'package:flutter/material.dart';
import 'package:getwidget/getwidget.dart';

import '../services/reminder_service.dart';

class DeferBottomSheet extends StatefulWidget {
  const DeferBottomSheet({
    super.key,
    this.initialTitle = '',
    this.initialContent = '',
    this.initialNotes = '',
    this.initialReminder,
    required this.onSubmit,
  });

  final String initialTitle;
  final String initialContent;
  final String initialNotes;
  final DateTime? initialReminder;
  final Future<void> Function(
    String title,
    String content,
    DateTime? remindAt,
    String notes,
  ) onSubmit;

  @override
  State<DeferBottomSheet> createState() => _DeferBottomSheetState();
}

class _DeferBottomSheetState extends State<DeferBottomSheet> {
  late TextEditingController titleController;
  late TextEditingController contentController;
  late TextEditingController notesController;
  DateTime? selectedReminder;

  @override
  void initState() {
    super.initState();
    titleController = TextEditingController(text: widget.initialTitle);
    contentController = TextEditingController(text: widget.initialContent);
    notesController = TextEditingController(text: widget.initialNotes);
    selectedReminder = widget.initialReminder;
  }

  @override
  void dispose() {
    titleController.dispose();
    contentController.dispose();
    notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
      initialDate: selectedReminder ?? now,
    );
    if (!mounted || date == null) return;
    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(selectedReminder ?? now),
    );
    if (!mounted || time == null) return;
    setState(() {
      selectedReminder = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  void _applyPreset(ReminderPreset preset) {
    setState(() {
      selectedReminder = ReminderService.computePreset(preset);
    });
  }

  @override
  Widget build(BuildContext context) {
    final reminderLabel = selectedReminder != null
        ? TimeOfDay.fromDateTime(selectedReminder!).format(context)
        : 'No reminder';
    return AnimatedPadding(
      duration: const Duration(milliseconds: 250),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Defer it',
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Content or link',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: notesController,
                minLines: 2,
                maxLines: 4,
                decoration: const InputDecoration(
                  labelText: 'Notes',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _PresetChip(
                    label: 'Tonight',
                    onPressed: () => _applyPreset(ReminderPreset.tonight),
                  ),
                  _PresetChip(
                    label: 'Tomorrow',
                    onPressed: () => _applyPreset(ReminderPreset.tomorrow),
                  ),
                  _PresetChip(
                    label: 'Weekend',
                    onPressed: () => _applyPreset(ReminderPreset.weekend),
                  ),
                  _PresetChip(
                    label: 'Pick date',
                    onPressed: _pickDate,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Text('Reminder: $reminderLabel'),
              const SizedBox(height: 16),
              GFButton(
                fullWidthButton: true,
                onPressed: () async {
                  await widget.onSubmit(
                    titleController.text.trim().isEmpty
                        ? 'Untitled'
                        : titleController.text.trim(),
                    contentController.text.trim(),
                    selectedReminder,
                    notesController.text.trim(),
                  );
                  if (mounted) Navigator.of(context).pop();
                },
                text: 'Save',
                color: Theme.of(context).colorScheme.primary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  const _PresetChip({required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GFButton(
      size: GFSize.SMALL,
      color: Theme.of(context).colorScheme.secondaryContainer,
      textColor: Theme.of(context).colorScheme.onSecondaryContainer,
      onPressed: onPressed,
      shape: GFButtonShape.pills,
      text: label,
    );
  }
}
