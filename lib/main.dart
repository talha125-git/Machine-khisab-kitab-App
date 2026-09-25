import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/user.dart';
import 'services/auth_service.dart';
import 'theme/app_theme.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';

final ValueNotifier<ThemeMode> appThemeModeNotifier = ValueNotifier<ThemeMode>(ThemeMode.dark);

Future<void> setAppThemeMode(ThemeMode mode) async {
  appThemeModeNotifier.value = mode;
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString('app_theme_mode', mode == ThemeMode.light ? 'light' : 'dark');
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final currentUser = await AuthService.getCurrentUser();

  final prefs = await SharedPreferences.getInstance();
  final savedTheme = prefs.getString('app_theme_mode');
  // Dark theme is default!
  if (savedTheme == 'light') {
    appThemeModeNotifier.value = ThemeMode.light;
  } else {
    appThemeModeNotifier.value = ThemeMode.dark;
  }

  runApp(KhisabKitabApp(initialUser: currentUser));
}

class KhisabKitabApp extends StatefulWidget {
  final AppUser? initialUser;

  const KhisabKitabApp({super.key, this.initialUser});

  @override
  State<KhisabKitabApp> createState() => _KhisabKitabAppState();
}

class _KhisabKitabAppState extends State<KhisabKitabApp> {
  AppUser? _user;

  @override
  void initState() {
    super.initState();
    _user = widget.initialUser;
  }

  void _handleLoginSuccess(AppUser user) {
    setState(() {
      _user = user;
    });
  }

  void _handleLogout() {
    setState(() {
      _user = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: appThemeModeNotifier,
      builder: (context, currentThemeMode, _) {
        return MaterialApp(
          title: 'Machine Khisab Kitab',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: currentThemeMode,
          home: _user != null
              ? HomeScreen(
                  user: _user!,
                  onLogout: _handleLogout,
                )
              : AuthScreen(
                  onLoginSuccess: _handleLoginSuccess,
                ),
        );
      },
    );
  }
}
