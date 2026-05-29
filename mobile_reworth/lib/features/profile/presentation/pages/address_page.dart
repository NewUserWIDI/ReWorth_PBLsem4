import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AddressPage extends StatefulWidget {
  const AddressPage({super.key});

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final SupabaseClient _client = Supabase.instance.client;

  bool _isLoading = true;
  String? _error;
  List<_AddressItem> _items = const [];

  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }

  Future<void> _loadAddresses() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        setState(() {
          _items = const [];
          _isLoading = false;
        });
        return;
      }

      List<Map<String, dynamic>> rows = const [];
      try {
        final raw = await _client
            .from('alamat')
            .select()
            .eq('user_id', userId)
            .limit(3);
        rows = List<Map<String, dynamic>>.from(raw as List);
      } catch (_) {
        try {
          final raw = await _client
              .from('alamat')
              .select()
              .eq('id_masyarakat', userId)
              .limit(3);
          rows = List<Map<String, dynamic>>.from(raw as List);
        } catch (_) {
          final raw = await _client.from('alamat').select().limit(3);
          rows = List<Map<String, dynamic>>.from(raw as List);
        }
      }

      setState(() {
        _items = rows.map(_AddressItem.fromMap).toList();
      });
    } catch (e) {
      setState(() => _error = 'Gagal memuat alamat: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _showAddDialog() async {
    if (_items.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Maksimal 3 alamat per akun.',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
        ),
      );
      return;
    }

    final result = await showModalBottomSheet<_AddressFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFCFCFC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _AddressFormSheet(),
    );

    if (result == null) {
      return;
    }
    await _insertAddress(result);
  }

  Future<void> _insertAddress(_AddressFormResult data) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return;
    }

    final fullPayload = {
      'user_id': userId,
      'nama_penerima': data.receiver,
      'nomor_hp': data.phone,
      'jalan': data.street,
      'kelurahan': data.kelurahan,
      'kecamatan': data.kecamatan,
      'kota': data.city,
      'provinsi': data.province,
      'kode_pos': data.postalCode,
      'patokan': data.landmark,
      'created_at': DateTime.now().toIso8601String(),
    };

    final fallbackPayload = {
      'id_masyarakat': userId,
      'jalan': data.street,
      'kelurahan': data.kelurahan,
      'kecamatan': data.kecamatan,
      'patokan': data.landmark,
      'created_at': DateTime.now().toIso8601String(),
    };

    try {
      await _client.from('alamat').insert(fullPayload);
    } catch (_) {
      await _client.from('alamat').insert(fallbackPayload);
    }

    await _loadAddresses();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001F1A),
      body: Stack(
        children: [
          const _PremiumBackdrop(),
          SafeArea(
            child: Column(
              children: [
                _Header(
                  title: 'Alamat Saya',
                  onBack: () => context.pop(),
                ),
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xFFFCFCFC),
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(32),
                        topRight: Radius.circular(32),
                      ),
                    ),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _buildBody(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _items.length >= 3
          ? null
          : FloatingActionButton.extended(
              onPressed: _showAddDialog,
              backgroundColor: const Color(0xFF2E7D32),
              icon: const Icon(Icons.add_location_alt_outlined, color: Colors.white),
              label: Text(
                'Tambah Alamat',
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 22),
          child: Text(
            _error!,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 13.5,
              fontWeight: FontWeight.w500,
              color: const Color(0xFFD32F2F),
            ),
          ),
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 26),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.location_off_outlined,
                size: 52,
                color: Color(0xFF7CA06A),
              ),
              const SizedBox(height: 12),
              Text(
                'Belum ada alamat pengiriman',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tambahkan alamat agar checkout lebih cepat.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  color: const Color.fromRGBO(17, 17, 17, 0.6),
                ),
              ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: _showAddDialog,
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFF2E7D32),
                  minimumSize: const Size(178, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Text(
                  'Tambah Alamat',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAddresses,
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(20, 22, 20, 24),
        itemCount: _items.length,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final item = _items[index];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: const Color.fromRGBO(0, 0, 0, 0.05)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        item.receiver.isEmpty ? 'Alamat Pengiriman' : item.receiver,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111111),
                        ),
                      ),
                    ),
                    if (item.isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE9F7DD),
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Text(
                          'Utama',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: const Color(0xFF2E7D32),
                          ),
                        ),
                      ),
                  ],
                ),
                if (item.phone.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    item.phone,
                    style: GoogleFonts.poppins(
                      fontSize: 13,
                      color: const Color.fromRGBO(17, 17, 17, 0.65),
                    ),
                  ),
                ],
                const SizedBox(height: 8),
                Text(
                  item.fullAddress,
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    height: 1.45,
                    color: const Color.fromRGBO(17, 17, 17, 0.78),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _PremiumBackdrop extends StatelessWidget {
  const _PremiumBackdrop();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF003B2F), Color(0xFF002D24), Color(0xFF001F1A)],
              stops: [0, 0.52, 1],
            ),
          ),
        ),
        Positioned(
          top: -40,
          left: 0,
          right: 0,
          child: Center(
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(sigmaX: 135, sigmaY: 135),
              child: Container(
                width: 320,
                height: 320,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: const Color(0xFFB7F164).withValues(alpha: 0.16),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.title, required this.onBack});

  final String title;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: GestureDetector(
              onTap: onBack,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.10),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.16)),
                ),
                child: const Icon(
                  Icons.arrow_back_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ),
          Text(
            title,
            style: GoogleFonts.poppins(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressItem {
  const _AddressItem({
    required this.receiver,
    required this.phone,
    required this.street,
    required this.kelurahan,
    required this.kecamatan,
    required this.city,
    required this.province,
    required this.postalCode,
    required this.landmark,
    required this.isDefault,
  });

  final String receiver;
  final String phone;
  final String street;
  final String kelurahan;
  final String kecamatan;
  final String city;
  final String province;
  final String postalCode;
  final String landmark;
  final bool isDefault;

  String get fullAddress {
    final parts = [street, kelurahan, kecamatan, city, province, postalCode]
        .where((e) => e.trim().isNotEmpty)
        .toList();
    final basic = parts.join(', ');
    if (landmark.trim().isEmpty) {
      return basic;
    }
    if (basic.isEmpty) {
      return landmark;
    }
    return '$basic\nPatokan: $landmark';
  }

  factory _AddressItem.fromMap(Map<String, dynamic> map) {
    String read(List<String> keys) {
      for (final key in keys) {
        final value = map[key];
        if (value == null) continue;
        final text = value.toString().trim();
        if (text.isNotEmpty) return text;
      }
      return '';
    }

    bool readBool(List<String> keys) {
      for (final key in keys) {
        final value = map[key];
        if (value == null) continue;
        if (value is bool) return value;
        if (value is num) return value > 0;
        final text = value.toString().toLowerCase();
        if (text == 'true' || text == '1') return true;
      }
      return false;
    }

    return _AddressItem(
      receiver: read(['nama_penerima', 'receiver_name', 'nama']),
      phone: read(['nomor_hp', 'phone', 'no_hp']),
      street: read(['jalan', 'street', 'alamat']),
      kelurahan: read(['kelurahan']),
      kecamatan: read(['kecamatan', 'district']),
      city: read(['kota', 'city']),
      province: read(['provinsi', 'province']),
      postalCode: read(['kode_pos', 'postal_code']),
      landmark: read(['patokan', 'landmark']),
      isDefault: readBool(['is_default', 'utama']),
    );
  }
}

class _AddressFormResult {
  const _AddressFormResult({
    required this.receiver,
    required this.phone,
    required this.street,
    required this.kelurahan,
    required this.kecamatan,
    required this.city,
    required this.province,
    required this.postalCode,
    required this.landmark,
  });

  final String receiver;
  final String phone;
  final String street;
  final String kelurahan;
  final String kecamatan;
  final String city;
  final String province;
  final String postalCode;
  final String landmark;
}

class _AddressFormSheet extends StatefulWidget {
  const _AddressFormSheet();

  @override
  State<_AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<_AddressFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _receiver = TextEditingController();
  final _phone = TextEditingController();
  final _street = TextEditingController();
  final _kelurahan = TextEditingController();
  final _kecamatan = TextEditingController();
  final _city = TextEditingController();
  final _province = TextEditingController();
  final _postal = TextEditingController();
  final _landmark = TextEditingController();

  @override
  void dispose() {
    _receiver.dispose();
    _phone.dispose();
    _street.dispose();
    _kelurahan.dispose();
    _kecamatan.dispose();
    _city.dispose();
    _province.dispose();
    _postal.dispose();
    _landmark.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 18, 20, 18 + bottomInset),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Tambah Alamat',
                style: GoogleFonts.poppins(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 12),
              _field(_receiver, 'Nama Penerima'),
              const SizedBox(height: 10),
              _field(_phone, 'Nomor HP'),
              const SizedBox(height: 10),
              _field(
                _street,
                'Jalan / Alamat Lengkap',
                requiredField: true,
                maxLines: 2,
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _field(_kelurahan, 'Kelurahan')),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _field(
                      _kecamatan,
                      'Kecamatan',
                      requiredField: true,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(child: _field(_city, 'Kota')),
                  const SizedBox(width: 10),
                  Expanded(child: _field(_province, 'Provinsi')),
                ],
              ),
              const SizedBox(height: 10),
              _field(_postal, 'Kode Pos'),
              const SizedBox(height: 10),
              _field(
                _landmark,
                'Patokan',
                requiredField: true,
                maxLines: 2,
              ),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: _submit,
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF2E7D32),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: Text(
                    'Simpan Alamat',
                    style: GoogleFonts.poppins(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _field(
    TextEditingController controller,
    String label, {
    bool requiredField = false,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      style: GoogleFonts.poppins(fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: GoogleFonts.poppins(fontSize: 13),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
        ),
      ),
      validator: (value) {
        if (!requiredField) {
          return null;
        }
        if (value == null || value.trim().isEmpty) {
          return 'Wajib diisi';
        }
        return null;
      },
    );
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) {
      return;
    }
    Navigator.pop(
      context,
      _AddressFormResult(
        receiver: _receiver.text.trim(),
        phone: _phone.text.trim(),
        street: _street.text.trim(),
        kelurahan: _kelurahan.text.trim(),
        kecamatan: _kecamatan.text.trim(),
        city: _city.text.trim(),
        province: _province.text.trim(),
        postalCode: _postal.text.trim(),
        landmark: _landmark.text.trim(),
      ),
    );
  }
}
