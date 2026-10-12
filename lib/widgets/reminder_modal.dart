import 'package:flutter/material.dart';
import '../models/reminder.dart';
import '../theme/app_theme.dart';

const _categories = ['medicine', 'exercise', 'hydration', 'vitals', 'general'];
const _repeatOptions = ['daily', 'weekdays', 'weekends', 'once'];

Future<void> showReminderModal({
  required BuildContext context,
  required Future<void> Function(Map<String, dynamic> data) onSave,
  Reminder? reminder,
  required int patientId,
}) {
  return showDialog(
    context: context,
    builder: (ctx) => ReminderModal(onSave: onSave, reminder: reminder, patientId: patientId),
  );
}

class ReminderModal extends StatefulWidget {
  final Future<void> Function(Map<String, dynamic> data) onSave;
  final Reminder? reminder;
  final int patientId;

  const ReminderModal({super.key, required this.onSave, this.reminder, required this.patientId});

  @override
  State<ReminderModal> createState() => _ReminderModalState();
}

class _ReminderModalState extends State<ReminderModal> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleController;
  late TextEditingController _audioPromptController;
  late String _category;
  late TimeOfDay _time;
  late String _repeatDays;
  late int _maxRetries;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final r = widget.reminder;
    _titleController = TextEditingController(text: r?.title ?? '');
    _audioPromptController =
        TextEditingController(text: r?.audioPrompt ?? 'Please take your scheduled medication with water.');
    _category = r?.category ?? 'medicine';
    _repeatDays = r?.repeatDays ?? 'daily';
    _maxRetries = r?.maxRetries ?? 3;
    if (r != null) {
      final parts = r.scheduledTime.split(':');
      _time = TimeOfDay(hour: int.tryParse(parts[0]) ?? 9, minute: int.tryParse(parts.length > 1 ? parts[1] : '0') ?? 0);
    } else {
      _time = const TimeOfDay(hour: 9, minute: 0);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _audioPromptController.dispose();
    super.dispose();
  }

  String get _formattedTime =>
      '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}';

  Future<void> _pickTime() async {
    final picked = await showTimePicker(context: context, initialTime: _time);
    if (picked != null) setState(() => _time = picked);
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    try {
      await widget.onSave(Reminder.buildJson(
        patientId: widget.patientId,
        title: _titleController.text.trim(),
        category: _category,
        scheduledTime: _formattedTime,
        repeatDays: _repeatDays,
        audioPrompt: _audioPromptController.text.trim(),
        maxRetries: _maxRetries,
        isActive: true,
      ));
      if (mounted) Navigator.of(context).pop();
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.reminder != null;
    return Dialog(
      backgroundColor: context.surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: context.borderColor)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isEdit ? 'Edit Voice Reminder' : 'Create New Voice Reminder',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.textPrimaryColor),
                      ),
                      IconButton(
                        onPressed: () => Navigator.of(context).pop(),
                        icon: Icon(Icons.close, size: 20, color: context.textSecondaryColor),
                      ),
                    ],
                  ),
                  Divider(color: context.borderColor),
                  const SizedBox(height: 8),
                  Text('REMINDER TITLE', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.textSecondaryColor)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _titleController,
                    style: TextStyle(fontSize: 13, color: context.textPrimaryColor),
                    decoration: const InputDecoration(hintText: 'e.g. Take Blood Pressure Medicine', isDense: true),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('CATEGORY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.textSecondaryColor)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: _category,
                              dropdownColor: context.surfaceColor,
                              style: TextStyle(fontSize: 13, color: context.textPrimaryColor),
                              decoration: const InputDecoration(isDense: true),
                              items: _categories
                                  .map((c) => DropdownMenuItem(value: c, child: Text(c[0].toUpperCase() + c.substring(1), style: TextStyle(color: context.textPrimaryColor))))
                                  .toList(),
                              onChanged: (v) => setState(() => _category = v ?? _category),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('SCHEDULED TIME', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.textSecondaryColor)),
                            const SizedBox(height: 6),
                            InkWell(
                              onTap: _pickTime,
                              child: InputDecorator(
                                decoration: const InputDecoration(isDense: true),
                                child: Text(_formattedTime, style: TextStyle(fontSize: 13, color: context.textPrimaryColor)),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('REPEAT FREQUENCY', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.textSecondaryColor)),
                            const SizedBox(height: 6),
                            DropdownButtonFormField<String>(
                              initialValue: _repeatDays,
                              dropdownColor: context.surfaceColor,
                              style: TextStyle(fontSize: 13, color: context.textPrimaryColor),
                              decoration: const InputDecoration(isDense: true),
                              items: _repeatOptions
                                  .map((c) => DropdownMenuItem(value: c, child: Text(c[0].toUpperCase() + c.substring(1), style: TextStyle(color: context.textPrimaryColor))))
                                  .toList(),
                              onChanged: (v) => setState(() => _repeatDays = v ?? _repeatDays),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('MAX RETRIES', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.textSecondaryColor)),
                            const SizedBox(height: 6),
                            TextFormField(
                              initialValue: _maxRetries.toString(),
                              keyboardType: TextInputType.number,
                              style: TextStyle(fontSize: 13, color: context.textPrimaryColor),
                              decoration: const InputDecoration(isDense: true),
                              onChanged: (v) => _maxRetries = int.tryParse(v) ?? _maxRetries,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Text('SPOKEN AUDIO TEXT (TTS PROMPT)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.textSecondaryColor)),
                  const SizedBox(height: 6),
                  TextFormField(
                    controller: _audioPromptController,
                    maxLines: 3,
                    style: TextStyle(fontSize: 13, color: context.textPrimaryColor),
                    decoration: const InputDecoration(hintText: 'Text spoken aloud by CareBot...', isDense: true),
                    validator: (v) => (v == null || v.trim().isEmpty) ? 'Required' : null,
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => Navigator.of(context).pop(),
                        child: Text('Cancel', style: TextStyle(fontSize: 12, color: context.textSecondaryColor)),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton.icon(
                        onPressed: _isSaving ? null : _handleSubmit,
                        icon: const Icon(Icons.save, size: 14),
                        label: Text(_isSaving ? 'Saving...' : 'Save Reminder', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
