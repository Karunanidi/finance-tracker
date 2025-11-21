import 'package:finance_tracker/features/auth/cubit/auth_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

/// Dialog to enable biometric authentication
class BiometricSetupDialog extends StatelessWidget {
  final String email;
  final String password;

  const BiometricSetupDialog({
    super.key,
    required this.email,
    required this.password,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Row(
        children: [
          Icon(Icons.fingerprint, color: Color(0xFF6366F1)),
          SizedBox(width: 12),
          Text('Enable Biometric Login'),
        ],
      ),
      content: const Text(
        'Would you like to enable biometric authentication for faster login?',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Not Now'),
        ),
        ElevatedButton(
          onPressed: () async {
            await context.read<AuthCubit>().enableBiometric(email, password);
            if (context.mounted) {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Biometric authentication enabled!'),
                  backgroundColor: Color(0xFF10B981),
                ),
              );
            }
          },
          child: const Text('Enable'),
        ),
      ],
    );
  }
}
