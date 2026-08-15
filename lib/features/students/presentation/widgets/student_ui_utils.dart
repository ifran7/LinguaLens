import 'dart:io';

import 'package:flutter/material.dart';

Color generateAvatarColor(String name) {
  const colors = [
    Color(0xFF5C6BC0),
    Color(0xFF26A69A),
    Color(0xFFEF5350),
    Color(0xFFAB47BC),
    Color(0xFF42A5F5),
    Color(0xFFFF7043),
    Color(0xFF66BB6A),
    Color(0xFFEC407A),
  ];
  final index =
      name.codeUnits.fold<int>(0, (sum, code) => sum + code) % colors.length;
  return colors[index];
}

String studentInitials(String name) {
  final parts = name
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .toList();
  if (parts.isEmpty) return '?';
  if (parts.length == 1) {
    return parts.first.characters.take(2).toString().toUpperCase();
  }
  return '${parts.first.characters.first}${parts.last.characters.first}'
      .toUpperCase();
}

bool hasLocalPhoto(String path) => path.isNotEmpty && File(path).existsSync();

String formatPhoneForWhatsApp(String phone) {
  var digits = phone.replaceAll(RegExp(r'[^0-9+]'), '');
  if (digits.startsWith('+')) digits = digits.substring(1);
  if (digits.startsWith('0')) digits = '880${digits.substring(1)}';
  if (!digits.startsWith('880')) digits = '880$digits';
  return digits;
}
