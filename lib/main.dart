import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://odtbyyhqyprczbfevflf.supabase.co',
    anonKey: 'sb_publishable_4b3SD4MijRDq3SgcojL41A_GFCgMjD_',
  );

  runApp(const ProviderScope(child: ReworthApp()));
}