import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/user.dart';
import '../models/patient.dart';
import '../models/reminder.dart';
import '../models/emergency_event.dart';
import '../models/analytics_summary.dart';
import '../models/live_status.dart';
import '../models/patient_activity.dart';
import '../models/health_data.dart';


/// Port of frontend/src/api/client.ts.
/// Android emulators can't reach `localhost` on the host machine, so the
/// default base URL points at the emulator's host loopback alias (10.0.2.2).
/// Physical devices need the host machine's LAN IP, editable in Settings.
class ApiClient {
  static const String defaultBaseUrl = 'http://10.91.188.174:8000/api/v1';
  static const String _prefsKey = 'carevoice_api_base_url';

  String _baseUrl = defaultBaseUrl;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    _baseUrl = prefs.getString(_prefsKey) ?? defaultBaseUrl;
  }

  String get baseUrl => _baseUrl;

  Future<void> setBaseUrl(String url) async {
    _baseUrl = url;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, url);
  }

  Map<String, String> get _headers => {'Content-Type': 'application/json'};

  Future<dynamic> _request(
    String endpoint, {
    String method = 'GET',
    Map<String, dynamic>? body,
  }) async {
    final uri = Uri.parse('$_baseUrl$endpoint');
    late http.Response response;
    final encodedBody = body != null ? jsonEncode(body) : null;

    switch (method) {
      case 'POST':
        response = await http.post(uri, headers: _headers, body: encodedBody);
        break;
      case 'PUT':
        response = await http.put(uri, headers: _headers, body: encodedBody);
        break;
      case 'DELETE':
        response = await http.delete(uri, headers: _headers);
        break;
      default:
        response = await http.get(uri, headers: _headers);
    }

    if (response.statusCode < 200 || response.statusCode >= 300) {
      String detail = 'API request failed';
      try {
        final decoded = jsonDecode(response.body);
        detail = decoded['detail']?.toString() ?? detail;
      } catch (_) {}
      throw Exception(detail);
    }

    if (response.body.isEmpty) return null;
    return jsonDecode(response.body);
  }

  // Auth
  Future<User> getCurrentUser() async {
    final json = await _request('/auth/me');
    return User.fromJson(json as Map<String, dynamic>);
  }

  // Patients
  Future<List<Patient>> getPatients() async {
    final json = await _request('/patients') as List<dynamic>;
    return json.map((e) => Patient.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Patient> getPatientById(int id) async {
    final json = await _request('/patients/$id');
    return Patient.fromJson(json as Map<String, dynamic>);
  }

  Future<Patient> createPatient(Map<String, dynamic> data) async {
    final json = await _request('/patients', method: 'POST', body: data);
    return Patient.fromJson(json as Map<String, dynamic>);
  }

  Future<Patient> updatePatient(int id, Map<String, dynamic> data) async {
    final json = await _request('/patients/$id', method: 'PUT', body: data);
    return Patient.fromJson(json as Map<String, dynamic>);
  }

  Future<void> deletePatient(int id) async {
    await _request('/patients/$id', method: 'DELETE');
  }

  // Reminders
  Future<List<Reminder>> getReminders({int? patientId}) async {
    final endpoint = patientId != null ? '/reminders?patient_id=$patientId' : '/reminders';
    final json = await _request(endpoint) as List<dynamic>;
    return json.map((e) => Reminder.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<Reminder> getReminderById(int id) async {
    final json = await _request('/reminders/$id');
    return Reminder.fromJson(json as Map<String, dynamic>);
  }

  Future<Reminder> createReminder(Map<String, dynamic> data) async {
    final json = await _request('/reminders', method: 'POST', body: data);
    return Reminder.fromJson(json as Map<String, dynamic>);
  }

  Future<Reminder> updateReminder(int id, Map<String, dynamic> data) async {
    final json = await _request('/reminders/$id', method: 'PUT', body: data);
    return Reminder.fromJson(json as Map<String, dynamic>);
  }

  Future<void> deleteReminder(int id) async {
    await _request('/reminders/$id', method: 'DELETE');
  }

  Future<dynamic> announceReminder(int id) async {
    return _request('/reminders/$id/announce', method: 'POST');
  }

  Future<dynamic> confirmVoice(int reminderId, String patientSpeech) async {
    return _request('/reminders/confirm-voice',
        method: 'POST', body: {'reminder_id': reminderId, 'patient_speech': patientSpeech});
  }

  Future<dynamic> completeReminder(int reminderId, {String? notes, String? patientSpeech}) async {
    final body = <String, dynamic>{'status': 'completed'};
    if (notes != null) body['notes'] = notes;
    if (patientSpeech != null) body['patient_speech'] = patientSpeech;
    return _request('/reminders/$reminderId/complete', method: 'POST', body: body);
  }

  // Patient Activities
  Future<List<PatientActivity>> getActivities({int? patientId, int limit = 50}) async {
    final endpoint = patientId != null ? '/activities?patient_id=$patientId&limit=$limit' : '/activities?limit=$limit';
    final json = await _request(endpoint) as List<dynamic>;
    return json.map((e) => PatientActivity.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<PatientActivity>> getRecentActivities({int? patientId, int limit = 10}) async {
    final endpoint = patientId != null ? '/activities/recent?patient_id=$patientId&limit=$limit' : '/activities/recent?limit=$limit';
    final json = await _request(endpoint) as List<dynamic>;
    return json.map((e) => PatientActivity.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<PatientActivity> createActivity(Map<String, dynamic> data) async {
    final json = await _request('/activities', method: 'POST', body: data);
    return PatientActivity.fromJson(json as Map<String, dynamic>);
  }

  // Health Data / Vitals
  Future<List<HealthData>> getHealthData({int? patientId, int limit = 50}) async {
    final endpoint = patientId != null ? '/health-data?patient_id=$patientId&limit=$limit' : '/health-data?limit=$limit';
    final json = await _request(endpoint) as List<dynamic>;
    return json.map((e) => HealthData.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<HealthData?> getLatestHealthData({int? patientId}) async {
    try {
      final endpoint = patientId != null ? '/health-data/latest?patient_id=$patientId' : '/health-data/latest';
      final json = await _request(endpoint);
      if (json == null) return null;
      return HealthData.fromJson(json as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<HealthData> createHealthData(Map<String, dynamic> data) async {
    final json = await _request('/health-data', method: 'POST', body: data);
    return HealthData.fromJson(json as Map<String, dynamic>);
  }

  // Emergency & Alerts
  Future<List<EmergencyEvent>> getEmergencies() async {
    final json = await _request('/emergency') as List<dynamic>;
    return json.map((e) => EmergencyEvent.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<List<EmergencyEvent>> getAlerts({int? patientId, String? status}) async {
    String endpoint = '/alerts';
    final params = <String>[];
    if (patientId != null) params.add('patient_id=$patientId');
    if (status != null) params.add('status=$status');
    if (params.isNotEmpty) endpoint += '?${params.join('&')}';
    final json = await _request(endpoint) as List<dynamic>;
    return json.map((e) => EmergencyEvent.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<EmergencyEvent> createAlert(Map<String, dynamic> data) async {
    final json = await _request('/alerts', method: 'POST', body: data);
    return EmergencyEvent.fromJson(json as Map<String, dynamic>);
  }

  Future<EmergencyEvent> resolveAlert(int id, {String? notes}) async {
    final json = await _request('/alerts/$id/resolve', method: 'PUT', body: {'notes': notes});
    return EmergencyEvent.fromJson(json as Map<String, dynamic>);
  }

  Future<EmergencyEvent> triggerEmergency({
    int? patientId,
    required String triggerSource,
    String? speechTranscript,
  }) async {
    final body = <String, dynamic>{'trigger_source': triggerSource};
    if (patientId != null) body['patient_id'] = patientId;
    if (speechTranscript != null) body['speech_transcript'] = speechTranscript;
    final json = await _request('/emergency/trigger', method: 'POST', body: body);
    return EmergencyEvent.fromJson(json as Map<String, dynamic>);
  }

  Future<EmergencyEvent> resolveEmergency(int id, {String? notes}) async {
    final json = await _request('/emergency/$id/resolve', method: 'PUT', body: {'notes': notes});
    return EmergencyEvent.fromJson(json as Map<String, dynamic>);
  }

  Future<dynamic> voiceSos(String transcript) async {
    final endpoint = '/emergency/voice-sos?speech_transcript=${Uri.encodeComponent(transcript)}';
    return _request(endpoint, method: 'POST');
  }

  // Analytics & Live Status
  Future<AnalyticsSummary> getAnalytics() async {
    final json = await _request('/analytics');
    return AnalyticsSummary.fromJson(json as Map<String, dynamic>);
  }

  Future<LiveStatus> getLiveStatus() async {
    final json = await _request('/live-status');
    return LiveStatus.fromJson(json as Map<String, dynamic>);
  }
}

final apiClient = ApiClient();

