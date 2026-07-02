import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'views/splash_view.dart';
import 'viewmodels/backend_viewmodels.dart';
import 'viewmodels/login_viewmodel.dart';
import 'viewmodels/splash_viewmodel.dart';

class IroncladBoxApp extends StatelessWidget {
  const IroncladBoxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LoginViewModel()),
        ChangeNotifierProvider(create: (_) => SplashViewModel()),
        ChangeNotifierProvider(create: (_) => MembershipsViewModel()),
        ChangeNotifierProvider(create: (_) => AthletesViewModel()),
        ChangeNotifierProvider(create: (_) => TrainersViewModel()),
        ChangeNotifierProvider(create: (_) => ClassesViewModel()),
        ChangeNotifierProvider(create: (_) => WodsViewModel()),
        ChangeNotifierProvider(create: (_) => ExercisesViewModel()),
        ChangeNotifierProvider(create: (_) => ProgressViewModel()),
        ChangeNotifierProvider(create: (_) => ContactsViewModel()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'IroncladBox',
        theme: ThemeData(
          useMaterial3: true,
          brightness: Brightness.dark,
          colorScheme: const ColorScheme.dark(
            primary: Color(0xFFFF3B30),
            secondary: Color(0xFFFF9500),
            surface: Color(0xFF1C1C1E),
            background: Color(0xFF111113),
            error: Color(0xFFFF453A),
            onPrimary: Colors.white,
            onSecondary: Colors.white,
            onSurface: Colors.white,
            onBackground: Colors.white,
          ),
          scaffoldBackgroundColor: const Color(0xFF111113),
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1C1C1E),
            foregroundColor: Colors.white,
            centerTitle: true,
            elevation: 0,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF3B30),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              textStyle: const TextStyle(
                fontWeight: FontWeight.w700,
                letterSpacing: 1,
              ),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFF1C1C1E),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF3A3A3C)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF3A3A3C)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFFF3B30), width: 1.5),
            ),
            labelStyle: const TextStyle(color: Color(0xFFB0B0B5)),
          ),
          cardTheme: CardThemeData(
            color: const Color(0xFF1C1C1E),
            elevation: 16,
            shadowColor: Colors.black.withValues(alpha: 0.35),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          ),
          bottomNavigationBarTheme: const BottomNavigationBarThemeData(
            backgroundColor: Color(0xFF1C1C1E),
            selectedItemColor: Color(0xFFFF3B30),
            unselectedItemColor: Color(0xFF8E8E93),
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
          ),
        ),
        home: const SplashView(),
      ),
    );
  }
}
