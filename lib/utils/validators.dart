import 'constants.dart';

String? requiredField(String? value, String label, {int minLength = 1}) {
  final text = value?.trim() ?? '';
  if (text.isEmpty) return '$label is required';
  if (text.length < minLength) return '$label must be at least $minLength characters';
  return null;
}

String? aluEmail(String? value) {
  final text = value?.trim().toLowerCase() ?? '';
  if (text.isEmpty) return 'Email is required';
  final parts = text.split('@');
  if (parts.length != 2 || parts[0].isEmpty) return 'Enter a valid email';
  if (!allowedEmailDomains.contains(parts[1])) {
    return 'Use your ALU email address';
  }
  return null;
}

String? loginPassword(String? value) {
  if (value == null || value.isEmpty) return 'Password is required';
  return null;
}

String? newPassword(String? value) {
  if (value == null || value.length < 8) {
    return 'Use at least 8 characters';
  }
  return null;
}
