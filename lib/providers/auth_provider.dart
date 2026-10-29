import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuthException, User;
import 'package:flutter/foundation.dart';

import '../models/app_user.dart';
import '../services/auth_service.dart';

enum AuthStatus { loading, signedOut, unverified, ready }

class AuthProvider extends ChangeNotifier {
  final AuthService _service;
  StreamSubscription<User?>? _sub;

  AuthStatus status = AuthStatus.loading;
  AppUser? user;
  String? error;
  bool busy = false;

  AuthProvider(this._service) {
    _sub = _service.authChanges.listen(_onAuthChanged);
  }

  Future<void> _onAuthChanged(User? firebaseUser) async {
    if (firebaseUser == null) {
      user = null;
      status = AuthStatus.signedOut;
    } else if (!firebaseUser.emailVerified) {
      user = null;
      status = AuthStatus.unverified;
    } else {
      try {
        user = await _service.fetchProfile(firebaseUser.uid);
      } catch (_) {
        user = null;
      }
      if (user == null) {
        error = 'Could not load your profile. Please sign in again.';
        await _service.logout();
        return;
      }
      status = AuthStatus.ready;
    }
    notifyListeners();
  }

  Future<bool> register(String name, String email, String password) {
    return _run(() => _service.register(name, email, password));
  }

  Future<bool> login(String email, String password) {
    return _run(() => _service.login(email, password));
  }

  Future<bool> resendVerification() => _run(_service.resendVerification);

  Future<bool> checkVerified() async {
    final verified = await _service.refreshVerification();
    if (verified) await _onAuthChanged(_service.currentUser);
    return verified;
  }

  Future<void> logout() => _service.logout();

  void clearError() {
    error = null;
    notifyListeners();
  }

    Future<bool> _run(Future<void> Function() action) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      await action();
      return true;
    } on FirebaseAuthException catch (e) {
      error = _message(e.code);
      return false;
    } catch (e) {
      error = 'Something went wrong. Please try again.';
      return false;
    } finally {
      busy = false;
      notifyListeners();
    }
  }
  String _message(String code) {
    switch (code) {
      case 'invalid-credential':
      case 'wrong-password':
      case 'user-not-found':
        return 'Email or password is incorrect.';
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'weak-password':
        return 'Choose a stronger password.';
      case 'network-request-failed':
        return 'No internet connection.';
      case 'too-many-requests':
        return 'Too many attempts. Wait a bit and try again.';
      default:
        return 'Something went wrong. Please try again.';
    }
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
