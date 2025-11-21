import 'package:finance_tracker/core/currency/currency_cubit.dart';
import 'package:finance_tracker/core/theme.dart';
import 'package:finance_tracker/data/services/biometric_service.dart';
import 'package:finance_tracker/features/auth/cubit/auth_cubit.dart';
import 'package:finance_tracker/features/auth/cubit/auth_state.dart';
import 'package:finance_tracker/features/auth/login_page.dart';
import 'package:finance_tracker/widgets/main_navigation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  const supabaseUrl = 'https://phxbciykiwakhcfuamli.supabase.co';
  const supabaseKey = 'sb_publishable_Ffl5qor2yuQLjdAr73cXFQ_MTRGK2_-';

  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseKey);

  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => CurrencyCubit()),
        BlocProvider(
          create: (_) =>
              AuthCubit(Supabase.instance.client, BiometricService()),
        ),
      ],
      child: MaterialApp(
        title: 'Finance Tracker',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(),
      ),
    );
  }
}

/// Wrapper to handle authentication routing
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthInitial || state is AuthLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (state is Authenticated) {
          return const MainNavigation();
        }

        return const LoginPage();
      },
    );
  }
}
