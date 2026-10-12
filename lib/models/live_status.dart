class CurrentReminderInfo {
  final int? id;
  final String title;
  final String category;
  final String scheduledTime;

  CurrentReminderInfo({this.id, required this.title, required this.category, required this.scheduledTime});

  factory CurrentReminderInfo.fromJson(Map<String, dynamic>? json) => CurrentReminderInfo(
        id: json?['id'] as int?,
        title: json?['title'] as String? ?? '',
        category: json?['category'] as String? ?? '',
        scheduledTime: json?['scheduled_time'] as String? ?? '',
      );
}

class LastConfirmationInfo {
  final int? id;
  final String status;
  final String? timestamp;
  final String? transcript;

  LastConfirmationInfo({this.id, required this.status, this.timestamp, this.transcript});

  factory LastConfirmationInfo.fromJson(Map<String, dynamic>? json) => LastConfirmationInfo(
        id: json?['id'] as int?,
        status: json?['status'] as String? ?? '',
        timestamp: json?['timestamp'] as String?,
        transcript: json?['transcript'] as String?,
      );
}

class NextReminderInfo {
  final int? id;
  final String title;
  final String scheduledTime;

  NextReminderInfo({this.id, required this.title, required this.scheduledTime});

  factory NextReminderInfo.fromJson(Map<String, dynamic>? json) => NextReminderInfo(
        id: json?['id'] as int?,
        title: json?['title'] as String? ?? '',
        scheduledTime: json?['scheduled_time'] as String? ?? '',
      );
}

class DeviceStatusInfo {
  final bool offlineMode;
  final String target;
  final String speechEngine;
  final String systemStatus;
  final bool wakewordActive;
  final bool raspberryConnected;

  DeviceStatusInfo({
    required this.offlineMode,
    required this.target,
    required this.speechEngine,
    required this.systemStatus,
    required this.wakewordActive,
    required this.raspberryConnected,
  });

  factory DeviceStatusInfo.fromJson(Map<String, dynamic>? json) => DeviceStatusInfo(
        offlineMode: json?['offline_mode'] as bool? ?? false,
        target: json?['target'] as String? ?? '',
        speechEngine: json?['speech_engine'] as String? ?? '',
        systemStatus: json?['system_status'] as String? ?? '',
        wakewordActive: json?['wakeword_active'] as bool? ?? false,
        raspberryConnected: json?['raspberry_connected'] as bool? ?? false,
      );
}

class LiveStatus {
  final CurrentReminderInfo currentReminder;
  final LastConfirmationInfo lastConfirmation;
  final NextReminderInfo nextReminder;
  final DeviceStatusInfo deviceStatus;

  LiveStatus({
    required this.currentReminder,
    required this.lastConfirmation,
    required this.nextReminder,
    required this.deviceStatus,
  });

  factory LiveStatus.fromJson(Map<String, dynamic> json) => LiveStatus(
        currentReminder: CurrentReminderInfo.fromJson(json['current_reminder'] as Map<String, dynamic>?),
        lastConfirmation: LastConfirmationInfo.fromJson(json['last_confirmation'] as Map<String, dynamic>?),
        nextReminder: NextReminderInfo.fromJson(json['next_reminder'] as Map<String, dynamic>?),
        deviceStatus: DeviceStatusInfo.fromJson(json['device_status'] as Map<String, dynamic>?),
      );
}
