import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaymentMethodPage extends StatefulWidget {
  const PaymentMethodPage({super.key});

  @override
  State<PaymentMethodPage> createState() => _PaymentMethodPageState();
}

class _PaymentMethodPageState extends State<PaymentMethodPage> {
  final SupabaseClient _client = Supabase.instance.client;
  bool _isLoading = true;
  String? _error;
  List<_BankCardItem> _items = const [];

  @override
  void initState() {
    super.initState();
    _loadCards();
  }

  Future<void> _loadCards() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        setState(() => _items = const []);
        return;
      }

      List<Map<String, dynamic>> rows = const [];
      try {
        final raw = await _client
            .from('kartu_pembayaran')
            .select()
            .eq('user_id', userId)
            .limit(3);
        rows = List<Map<String, dynamic>>.from(raw as List);
      } catch (_) {
        try {
          final raw = await _client
              .from('kartu_pembayaran')
              .select()
              .eq('id_masyarakat', userId)
              .limit(3);
          rows = List<Map<String, dynamic>>.from(raw as List);
        } catch (_) {
          final raw = await _client.from('kartu_pembayaran').select().limit(3);
          rows = List<Map<String, dynamic>>.from(raw as List);
        }
      }

      setState(() {
        _items = rows.map(_BankCardItem.fromMap).toList();
      });
    } catch (e) {
      setState(() => _error = 'Gagal memuat akun bank: $e');
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
            'Maksimal 3 akun bank per akun.',
            style: GoogleFonts.poppins(fontSize: 13),
          ),
        ),
      );
      return;
    }

    final result = await showModalBottomSheet<_BankCardFormResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: const Color(0xFFFCFCFC),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const _BankCardFormSheet(),
    );

    if (result == null) {
      return;
    }
    await _insertCard(result);
  }

  Future<void> _insertCard(_BankCardFormResult data) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      return;
    }

    final fullPayload = {
      'user_id': userId,
      'nama_bank': data.bankName,
      'nama_pemilik': data.ownerName,
      'nomor_rekening': data.accountNumber,
      'label': data.label,
      'created_at': DateTime.now().toIso8601String(),
    };
    final fallbackPayload = {
      'id_masyarakat': userId,
      'nama_bank': data.bankName,
      'nomor_rekening': data.accountNumber,
      'created_at': DateTime.now().toIso8601String(),
    };

    try {
      await _client.from('kartu_pembayaran').insert(fullPayload);
    } catch (_) {
      await _client.from('kartu_pembayaran').insert(fallbackPayload);
    }

    await _loadCards();
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
                  title: 'Akun Bank',
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
              icon: const Icon(Icons.add_card_rounded, color: Colors.white),
              label: Text(
                'Tambah Bank',
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
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.account_balance_wallet_outlined,
                size: 52,
                color: Color(0xFF7CA06A),
              ),
              const SizedBox(height: 12),
              Text(
                'Belum ada akun bank',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tambahkan akun bank untuk checkout Mini Market.',
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
                  minimumSize: const Size(174, 48),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
                child: Text(
                  'Tambah Bank',
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
      onRefresh: _loadCards,
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
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xFFEAF5E1),
                  ),
                  child: const Icon(
                    Icons.account_balance_rounded,
                    color: Color(0xFF2E7D32),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        item.bankName,
                        style: GoogleFonts.poppins(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: const Color(0xFF111111),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        item.maskedNumber,
                        style: GoogleFonts.poppins(
                          fontSize: 13.5,
                          color: const Color.fromRGBO(17, 17, 17, 0.7),
                        ),
                      ),
                      if (item.ownerName.isNotEmpty)
                        Text(
                          item.ownerName,
                          style: GoogleFonts.poppins(
                            fontSize: 12.5,
                            color: const Color.fromRGBO(17, 17, 17, 0.52),
                          ),
                        ),
                    ],
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

class _BankCardItem {
  const _BankCardItem({
    required this.bankName,
    required this.ownerName,
    required this.accountNumber,
    required this.isDefault,
  });

  final String bankName;
  final String ownerName;
  final String accountNumber;
  final bool isDefault;

  String get maskedNumber {
    final clean = accountNumber.replaceAll(RegExp(r'\s+'), '');
    if (clean.length <= 4) {
      return clean;
    }
    final suffix = clean.substring(clean.length - 4);
    return '**** **** $suffix';
  }

  factory _BankCardItem.fromMap(Map<String, dynamic> map) {
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

    return _BankCardItem(
      bankName: read(['nama_bank', 'bank_name', 'bank']).isEmpty
          ? 'Bank'
          : read(['nama_bank', 'bank_name', 'bank']),
      ownerName: read(['nama_pemilik', 'owner_name', 'nama']),
      accountNumber: read(['nomor_rekening', 'account_number', 'rekening']),
      isDefault: readBool(['is_default', 'utama']),
    );
  }
}

class _BankCardFormResult {
  const _BankCardFormResult({
    required this.bankName,
    required this.ownerName,
    required this.accountNumber,
    required this.label,
  });

  final String bankName;
  final String ownerName;
  final String accountNumber;
  final String label;
}

class _BankCardFormSheet extends StatefulWidget {
  const _BankCardFormSheet();

  @override
  State<_BankCardFormSheet> createState() => _BankCardFormSheetState();
}

class _BankCardFormSheetState extends State<_BankCardFormSheet> {
  final _formKey = GlobalKey<FormState>();
  final _bank = TextEditingController();
  final _owner = TextEditingController();
  final _number = TextEditingController();
  final _label = TextEditingController();

  @override
  void dispose() {
    _bank.dispose();
    _owner.dispose();
    _number.dispose();
    _label.dispose();
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
                'Tambah Akun Bank',
                style: GoogleFonts.poppins(
                  fontSize: 19,
                  fontWeight: FontWeight.w700,
                  color: const Color(0xFF111111),
                ),
              ),
              const SizedBox(height: 12),
              _field(_bank, 'Nama Bank', requiredField: true),
              const SizedBox(height: 10),
              _field(_owner, 'Nama Pemilik Rekening', requiredField: true),
              const SizedBox(height: 10),
              _field(_number, 'Nomor Rekening', requiredField: true),
              const SizedBox(height: 10),
              _field(_label, 'Label (opsional, contoh: Utama)'),
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
                    'Simpan Akun Bank',
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
  }) {
    return TextFormField(
      controller: controller,
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
      _BankCardFormResult(
        bankName: _bank.text.trim(),
        ownerName: _owner.text.trim(),
        accountNumber: _number.text.trim(),
        label: _label.text.trim(),
      ),
    );
  }
}

