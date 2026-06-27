import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:one_coorg/providers/favourites_provider.dart';
import 'package:one_coorg/splash_screen.dart';
import 'package:one_coorg/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  await Supabase.initialize(
    url: 'https://wacayfyuuugawcwzsqcn.supabase.co',
    // publishableKey: 'sb_publishable_WDyUGVPutJMulZevxZ-T2A_PCbF9ulZ',
    publishableKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6IndhY2F5Znl1dXVnYXdjd3pzcWNuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODEyNjg5MDMsImV4cCI6MjA5Njg0NDkwM30.kgoi97hUSazLORehFjDFafRbjCLnRt5Blro2WF84sHo',
  );

  runApp(const CoorgExplorerApp());
}

class CoorgExplorerApp extends StatelessWidget {
  const CoorgExplorerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return FavouritesProvider(
      // ← wrap here
      notifier: FavouritesNotifier(),
      child: MaterialApp(
        title: 'One Coorg',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: ThemeMode.system,
        home: const SplashScreen(),
      ),
    );
  }
}
