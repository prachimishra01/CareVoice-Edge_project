import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/patient.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class PatientSummaryWidget extends StatefulWidget {
  final Patient? patient;
  final VoidCallback? onEditProfile;

  const PatientSummaryWidget({super.key, required this.patient, this.onEditProfile});

  @override
  State<PatientSummaryWidget> createState() => _PatientSummaryWidgetState();
}

class _PatientSummaryWidgetState extends State<PatientSummaryWidget> {
  bool _isCalling = false;
  bool _callSuccess = false;

  Future<void> _handleCallContact() async {
    final contact = widget.patient?.emergencyContact?.trim();
    if (contact == null || contact.isEmpty) return;

    setState(() {
      _isCalling = true;
      _callSuccess = false;
    });

    try {
      await apiClient.triggerEmergency(
        patientId: widget.patient!.id,
        triggerSource: 'dashboard_call_button',
        speechTranscript: 'Direct call initiated by Caretaker to $contact',
      );
      final tel = Uri(scheme: 'tel', path: contact.replaceAll(RegExp(r'[^0-9+]'), ''));
      await launchUrl(tel);
      setState(() => _callSuccess = true);
      Future.delayed(const Duration(seconds: 4), () {
        if (mounted) setState(() => _callSuccess = false);
      });
    } catch (err) {
      debugPrint('Call dispatch error: $err');
    } finally {
      if (mounted) setState(() => _isCalling = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final patient = widget.patient;
    if (patient == null) {
      return GlassCard(
        child: Center(child: Text('Loading patient profile summary...', style: TextStyle(fontSize: 13, color: context.textSecondaryColor))),
      );
    }

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(gradient: AppColors.gradientPrimary, borderRadius: BorderRadius.circular(14)),
                alignment: Alignment.center,
                child: Text(patient.fullName.isNotEmpty ? patient.fullName[0] : 'P',
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: Colors.white)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(patient.fullName, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: context.textPrimaryColor)),
                    const SizedBox(height: 2),
                    Text('Age: ${patient.age} • Room ${patient.roomNumber ?? 'N/A'}',
                        style: TextStyle(fontSize: 11, color: context.textSecondaryColor)),
                  ],
                ),
              ),
              if (widget.onEditProfile != null)
                TextButton.icon(
                  onPressed: widget.onEditProfile,
                  icon: const Icon(Icons.edit, size: 14, color: AppColors.indigo500),
                  label: const Text('Edit', style: TextStyle(fontSize: 11, color: AppColors.indigo500)),
                ),
            ],
          ),
          const SizedBox(height: 14),
          Divider(color: context.borderColor, height: 1),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.subtleBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.phone, size: 14, color: AppColors.rose500),
                    const SizedBox(width: 6),
                    Text('EMERGENCY CONTACT', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: context.textSecondaryColor)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(patient.emergencyContact?.isNotEmpty == true ? patient.emergencyContact! : 'No Contact Stored',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: context.textPrimaryColor)),
                if (patient.emergencyContact?.isNotEmpty == true) ...[
                  const SizedBox(height: 10),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _isCalling ? null : _handleCallContact,
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.rose600),
                      icon: const Icon(Icons.phone_in_talk, size: 16),
                      label: Text(
                        _isCalling ? 'Dialing Number...' : (_callSuccess ? 'Call Dispatched!' : 'Call Designated Contact'),
                        style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: context.subtleBg,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: context.borderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.favorite, size: 14, color: AppColors.rose500),
                    const SizedBox(width: 6),
                    Text('MEDICAL CONDITIONS & ALLERGIES', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: context.textSecondaryColor)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(patient.medicalConditions?.isNotEmpty == true ? patient.medicalConditions! : 'None specified',
                    maxLines: 3, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 12, color: context.textPrimaryColor)),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.indigo500.withValues(alpha: context.isDark ? 0.15 : 0.08),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.indigo500.withValues(alpha: 0.2)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('PATIENT CARE SUMMARY',
                    style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.indigo500)),
                const SizedBox(height: 6),
                Text(
                  patient.summary?.isNotEmpty == true
                      ? patient.summary!
                      : (patient.notes?.isNotEmpty == true ? patient.notes! : 'No summary notes available. Edit profile to update.'),
                  style: TextStyle(fontSize: 12, color: context.textPrimaryColor, height: 1.4),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
