import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:whats_app/core/services/preference_manager.dart';
import 'package:whats_app/core/services/save_user_by_hive.dart';
import 'package:whats_app/features/splash/splash_screen.dart';
import 'colors.dart';
import 'core/di/injection_container.dart';
import 'features/chat/controllers/chat_contacts_cubit/chat_contacts_cubit.dart';
import 'firebase_options.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await dotenv.load(fileName: '.env');
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    publishableKey: dotenv.env['SUPABASE_PUBLISHER_KEY']!,

  );
  await initDependencies();
  await PreferencesManager().init();
  await UserRepository().init();
  runApp(
    BlocProvider(
      create: (_) => sl<ChatContactsCubit>()..getChatContacts(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Whatsapp UI',
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          backgroundColor: appBarColor,
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

