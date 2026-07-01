import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'views/splash_view.dart';
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
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'IroncladBox',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.orange),
          useMaterial3: true,
        ),
        home: const SplashView(),
      ),
    );
  }
}
