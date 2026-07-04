import 'dart:ui';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:one_coorg/firebase_options.dart';
import 'package:one_coorg/providers/favourites_provider.dart';
import 'package:one_coorg/providers/weather_provider.dart';
import 'package:one_coorg/splash_screen.dart';
import 'package:one_coorg/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  await MobileAds.instance.initialize();
  await Supabase.initialize(
    url: 'https://wacayfyuuugawcwzsqcn.supabase.co',
    publishableKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndhY2F5Znl1dXVnYXdjd3pzcWNuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEyNjg5MDMsImV4cCI6MjA5Njg0NDkwM30.kgoi97hUSazLORehFjDFafRbjCLnRt5Blro2WF84sHo',
  );

  FlutterError.onError = (errorDetails) {
    FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
  };
  PlatformDispatcher.instance.onError = (error, stack) {
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
    return true;
  };

  runApp(const CoorgExplorerApp());
}

class CoorgExplorerApp extends StatelessWidget {
  const CoorgExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FavouritesProvider(
      notifier: FavouritesNotifier(),
      child: WeatherProvider(
        notifier: WeatherNotifier(),
        child: MaterialApp(
          title: 'One Coorg',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          darkTheme: AppTheme.dark,
          themeMode: ThemeMode.system,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
