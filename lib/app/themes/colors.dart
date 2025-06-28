// lib/app/theme/colors.dart
import 'package:flutter/material.dart';

class AppColors {
  // --- Background / Base Colors ---
  static const Color primaryBackground = Color(0xFF1A1A1A); // Hitam gelap
  static const Color secondaryBackground = Color(0xFF2C2C2C); // Abu-abu gelap
  static const Color glassBackgroundStart = Color(0xFFFFFFFF); // Putih untuk awal gradien kaca
  static const Color glassBackgroundEnd = Color(0xFFCCCCCC);   // Abu-abu terang untuk akhir gradien kaca

  // --- Text Colors ---
  static const Color primaryText = Color(0xFFFFFFFF);     // Putih
  static const Color secondaryText = Color(0xFFCCCCCC);   // Abu-abu terang untuk teks sekunder
  static const Color tertiaryText = Color(0xFFAAAAAA);    // Abu-abu lebih gelap untuk teks pelengkap

  // --- Accent / Uplifting Colors (Warna Semangat) ---
  static const Color accentBlue = Color(0xFF87CEEB);     // Biru Langit (Soft Blue)
  static const Color accentGreen = Color(0xFF90EE90);    // Hijau Mint (Soft Green)
  static const Color accentPurple = Color(0xFFB19CD9);   // Ungu Lavender (Soft Purple)
  static const Color accentOrange = Color(0xFFFFA07A);   // Orange Salmon (Soft Orange)
  static const Color accentPink = Color(0xFFFDA4B9);     // Merah Jambu Lembut (Soft Pink)

  // --- Status Colors (Jika diperlukan) ---
  static const Color success = Color(0xFF4CAF50);    // Hijau
  static const Color warning = Color(0xFFFFC107);    // Kuning
  static const Color error = Color(0xFFF44336);      // Merah
}