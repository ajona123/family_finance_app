import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'core/theme/app_theme.dart';
import 'core/navigation/main_shell.dart';
import 'data/providers/member_provider.dart';
import 'data/providers/transaction_provider.dart';
import 'data/providers/arisan_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set preferred orientations (portrait only)
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Set status bar style
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MemberProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => TransactionProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => ArisanProvider()..initializeDummyData()),
      ],
      child: MaterialApp(
        title: 'Family Finance',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),

        // Set this to true if you want dark theme
        // darkTheme: AppTheme.dark(),
        // themeMode: ThemeMode.system,

        home: const MainShell(),
      ),
    );
  }
}