import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'screens/dashboard_screen.dart';
import 'services/notification_service.dart';
import 'services/providers.dart';
import 'services/reminder_service.dart';
import 'services/settings_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: DeferItApp()));
}

class DeferItApp extends ConsumerStatefulWidget {
  const DeferItApp({super.key});

  @override
  ConsumerState<DeferItApp> createState() => _DeferItAppState();
}

class _DeferItAppState extends ConsumerState<DeferItApp> {
  late Future<void> _initialization;

  @override
  void initState() {
    super.initState();
    _initialization = _bootstrap();
  }

  Future<void> _bootstrap() async {
    await NotificationService.instance.initialize((response) {
      Future.microtask(() =>
          ref.read(reminderServiceProvider).handleNotificationResponse(response));
    });
    await ref.read(reminderServiceProvider).initialize();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);

    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {
        return MaterialApp(
          title: 'Defer It',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light(),
          darkTheme: AppTheme.dark(),
          themeMode: settings.themeMode,
          home: const DashboardScreen(),
        );
      },
    );
  }
}
