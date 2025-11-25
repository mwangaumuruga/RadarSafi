import 'package:flutter/material.dart';

import 'features/splash/splash_screen.dart';
import 'theme/app_colors.dart';

class RadarSafiApp extends StatelessWidget {
  const RadarSafiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RadarSafi',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: 'Poppins',
        useMaterial3: true,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.accentGreen,
          secondary: AppColors.accentBlue,
          surface: AppColors.surface,
          background: AppColors.backgroundDeep,
          error: AppColors.danger,
        ),
        scaffoldBackgroundColor: AppColors.backgroundDeep,
      ),
      home: const SplashScreen(),
    );
  }
}

