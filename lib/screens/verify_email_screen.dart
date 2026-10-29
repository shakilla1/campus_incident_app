import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/constants.dart';
import '../widgets/primary_button.dart';

class VerifyEmailScreen extends StatefulWidget {
  const VerifyEmailScreen({super.key});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _checking = false;

  void _show(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _check() async {
    setState(() => _checking = true);
    final verified = await context.read<AuthProvider>().checkVerified();
    if (!mounted) return;
    setState(() => _checking = false);
    if (!verified) _show('Your email is not verified yet.');
  }

  Future<void> _resend() async {
    final auth = context.read<AuthProvider>();
    final sent = await auth.resendVerification();
    if (!mounted) return;
    _show(sent ? 'Verification email sent.' : auth.error ?? 'Could not send the email.');
  }

  @override
  Widget build(BuildContext context) {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Icon(Icons.mark_email_unread_outlined, size: 64, color: brandColor),
              const SizedBox(height: 20),
              const Text(
                'Verify your email',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                'We sent a link to $email. Open it, then come back and tap the button below.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.black54),
              ),
              const SizedBox(height: 28),
              PrimaryButton(
                label: 'I have verified',
                loading: _checking,
                onPressed: _check,
              ),
              TextButton(onPressed: _resend, child: const Text('Resend email')),
              TextButton(
                onPressed: () => context.read<AuthProvider>().logout(),
                child: const Text('Use a different account'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
