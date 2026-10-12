import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/root_shell.dart';
import 'services/api_client.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await apiClient.init();
  runApp(const CareVoiceEdgeApp());
}

class CareVoiceEdgeApp extends StatefulWidget {
  const CareVoiceEdgeApp({super.key});

  @override
  State<CareVoiceEdgeApp> createState() => _CareVoiceEdgeAppState();
}

class _CareVoiceEdgeAppState extends State<CareVoiceEdgeApp> {
  late final AuthProvider _authProvider;
  late final ThemeProvider _themeProvider;

  @override
  void initState() {
    super.initState();
    _authProvider = AuthProvider();
    _authProvider.bootstrap();
    _themeProvider = ThemeProvider();
    _themeProvider.bootstrap();
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: _authProvider),
        ChangeNotifierProvider.value(value: _themeProvider),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp(
            title: 'CareVoice Edge',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.light,
            darkTheme: AppTheme.dark,
            themeMode: themeProvider.themeMode,
            home: const RootShell(),
          );
        },
      ),
    );
  }
}
