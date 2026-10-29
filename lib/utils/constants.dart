import 'package:flutter/material.dart';

const brandColor = Color(0xFF6C47E8);

const allowedEmailDomains = ['alustudent.com', 'alueducation.com'];

const categories = [
  'Facilities',
  'Water',
  'Electricity',
  'Furniture',
  'Sanitation',
  'Safety',
];

const statuses = ['Submitted', 'In Progress', 'Resolved'];

const categoryIcons = <String, IconData>{
  'Facilities': Icons.apartment,
  'Water': Icons.water_drop_outlined,
  'Electricity': Icons.bolt,
  'Furniture': Icons.chair_alt,
  'Sanitation': Icons.delete_outline,
  'Safety': Icons.shield_outlined,
};

const statusColors = <String, (Color, Color)>{
  'Submitted': (Color(0xFFFFF0D6), Color(0xFFC77700)),
  'In Progress': (Color(0xFFE5E1FF), Color(0xFF4F3BD6)),
  'Resolved': (Color(0xFFDDF5E6), Color(0xFF1E8A4C)),
};
