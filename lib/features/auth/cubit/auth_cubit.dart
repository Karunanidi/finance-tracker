import 'package:finance_tracker/data/services/biometric_service.dart';
import 'package:finance_tracker/features/auth/cubit/auth_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;

/// Cubit for managing authentication state
class AuthCubit extends Cubit<AuthState> {
  final SupabaseClient _supabase;
  final BiometricService biometricService;

  AuthCubit(this._supabase, this.biometricService)
    : super(const AuthInitial()) {
    _init();
  }

  /// Initialize and check for existing session
  Future<void> _init() async {
    emit(const AuthLoading());

    try {
      final session = _supabase.auth.currentSession;
      if (session != null) {
        final biometricEnabled = await biometricService.isBiometricEnabled();
        emit(
          Authenticated(user: session.user, biometricEnabled: biometricEnabled),
        );
      } else {
        emit(const Unauthenticated());
      }
    } catch (e) {
      emit(const Unauthenticated());
    }
  }

  /// Sign up with email and password
  Future<void> signUp(String email, String password) async {
    emit(const AuthLoading());

    try {
      final response = await _supabase.auth.signUp(
        email: email,
        password: password,
      );

      if (response.user != null) {
        emit(Authenticated(user: response.user!));
      } else {
        emit(const AuthError('Failed to create account'));
      }
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('An error occurred: $e'));
    }
  }

  /// Sign in with email and password
  Future<void> signIn(String email, String password) async {
    emit(const AuthLoading());

    try {
      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user != null) {
        final biometricEnabled = await biometricService.isBiometricEnabled();
        emit(
          Authenticated(
            user: response.user!,
            biometricEnabled: biometricEnabled,
          ),
        );
      } else {
        emit(const AuthError('Failed to sign in'));
      }
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('An error occurred: $e'));
    }
  }

  /// Sign in with biometric
  Future<void> signInWithBiometric() async {
    emit(const AuthLoading());

    try {
      // Check if biometric is available
      final isAvailable = await biometricService.isBiometricAvailable();
      if (!isAvailable) {
        emit(const AuthError('Biometric authentication not available'));
        return;
      }

      // Authenticate with biometric
      final authenticated = await biometricService.authenticate();
      if (!authenticated) {
        emit(const AuthError('Biometric authentication failed'));
        return;
      }

      // Get stored credentials
      final credentials = await biometricService.getStoredCredentials();
      if (credentials == null) {
        emit(const AuthError('No stored credentials found'));
        return;
      }

      // Sign in with stored credentials
      await signIn(credentials['email']!, credentials['password']!);
    } catch (e) {
      emit(AuthError('Biometric sign in failed: $e'));
    }
  }

  /// Enable biometric authentication
  Future<void> enableBiometric(String email, String password) async {
    try {
      // Check if biometric is available
      final isAvailable = await biometricService.isBiometricAvailable();
      if (!isAvailable) {
        emit(const AuthError('Biometric authentication not available'));
        return;
      }

      // Authenticate with biometric to confirm
      final authenticated = await biometricService.authenticate();
      if (!authenticated) {
        return;
      }

      // Store credentials
      await biometricService.storeCredentials(email, password);

      // Update state
      final currentState = state;
      if (currentState is Authenticated) {
        emit(Authenticated(user: currentState.user, biometricEnabled: true));
      }
    } catch (e) {
      emit(AuthError('Failed to enable biometric: $e'));
    }
  }

  /// Disable biometric authentication
  Future<void> disableBiometric() async {
    try {
      await biometricService.disableBiometric();

      final currentState = state;
      if (currentState is Authenticated) {
        emit(Authenticated(user: currentState.user, biometricEnabled: false));
      }
    } catch (e) {
      emit(AuthError('Failed to disable biometric: $e'));
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _supabase.auth.signOut();
      await biometricService.clearAll();
      emit(const Unauthenticated());
    } catch (e) {
      emit(AuthError('Failed to sign out: $e'));
    }
  }

  /// Check session
  Future<void> checkSession() async {
    await _init();
  }
}
