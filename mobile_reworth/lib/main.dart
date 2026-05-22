import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://odtbyyhpqrczbvevflf.supabase.co',
    anonKey: 'eyJhbGci0iJIUzI1NiIsInR5cCI6IkpXVC39.eyJpc3Mi0iJzdXBhYmFzZSIsInJlZIi6Im9kd', // Ganti dengan key lengkap!
  );

  runApp(const ProviderScope(child: ReworthApp()));
}