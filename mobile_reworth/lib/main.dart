import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://odtbyyhqyprczbfevflf.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9kdGJ5eWhxeXByY3piZmV2ZmxmIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzgxNTU4MjksImV4cCI6MjA5MzczMTgyOX0.Yx84RnYTa8h-RLYkxKO2wWY60ZcDSTYYO_vqB7Bqv14',
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final supabase = Supabase.instance.client;

  List<dynamic> data = [];

  @override
  void initState() {
    super.initState();
    ambilData();
  }

  Future<void> tambahData() async {
    try {
      await supabase.from('alamat').insert({
        'no_hp': '08123456789',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Data berhasil ditambahkan'),
        ),
      );

      ambilData();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: $e'),
        ),
      );
    }
  }

  Future<void> ambilData() async {
    try {
      final response = await supabase
          .from('alamat')
          .select();

      setState(() {
        data = response;
      });
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Flutter + Supabase"),
      ),
      body: data.isEmpty
          ? const Center(
              child: Text("Belum ada data"),
            )
          : ListView.builder(
              itemCount: data.length,
              itemBuilder: (context, index) {
                final item = data[index];

                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(
                    item['no_hp'].toString(),
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: tambahData,
        child: const Icon(Icons.add),
      ),
    );
  }
}