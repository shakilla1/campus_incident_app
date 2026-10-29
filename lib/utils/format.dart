const _months = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String formatDateTime(DateTime t) {
  final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
  final minute = t.minute.toString().padLeft(2, '0');
  final suffix = t.hour >= 12 ? 'PM' : 'AM';
  return '${_months[t.month - 1]} ${t.day}, ${t.year} at $hour:$minute $suffix';
}

String shortDate(DateTime t) => '${_months[t.month - 1]} ${t.day}';

String timeAgo(DateTime t) {
  final diff = DateTime.now().difference(t);
  if (diff.inMinutes < 1) return 'Just now';
  if (diff.inMinutes < 60) return '${diff.inMinutes} min ago';
  if (diff.inHours < 24) return _count(diff.inHours, 'hour');
  if (diff.inDays < 30) return _count(diff.inDays, 'day');
  return shortDate(t);
}

String _count(int n, String unit) => '$n $unit${n == 1 ? '' : 's'} ago';
