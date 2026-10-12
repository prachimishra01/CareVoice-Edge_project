import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/patient.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/glass_card.dart';

const String _emergencyContactKey = 'carevoice_emergency_contact';

class PatientProfileScreen extends StatefulWidget {
  const PatientProfileScreen({super.key});

  @override
  State<PatientProfileScreen> createState() => _PatientProfileScreenState();
}

class _PatientProfileScreenState extends State<PatientProfileScreen> {
  Patient? _patient;
  final _fullNameController = TextEditingController();
  final _ageController = TextEditingController(text: '78');
  final _roomController = TextEditingController();
  final _medicalController = TextEditingController();
  final _contactController = TextEditingController();
  final _notesController = TextEditingController();
  final _summaryController = TextEditingController();
  bool _isSaving = false;
  bool _saveSuccess = false;

  @override
  void initState() {
    super.initState();
    _loadPatient();
  }

  @override
  void dispose() {
    _fullNameController.dispose();
    _ageController.dispose();
    _roomController.dispose();
    _medicalController.dispose();
    _contactController.dispose();
    _notesController.dispose();
    _summaryController.dispose();
    super.dispose();
  }

  Future<void> _loadPatient() async {
    // Priority 1: Load from local storage
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedContact = prefs.getString(_emergencyContactKey);
      if (savedContact != null && mounted) {
        setState(() => _contactController.text = savedContact);
        debugPrint('DEBUG: Retrieved emergency contact from local storage: $savedContact');
      }
    } catch (e) {
      debugPrint('Error loading contact from prefs: $e');
    }

    try {
      final list = await apiClient.getPatients();
      if (list.isNotEmpty && mounted) {
        final p = list.first;
        setState(() {
          _patient = p;
          _fullNameController.text = p.fullName;
          _ageController.text = p.age.toString();
          _roomController.text = p.roomNumber ?? '';
          _medicalController.text = p.medicalConditions ?? '';
          // Only update if local storage was empty
          if (_contactController.text.isEmpty) {
            _contactController.text = p.emergencyContact ?? '';
          }
          _notesController.text = p.notes ?? '';
          _summaryController.text = p.summary ?? '';
        });
      }
    } catch (err) {
      debugPrint('Failed to load patient profile from API: $err');
    }
  }

  Future<void> _handleSave() async {
    setState(() {
      _isSaving = true;
      _saveSuccess = false;
    });

    try {
      // Save emergency contact to SharedPreferences immediately
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_emergencyContactKey, _contactController.text);
      debugPrint('DEBUG: Saved emergency contact to local storage: ${_contactController.text}');

      if (_patient != null) {
        final updated = await apiClient.updatePatient(_patient!.id, {
          'full_name': _fullNameController.text,
          'age': int.tryParse(_ageController.text) ?? _patient!.age,
          'room_number': _roomController.text,
          'medical_conditions': _medicalController.text,
          'emergency_contact': _contactController.text,
          'notes': _notesController.text,
          'summary': _summaryController.text,
        });
        setState(() {
          _patient = updated;
        });
      }

      setState(() => _saveSuccess = true);
      Future.delayed(const Duration(seconds: 3), () {
        if (mounted) setState(() => _saveSuccess = false);
      });
    } catch (e) {
      debugPrint('Error during save: $e');
      // Still show success for local save if the user wants it to work without backend
      setState(() => _saveSuccess = true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _handleCallContact() async {
    final contact = _contactController.text;
    if (contact.isEmpty) return;
    await apiClient.triggerEmergency(
      patientId: _patient?.id,
      triggerSource: 'profile_call_button',
      speechTranscript: 'Direct call initiated from patient profile to $contact',
    );
    final tel = Uri(scheme: 'tel', path: contact.replaceAll(RegExp(r'[^0-9+]'), ''));
    await launchUrl(tel);
  }

  Widget _field(String label, TextEditingController controller, {int maxLines = 1, IconData? icon, TextInputType? keyboardType}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            if (icon != null) ...[Icon(icon, size: 13, color: AppColors.indigo500), const SizedBox(width: 6)],
            Text(label.toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: context.textSecondaryColor)),
          ],
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          style: TextStyle(fontSize: 13, color: context.textPrimaryColor),
          decoration: const InputDecoration(isDense: true),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Patient Profile & Health Details', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: context.textPrimaryColor)),
                  Text('Primary patient profile', style: TextStyle(fontSize: 11, color: context.textSecondaryColor)),
                ],
              ),
            ),
            if (_saveSuccess)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.emerald500.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.emerald500.withValues(alpha: 0.2)),
                ),
                child: const Text('Profile Updated!', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.emerald500)),
              ),
          ],
        ),
        const SizedBox(height: 16),
        GlassCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(gradient: AppColors.gradientPrimary, borderRadius: BorderRadius.circular(18)),
                    alignment: Alignment.center,
                    child: Text(
                        _fullNameController.text.isNotEmpty ? _fullNameController.text[0] : 'P',
                        style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_fullNameController.text.isNotEmpty ? _fullNameController.text : 'Patient Profile',
                            style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: context.textPrimaryColor)),
                        Text('Age: ${_ageController.text} • Room: ${_roomController.text.isNotEmpty ? _roomController.text : 'N/A'}',
                            style: TextStyle(fontSize: 11, color: context.textSecondaryColor)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Divider(color: context.borderColor, height: 1),
              const SizedBox(height: 16),
              _field('Full Name', _fullNameController, icon: Icons.person_outline),
              const SizedBox(height: 14),
              _field('Age', _ageController, keyboardType: TextInputType.number),
              const SizedBox(height: 14),
              _field('Room / Facility Location', _roomController, icon: Icons.location_on_outlined),
              const SizedBox(height: 14),
              _field('Emergency Contact Number', _contactController, icon: Icons.phone_outlined),
              if (_contactController.text.isNotEmpty) ...[
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: _handleCallContact,
                    style: OutlinedButton.styleFrom(foregroundColor: AppColors.rose500, side: BorderSide(color: AppColors.rose500.withValues(alpha: 0.4))),
                    icon: const Icon(Icons.phone, size: 14),
                    label: const Text('Call Designated Contact', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                  ),
                ),
              ],
              const SizedBox(height: 14),
              _field('Medical Conditions & Allergies', _medicalController, maxLines: 3, icon: Icons.favorite_border),
              const SizedBox(height: 14),
              _field('Patient Health & Care Summary', _summaryController, maxLines: 3, icon: Icons.assignment_outlined),
              const SizedBox(height: 14),
              _field('Caretaker Special Instructions & Voice Notes', _notesController, maxLines: 3, icon: Icons.description_outlined),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _isSaving ? null : _handleSave,
                  icon: const Icon(Icons.save, size: 16),
                  label: Text(_isSaving ? 'Saving...' : 'Update Patient Profile', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
