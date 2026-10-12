import 'package:flutter/foundation.dart';
import '../models/user.dart';
import '../services/api_client.dart';

/// Port of frontend/src/context/AuthContext.tsx.
/// Auth is bypassed in the web app (hardcoded caretaker user, login()/logout()
/// are no-ops) — this mirrors that exactly.
class AuthProvider extends ChangeNotifier {
  User? _user = User(
    id: 1,
    email: 'caretaker@carevoice.local',
    fullName: 'Primary Caretaker',
    role: 'caretaker',
    isActive: true,
  );
  bool _isLoading = true;

  User? get user => _user;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoading;

  Future<void> bootstrap() async {
    try {
      final userData = await apiClient.getCurrentUser();
      _user = userData;
    } catch (err) {
      debugPrint('Session bypass load error: $err');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> login(String email, String password) async {
    // Auth is bypassed
  }

  void logout() {
    // Auth is bypassed
  }
}
