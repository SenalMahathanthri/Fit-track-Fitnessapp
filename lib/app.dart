// lib/app.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'core/routes/app_pages.dart';
import 'core/theme/app_theme.dart';

class FitTrackerApp extends StatelessWidget {
  const FitTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'FitTracker',
      debugShowCheckedModeBanner: false,

      // Theme configuration
      theme: AppTheme.lightTheme(),
      darkTheme: AppTheme.darkTheme(),
      themeMode: ThemeMode.light,
      initialRoute: Routes.splash,
      getPages: AppPages.pages,
      defaultTransition: Transition.rightToLeftWithFade,
      transitionDuration: const Duration(milliseconds: 300),

      // Error handling and logging
      onUnknownRoute: (settings) {
        return GetPageRoute(
          page:
              () =>
                  const Scaffold(body: Center(child: Text('Route not found'))),
        );
      },
      enableLog: true,
      logWriterCallback: (String text, {bool isError = false}) {
        debugPrint('GetX: $text');
      },

      defaultGlobalState: false,
      popGesture: true,
      smartManagement: SmartManagement.keepFactory,
    );
  }
}
