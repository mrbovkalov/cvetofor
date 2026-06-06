import 'package:cvetofor/app.dart';
import 'package:cvetofor/core/themes.dart';
import 'package:cvetofor/shared/privacy_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:appmetrica_plugin/appmetrica_plugin.dart';

AppMetricaConfig get _appMetricaConfig =>
    const AppMetricaConfig('98bbf6bd-68cc-4694-9acd-e3810373e6ae', logs: true);

void main() async {
  AppMetrica.runZoneGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();

    await AppMetrica.activate(_appMetricaConfig);

    final prefs = await SharedPreferences.getInstance();
    final hasConsent = prefs.getBool('privacy_consent_given') ?? false;

    runApp(
      MaterialApp(
        title: 'Цветофор',
        theme: AppTheme.lightTheme,
        home: hasConsent ? const Cvetofor() : const PrivacyScreen(),
        locale: const Locale('ru', 'RU'),
        debugShowCheckedModeBanner: false,
      ),
    );
  });
}

// import 'package:cvetofor/app.dart';
// import 'package:cvetofor/core/themes.dart';
// import 'package:cvetofor/shared/privacy_screen.dart';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// void main() async {
//   WidgetsFlutterBinding.ensureInitialized();

//   final prefs = await SharedPreferences.getInstance();
//   final hasConsent = prefs.getBool('privacy_consent_given') ?? false;

//   runApp(
//     MaterialApp(
//       title: 'Цветофор',
//       theme: AppTheme.lightTheme,
//       home: hasConsent ? const Cvetofor() : const PrivacyScreen(),
//       locale: const Locale('ru', 'RU'),
//       debugShowCheckedModeBanner: false,
//     ),
//   );
// }
