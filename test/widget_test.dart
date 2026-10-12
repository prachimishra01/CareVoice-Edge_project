import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:carevoice_edge/providers/auth_provider.dart';
import 'package:carevoice_edge/theme/app_theme.dart';
import 'package:carevoice_edge/screens/dashboard_screen.dart';

void main() {
  testWidgets('Dashboard shows a loading spinner before data arrives', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AuthProvider(),
        child: MaterialApp(
          theme: AppTheme.dark,
          home: Scaffold(
            body: DashboardScreen(onOpenReminderModal: () {}),
          ),
        ),
      ),
    );

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}
