// lib/main.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'app/app.dart'; 
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Inisialisasi Supabase
  await Supabase.initialize(
    url: 'https://klxqocgxnjxqaonyffei.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImtseHFvY2d4bmp4cWFvbnlmZmVpIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTExODQ4NjAsImV4cCI6MjA2Njc2MDg2MH0.BcYFMnf_nXKA0R1Xi0x_UpJW0ib3a9GqLiWcWuxdl7U', // Anon Key Anda
    debug: true,
  );

  // --- SOLUSI UNTUK LocaleDataException ---
  await initializeDateFormatting('id_ID', null); 

  runApp(
    const ProviderScope(
      child: App(), 
    ),
  );
}