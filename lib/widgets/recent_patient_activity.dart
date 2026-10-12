import 'package:flutter/material.dart';
import '../models/patient_activity.dart';
import '../theme/app_theme.dart';
import 'glass_card.dart';

class PatientActivityEntry {
  final String id;
  final String activity;
  final String timestamp;

  const PatientActivityEntry({required this.id, required this.activity, required this.timestamp});

  factory PatientActivityEntry.fromModel(PatientActivity model) => PatientActivityEntry(
        id: model.id.toString(),
        activity: model.activityType,
        timestamp: model.timestamp,
      );

  static const defaultActivities = [
    PatientActivityEntry(id: 'act-1', activity: 'Walking', timestamp: '10 minutes ago'),
    PatientActivityEntry(id: 'act-2', activity: 'Sleeping', timestamp: '25 minutes ago'),
    PatientActivityEntry(id: 'act-3', activity: 'Sitting', timestamp: '40 minutes ago'),
    PatientActivityEntry(id: 'act-4', activity: 'Standing', timestamp: '1 hour ago'),
    PatientActivityEntry(id: 'act-5', activity: 'Medicine Taken', timestamp: '2 hours ago'),
    PatientActivityEntry(id: 'act-6', activity: 'Eating', timestamp: '3 hours ago'),
  ];
}

class RecentPatientActivity extends StatelessWidget {
  final List<PatientActivityEntry> activities;

  const RecentPatientActivity({super.key, this.activities = PatientActivityEntry.defaultActivities});


  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.timeline, size: 16, color: AppColors.indigo400),
                  const SizedBox(width: 8),
                  Text('Recent Patient Activity', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: context.textPrimaryColor)),
                ],
              ),
              Text('Activity Log', style: TextStyle(fontSize: 10, color: context.textSecondaryColor)),
            ],
          ),
          const SizedBox(height: 10),
          Divider(color: context.borderColor, height: 1),
          const SizedBox(height: 10),
          ...activities.map((item) => Container(
                margin: const EdgeInsets.only(bottom: 8),
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: context.subtleBg,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: context.borderColor),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(item.activity, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: context.textPrimaryColor)),
                    Text(item.timestamp, style: TextStyle(fontSize: 11, color: context.textSecondaryColor)),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}
