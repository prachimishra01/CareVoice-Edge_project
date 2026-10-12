import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/reminder.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../services/api_client.dart';
import '../theme/app_theme.dart';
import '../widgets/custom_nav_bar.dart';
import '../widgets/reminder_modal.dart';
import 'dashboard_screen.dart';
import 'login_screen.dart';
import 'patient_chatbot_screen.dart';
import 'patient_profile_screen.dart';
import 'reminders_screen.dart';
import 'settings_screen.dart';
import 'task_history_screen.dart';

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _tabIndex = 0;
  bool _isPiConnected = false;
  Timer? _piPollTimer;

  final _tabs = ['dashboard', 'reminders', 'chat', 'patient', 'history', 'settings'];

  @override
  void initState() {
    super.initState();
    _checkStatus();
    _piPollTimer = Timer.periodic(const Duration(seconds: 10), (_) => _checkStatus());
  }

  @override
  void dispose() {
    _piPollTimer?.cancel();
    super.dispose();
  }

  Future<void> _checkStatus() async {
    try {
      final status = await apiClient.getLiveStatus();
      if (mounted) setState(() => _isPiConnected = status.deviceStatus.raspberryConnected);
    } catch (err) {
      debugPrint('Failed to check live status: $err');
    }
  }

  void _navigateTab(String tab) {
    final idx = _tabs.indexOf(tab);
    if (idx != -1) setState(() => _tabIndex = idx);
  }

  Future<void> _openReminderModal({Reminder? reminder}) {
    return showReminderModal(
      context: context,
      reminder: reminder,
      patientId: 1,
      onSave: (data) async {
        if (reminder != null) {
          await apiClient.updateReminder(reminder.id, data);
        } else {
          await apiClient.createReminder(data);
        }
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();

    if (auth.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (!auth.isAuthenticated) {
      return const LoginScreen();
    }

    final user = auth.user;

    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        titleSpacing: 20,
        toolbarHeight: 80,
        title: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.indigo500,
                  child: const Icon(Icons.health_and_safety_rounded, color: Colors.white, size: 24),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: _isPiConnected ? AppColors.emerald500 : AppColors.amber500,
                      shape: BoxShape.circle,
                      border: Border.all(color: context.surfaceColor, width: 2),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Hello, ${user?.fullName.split(' ')[0] ?? 'Caregiver'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: context.textSecondaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    'Patient health at a glance',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: context.textPrimaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          // Chatbot quick button
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              shape: BoxShape.circle,
              border: Border.all(color: context.borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              tooltip: 'Patient AI Chatbot',
              onPressed: () => _navigateTab('chat'),
              icon: Icon(
                Icons.smart_toy_rounded,
                color: _tabIndex == 2 ? AppColors.indigo500 : context.textPrimaryColor,
                size: 20,
              ),
            ),
          ),
          // Theme quick-toggle button
          Container(
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              shape: BoxShape.circle,
              border: Border.all(color: context.borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              tooltip: 'Toggle Light / Dark Mode',
              onPressed: () => themeProvider.toggleTheme(context),
              icon: Icon(
                context.isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                color: context.isDark ? AppColors.amber400 : AppColors.indigo500,
                size: 20,
              ),
            ),
          ),
          // Notifications button
          Container(
            margin: const EdgeInsets.only(right: 20),
            decoration: BoxDecoration(
              color: context.surfaceColor,
              shape: BoxShape.circle,
              border: Border.all(color: context.borderColor),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: context.isDark ? 0.2 : 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () {},
              icon: Icon(Icons.notifications_none_rounded, color: context.textPrimaryColor),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _tabIndex,
        children: [
          DashboardScreen(onOpenReminderModal: () => _openReminderModal(), onNavigateTab: _navigateTab),
          RemindersScreen(onOpenModal: (r) => _openReminderModal(reminder: r)),
          PatientChatbotScreen(onBackToDashboard: () => _navigateTab('dashboard')),
          const PatientProfileScreen(),
          const TaskHistoryScreen(),
          const SettingsScreen(),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 64,
        width: 64,
        margin: const EdgeInsets.only(top: 30),
        child: FloatingActionButton(
          onPressed: () => _openReminderModal(),
          elevation: 4,
          backgroundColor: AppColors.indigo500,
          shape: const CircleBorder(),
          child: const Icon(Icons.add, color: Colors.white, size: 30),
        ),
      ),
      bottomNavigationBar: CustomNavBar(
        currentIndex: _tabIndex,
        onTap: (i) => setState(() => _tabIndex = i),
        onActionTap: () => _openReminderModal(),
      ),
    );
  }
}
