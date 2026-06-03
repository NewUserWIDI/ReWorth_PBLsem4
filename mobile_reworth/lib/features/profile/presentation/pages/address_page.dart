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
  static const int _maxAddressCount = 3;

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

      final rows = await _fetchAddressRows(userId);
      final items = rows.map(_AddressItem.fromMap).toList()
        ..sort((a, b) => (b.isDefault ? 1 : 0).compareTo(a.isDefault ? 1 : 0));

      if (!mounted) {
        return;
      }
      setState(() {
        _items = items;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }
      setState(() => _error = 'Gagal memuat alamat: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<List<Map<String, dynamic>>> _fetchAddressRows(String userId) async {
    final fetchers = [
      () => _client
          .from('alamat')
          .select()
          .eq('id_masyarakat', userId)
          .limit(_maxAddressCount)
          .timeout(const Duration(seconds: 8)),
      () => _client
          .from('alamat')
          .select()
          .eq('user_id', userId)
          .limit(_maxAddressCount)
          .timeout(const Duration(seconds: 8)),
    ];

    Object? lastError;
    for (final fetch in fetchers) {
      try {
        final raw = await fetch();
        return List<Map<String, dynamic>>.from(raw as List);
      } catch (e) {
        lastError = e;
      }
    }

    if (lastError != null) {
      throw lastError;
    }
    return const [];
  }

  Future<void> _showAddDialog() async {
    if (_items.length >= _maxAddressCount) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF412020),
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
      backgroundColor: const Color(0xFF0A1E19),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => const _AddressFormSheet(),
    );

    if (result == null) {
      return;
    }

    try {
      await _insertAddress(result);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF173A2C),
          content: Text(
            'Alamat berhasil ditambahkan.',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFF7A1C1C),
          content: Text(
            'Gagal menambah alamat: $e',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
        ),
      );
    }
  }

  Future<void> _insertAddress(_AddressFormResult data) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      throw Exception('User belum login');
    }

    final now = DateTime.now().toIso8601String();
    final isPrimary = _items.isEmpty;
    final variants = <Map<String, dynamic>>[
      {
        'id_masyarakat': userId,
        'nama_penerima': data.receiver,
        'no_hp': data.phone,
        'jalan': data.street,
        'kelurahan': data.kelurahan,
        'kecamatan': data.kecamatan,
        'kota': data.city,
        'provinsi': data.province,
        'kode_pos': data.postalCode,
        'patokan': data.landmark,
        'alamat_utama': isPrimary,
        'created_at': now,
        'updated_at': now,
      },
      {
        'id_masyarakat': userId,
        'nama_penerima': data.receiver,
        'nomor_hp': data.phone,
        'jalan': data.street,
        'kelurahan': data.kelurahan,
        'kecamatan': data.kecamatan,
        'kota': data.city,
        'provinsi': data.province,
        'kode_pos': data.postalCode,
        'patokan': data.landmark,
        'utama': isPrimary,
        'created_at': now,
        'updated_at': now,
      },
      {
        'user_id': userId,
        'nama_penerima': data.receiver,
        'no_hp': data.phone,
        'jalan': data.street,
        'kelurahan': data.kelurahan,
        'kecamatan': data.kecamatan,
        'kota': data.city,
        'provinsi': data.province,
        'kode_pos': data.postalCode,
        'patokan': data.landmark,
        'is_default': isPrimary,
        'created_at': now,
        'updated_at': now,
      },
    ];

    Object? lastError;
    for (final payload in variants) {
      try {
        await _client.from('alamat').insert(payload);
        await _loadAddresses();
        return;
      } catch (e) {
        lastError = e;
      }
    }

    throw lastError ?? Exception('Gagal menyimpan alamat');
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
                _Header(title: 'Alamat Saya', onBack: () => context.pop()),
                const SizedBox(height: 8),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        )
                      : _buildBody(),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _items.length >= _maxAddressCount
          ? null
          : Container(
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.white, Color(0xFFDCEBD5)],
                ),
                borderRadius: BorderRadius.circular(30),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.24),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: FloatingActionButton.extended(
                onPressed: _showAddDialog,
                backgroundColor: Colors.transparent,
                elevation: 0,
                icon: const Icon(
                  Icons.add_location_alt_rounded,
                  color: Color(0xFF082018),
                ),
                label: Text(
                  'Tambah Alamat',
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w700,
                    color: const Color(0xFF082018),
                  ),
                ),
              ),
            ),
    );
  }

  Widget _buildBody() {
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                _error!,
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  color: const Color(0xFFFFD4D4),
                ),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: _loadAddresses,
                style: OutlinedButton.styleFrom(
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.24)),
                  foregroundColor: Colors.white,
                ),
                child: const Text('Coba lagi'),
              ),
            ],
          ),
        ),
      );
    }

    if (_items.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 84,
                height: 84,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Colors.white.withValues(alpha: 0.20),
                      Colors.white.withValues(alpha: 0.06),
                    ],
                  ),
                ),
                child: const Icon(
                  Icons.location_on_outlined,
                  size: 40,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                'Belum ada alamat pengiriman',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tambahkan alamat agar checkout bisa langsung memakai data dari profil Anda.',
                textAlign: TextAlign.center,
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  color: Colors.white.withValues(alpha: 0.68),
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 18),
              FilledButton(
                onPressed: _showAddDialog,
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF082018),
                  minimumSize: const Size(180, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Text(
                  'Tambah Alamat',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
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
      color: Colors.white,
      backgroundColor: const Color(0xFF0A1E19),
      child: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        itemCount: _items.length + 1,
        separatorBuilder: (context, index) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          if (index == 0) {
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.info_outline_rounded,
                    color: Colors.white,
                    size: 18,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Alamat di sini akan otomatis muncul di checkout.',
                      style: GoogleFonts.poppins(
                        fontSize: 12.5,
                        color: Colors.white.withValues(alpha: 0.74),
                      ),
                    ),
                  ),
                ],
              ),
            );
          }

          final item = _items[index - 1];
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF0A1E19).withValues(alpha: 0.84),
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: Colors.white.withValues(alpha: 0.10)),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.20),
                  blurRadius: 16,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(14),
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.white.withValues(alpha: 0.20),
                            Colors.white.withValues(alpha: 0.08),
                          ],
                        ),
                      ),
                      child: const Icon(
                        Icons.location_on_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            item.receiver.isEmpty
                                ? 'Alamat Pengiriman'
                                : item.receiver,
                            style: GoogleFonts.poppins(
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          if (item.phone.isNotEmpty) ...[
                            const SizedBox(height: 4),
                            Text(
                              item.phone,
                              style: GoogleFonts.poppins(
                                fontSize: 12.5,
                                color: Colors.white.withValues(alpha: 0.70),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (item.isDefault)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(999),
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.16),
                          ),
                        ),
                        child: Text(
                          'Utama',
                          style: GoogleFonts.poppins(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  item.fullAddress,
                  style: GoogleFonts.poppins(
                    fontSize: 13.5,
                    height: 1.5,
                    color: Colors.white.withValues(alpha: 0.82),
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
                  color: const Color(0xFFB7F164).withValues(alpha: 0.14),
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
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: IconButton(
              onPressed: onBack,
              padding: EdgeInsets.zero,
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 28,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AddressItem {
  const _AddressItem({
    required this.id,
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

  final String id;
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
    final parts = [
      street,
      kelurahan,
      kecamatan,
      city,
      province,
      postalCode,
    ].where((value) => value.trim().isNotEmpty).toList();

    final base = parts.join(', ');
    if (landmark.trim().isEmpty) {
      return base;
    }
    if (base.isEmpty) {
      return 'Patokan: $landmark';
    }
    return '$base\nPatokan: $landmark';
  }

  factory _AddressItem.fromMap(Map<String, dynamic> map) {
    String read(List<String> keys) {
      for (final key in keys) {
        final value = map[key];
        if (value == null) {
          continue;
        }
        final text = value.toString().trim();
        if (text.isNotEmpty) {
          return text;
        }
      }
      return '';
    }

    bool readBool(List<String> keys) {
      for (final key in keys) {
        final value = map[key];
        if (value == null) {
          continue;
        }
        if (value is bool) {
          return value;
        }
        if (value is num) {
          return value > 0;
        }
        final text = value.toString().toLowerCase();
        if (text == 'true' || text == '1') {
          return true;
        }
      }
      return false;
    }

    return _AddressItem(
      id: read(['id_alamat', 'id', 'address_id']),
      receiver: read(['nama_penerima', 'receiver_name', 'nama']),
      phone: read(['no_hp', 'nomor_hp', 'phone']),
      street: read(['jalan', 'street', 'alamat']),
      kelurahan: read(['kelurahan']),
      kecamatan: read(['kecamatan', 'district']),
      city: read(['kota', 'city']),
      province: read(['provinsi', 'province']),
      postalCode: read(['kode_pos', 'postal_code']),
      landmark: read(['patokan', 'landmark']),
      isDefault: readBool(['alamat_utama', 'is_default', 'utama']),
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
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF0A1E19),
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 20, 20, 20 + bottomInset),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 50,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.20),
                      borderRadius: BorderRadius.circular(999),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  'Tambah Alamat',
                  style: GoogleFonts.poppins(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 18),
                _field(_receiver, 'Nama Penerima'),
                const SizedBox(height: 14),
                _field(_phone, 'Nomor HP'),
                const SizedBox(height: 14),
                _field(
                  _street,
                  'Jalan / Alamat Lengkap',
                  requiredField: true,
                  maxLines: 2,
                ),
                const SizedBox(height: 14),
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
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(child: _field(_city, 'Kota')),
                    const SizedBox(width: 10),
                    Expanded(child: _field(_province, 'Provinsi')),
                  ],
                ),
                const SizedBox(height: 14),
                _field(_postal, 'Kode Pos'),
                const SizedBox(height: 14),
                _field(_landmark, 'Patokan', requiredField: true, maxLines: 2),
                const SizedBox(height: 20),
                Container(
                  width: double.infinity,
                  height: 54,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Colors.white, Color(0xFFDCEBD5)],
                    ),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: ElevatedButton(
                    onPressed: _submit,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.transparent,
                      shadowColor: Colors.transparent,
                      foregroundColor: const Color(0xFF082018),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(18),
                      ),
                    ),
                    child: Text(
                      'Simpan Alamat',
                      style: GoogleFonts.poppins(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: GoogleFonts.poppins(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Colors.white.withValues(alpha: 0.80),
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          maxLines: maxLines,
          style: GoogleFonts.poppins(fontSize: 14, color: Colors.white),
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFF1A2A25),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.12),
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.28),
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFFD32F2F)),
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
        ),
      ],
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
