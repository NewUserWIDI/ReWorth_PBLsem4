import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:latlong2/latlong.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_map/flutter_map.dart';

class ReportPage extends StatefulWidget {
  const ReportPage({super.key});

  @override
  State<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends State<ReportPage> {
  final SupabaseClient _client = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();

  final TextEditingController _jalanController = TextEditingController();
  final TextEditingController _kelurahanController = TextEditingController();
  final TextEditingController _kecamatanController = TextEditingController();
  final TextEditingController _patokanController = TextEditingController();
  final TextEditingController _deskripsiController = TextEditingController();
  final TextEditingController _jumlahController = TextEditingController();

  int _currentStep = 0;
  bool _isLocationLoading = false;
  bool _isSubmitting = false;
  bool _useManualLocation = false;

  double? _latitude;
  double? _longitude;
  String? _kota;
  String? _provinsi;
  String? _locationError;
  XFile? _selectedImage;
  String? _selectedWasteType;
  String? _selectedSeverity;

  static const List<String> _stepTitles = [
    'Informasi',
    'Lokasi',
    'Detail',
    'Konfirmasi',
  ];

  static const List<String> _wasteTypes = [
    'organik',
    'anorganik',
    'b3',
    'lainnya',
  ];

  static const List<String> _severityLevels = [
    'rendah',
    'sedang',
    'tinggi',
  ];

  @override
  void initState() {
    super.initState();
    _resolveLocation();
  }

  @override
  void dispose() {
    _jalanController.dispose();
    _kelurahanController.dispose();
    _kecamatanController.dispose();
    _patokanController.dispose();
    _deskripsiController.dispose();
    _jumlahController.dispose();
    super.dispose();
  }

  Future<void> _resolveLocation() async {
    setState(() {
      _isLocationLoading = true;
      _locationError = null;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationError = 'Layanan lokasi tidak aktif. Aktifkan GPS terlebih dahulu.';
          _useManualLocation = true;
          _isLocationLoading = false;
        });
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() {
          _locationError = 'Izin lokasi ditolak. Isi lokasi manual untuk melanjutkan.';
          _useManualLocation = true;
          _isLocationLoading = false;
        });
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );
      final place = placemarks.isNotEmpty ? placemarks.first : null;

      setState(() {
        _latitude = position.latitude;
        _longitude = position.longitude;
        _kota = place?.locality;
        _provinsi = place?.administrativeArea;
        _jalanController.text = (place?.street ?? '').trim();
        _kelurahanController.text = (place?.subLocality ?? '').trim();
        _kecamatanController.text = (place?.subAdministrativeArea ?? '').trim();
        _isLocationLoading = false;
        _locationError = null;
      });
    } catch (_) {
      setState(() {
        _locationError = 'Gagal mendeteksi lokasi. Silakan isi manual.';
        _useManualLocation = true;
        _isLocationLoading = false;
      });
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final image = await _picker.pickImage(
      source: source,
      imageQuality: 78,
      maxWidth: 1800,
    );
    if (image == null) return;
    setState(() {
      _selectedImage = image;
    });
  }

  bool _validateLocationStep() {
    final jalan = _jalanController.text.trim();
    final kelurahan = _kelurahanController.text.trim();
    final kecamatan = _kecamatanController.text.trim();
    final patokan = _patokanController.text.trim();

    if (jalan.isEmpty || kelurahan.isEmpty || kecamatan.isEmpty || patokan.isEmpty) {
      setState(() {
        _locationError = 'Lengkapi jalan, kelurahan, kecamatan, dan patokan.';
      });
      return false;
    }

    if (_latitude == null || _longitude == null) {
      setState(() {
        _locationError =
            'Koordinat belum tersedia. Nyalakan GPS atau gunakan Ubah Lokasi.';
      });
      return false;
    }

    setState(() {
      _locationError = null;
    });
    return true;
  }

  bool _validateDetailStep() {
    if (_selectedImage == null) {
      _showSnack('Foto sampah wajib diunggah.');
      return false;
    }
    if (_selectedWasteType == null) {
      _showSnack('Pilih jenis sampah terlebih dahulu.');
      return false;
    }
    if (_selectedSeverity == null) {
      _showSnack('Pilih tingkat keparahan terlebih dahulu.');
      return false;
    }

    final deskripsi = _deskripsiController.text.trim();
    if (deskripsi.isEmpty) {
      _showSnack('Deskripsi wajib diisi.');
      return false;
    }
    if (deskripsi.length > 200) {
      _showSnack('Deskripsi maksimal 200 karakter.');
      return false;
    }

    return true;
  }

  void _onPrimaryAction() {
    if (_currentStep == 0) {
      setState(() => _currentStep = 1);
      return;
    }
    if (_currentStep == 1) {
      if (_validateLocationStep()) {
        setState(() => _currentStep = 2);
      }
      return;
    }
    if (_currentStep == 2) {
      if (_validateDetailStep()) {
        setState(() => _currentStep = 3);
      }
      return;
    }
    _submitReport();
  }

  Future<String> _uploadReportImage(String userId) async {
    final image = _selectedImage;
    if (image == null) {
      throw Exception('Foto belum dipilih.');
    }

    final bytes = await File(image.path).readAsBytes();
    final storagePath = 'laporan/$userId/${DateTime.now().millisecondsSinceEpoch}.jpg';

    await _client.storage.from('laporan-sampah').uploadBinary(
          storagePath,
          bytes,
          fileOptions: const FileOptions(
            contentType: 'image/jpeg',
            upsert: true,
          ),
        );

    return _client.storage.from('laporan-sampah').getPublicUrl(storagePath);
  }

  Future<void> _submitReport() async {
    if (_isSubmitting) return;
    if (!_validateLocationStep() || !_validateDetailStep()) return;

    final user = _client.auth.currentUser;
    if (user == null) {
      _showSnack('Sesi login tidak ditemukan. Silakan login ulang.');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final photoUrl = await _uploadReportImage(user.id);

      await _client.from('laporan').insert({
        'id_masyarakat': user.id,
        'foto_sampah': photoUrl,
        'latitude': _latitude,
        'longitude': _longitude,
        'jalan': _jalanController.text.trim(),
        'kelurahan': _kelurahanController.text.trim(),
        'kecamatan': _kecamatanController.text.trim(),
        'patokan': _patokanController.text.trim(),
        'deskripsi': _deskripsiController.text.trim(),
        'jenis_sampah': _selectedWasteType,
        'tingkat_keparahan': _selectedSeverity,
        'status_laporan': 'pending',
        'poin_diberikan': 0,
        'alasan_ditolak': null,
        'waktu_lapor': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      });

      if (!mounted) return;
      await _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      _showSnack('Gagal mengirim laporan: $e');
    } finally {
      if (mounted) {
        setState(() => _isSubmitting = false);
      }
    }
  }

  Future<void> _showSuccessDialog() async {
    await showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.65),
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.transparent,
          child: Container(
            padding: const EdgeInsets.fromLTRB(22, 26, 22, 20),
            decoration: BoxDecoration(
              color: const Color(0xFF0C221A),
              borderRadius: BorderRadius.circular(28),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.10),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 30,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 66,
                  height: 66,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF94FF38).withValues(alpha: 0.22),
                  ),
                  child: const Icon(
                    Icons.check_rounded,
                    size: 38,
                    color: Color(0xFF94FF38),
                  ),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Laporan Terkirim',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Laporan Anda berhasil dikirim dan akan diverifikasi oleh petugas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 15,
                    height: 1.45,
                    color: Colors.white.withValues(alpha: 0.78),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Reward 10 poin diberikan setelah laporan dinyatakan valid.',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 13,
                    height: 1.5,
                    color: Color(0xFF94FF38),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      context.go('/report-history');
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF94FF38),
                      foregroundColor: const Color(0xFF0A1A12),
                      minimumSize: const Size.fromHeight(52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: const Text(
                      'Lihat Status',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    context.go('/home');
                  },
                  child: Text(
                    'Kembali ke Beranda',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.84),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF173A2C),
        behavior: SnackBarBehavior.floating,
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001F1A),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF003B2F),
                  Color(0xFF002D24),
                  Color(0xFF001F1A),
                ],
              ),
            ),
          ),
          Positioned(
            top: -160,
            left: 0,
            right: 0,
            child: Center(
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: 110, sigmaY: 110),
                child: Container(
                  width: 360,
                  height: 360,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: RadialGradient(
                      colors: [
                        const Color(0xFFB5FF77).withValues(alpha: 0.38),
                        const Color(0xFF5BE22F).withValues(alpha: 0.18),
                        Colors.transparent,
                      ],
                      stops: const [0.0, 0.42, 1.0],
                    ),
                  ),
                ),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 22),
                    child: Column(
                      children: [
                        _buildStepper(),
                        const SizedBox(height: 22),
                        _buildStepBody(),
                        const SizedBox(height: 24),
                        _buildPrimaryButton(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
      child: Row(
        children: [
          GestureDetector(
            onTap: () {
              if (_currentStep > 0) {
                setState(() => _currentStep -= 1);
                return;
              }
              context.pop();
            },
            child: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.08),
                border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Text(
            'Laporkan Sampah',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepper() {
    return Column(
      children: [
        SizedBox(
          height: 36,
          child: Stack(
            children: [
              Positioned(
                left: 22,
                right: 22,
                top: 17,
                child: Container(
                  height: 3,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.18),
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: List.generate(_stepTitles.length, (index) {
                  final isActive = index <= _currentStep;
                  return Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isActive
                          ? const Color(0xFF94FF38)
                          : Colors.white.withValues(alpha: 0.10),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isActive
                              ? const Color(0xFF0B2116)
                              : Colors.white.withValues(alpha: 0.8),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(_stepTitles.length, (index) {
            final isActive = index == _currentStep;
            return SizedBox(
              width: 72,
              child: Text(
                _stepTitles[index],
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: isActive
                      ? const Color(0xFF94FF38)
                      : Colors.white.withValues(alpha: 0.52),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildStepBody() {
    switch (_currentStep) {
      case 0:
        return _buildInformasiStep();
      case 1:
        return _buildLokasiStep();
      case 2:
        return _buildDetailStep();
      default:
        return _buildKonfirmasiStep();
    }
  }

  Widget _buildInformasiStep() {
    return Column(
      children: [
        Image.asset(
          'assets/images/lapor_sampah.png',
          width: 210,
          height: 210,
          fit: BoxFit.contain,
          errorBuilder: (_, _, _) {
            return const Icon(
              Icons.info_outline_rounded,
              size: 120,
              color: Color(0xFF94FF38),
            );
          },
        ),
        const SizedBox(height: 12),
        const Text(
          'Sebelum Melapor',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Pastikan laporan Anda sesuai kriteria agar dapat diproses cepat oleh petugas.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            height: 1.6,
            color: Colors.white.withValues(alpha: 0.72),
          ),
        ),
        const SizedBox(height: 20),
        _infoRuleCard(
          icon: Icons.check_rounded,
          iconColor: const Color(0xFF94FF38),
          text: 'Sampah mengganggu pejalan kaki atau pengguna jalan.',
        ),
        _infoRuleCard(
          icon: Icons.check_rounded,
          iconColor: const Color(0xFF94FF38),
          text: 'Sampah menyumbat gorong gorong atau drainase.',
        ),
        _infoRuleCard(
          icon: Icons.check_rounded,
          iconColor: const Color(0xFF94FF38),
          text: 'Sampah mengotori lingkungan secara signifikan atau memicu polusi.',
        ),
        _infoRuleCard(
          icon: Icons.check_rounded,
          iconColor: const Color(0xFFFFD54F),
          text: 'Potensi merusak fasilitas umum atau membahayakan.',
        ),
        _infoRuleCard(
          icon: Icons.close_rounded,
          iconColor: const Color(0xFFFFA14A),
          text: 'Hindari melaporkan sampah kecil yang tidak berdampak signifikan.',
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: const Color(0xFF0D2B21).withValues(alpha: 0.72),
            borderRadius: BorderRadius.circular(22),
            border: Border.all(
              color: const Color(0xFF94FF38).withValues(alpha: 0.35),
            ),
          ),
          child: RichText(
            text: TextSpan(
              style: TextStyle(
                fontSize: 16,
                height: 1.5,
                color: Colors.white.withValues(alpha: 0.85),
              ),
              children: const [
                TextSpan(
                  text:
                      'Laporan yang valid akan diverifikasi petugas dan Anda mendapatkan ',
                ),
                TextSpan(
                  text: '10 poin!',
                  style: TextStyle(
                    color: Color(0xFF94FF38),
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _infoRuleCard({
    required IconData icon,
    required Color iconColor,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: iconColor, width: 2),
            ),
            child: Icon(icon, color: iconColor, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                height: 1.45,
                color: Colors.white.withValues(alpha: 0.85),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLokasiStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (_isLocationLoading)
          const Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 32),
              child: CircularProgressIndicator(color: Color(0xFF94FF38)),
            ),
          )
        else
          _buildMapPreview(),
        const SizedBox(height: 14),
        _buildLocationCard(),
        if (_locationError != null) ...[
          const SizedBox(height: 10),
          Text(
            _locationError!,
            style: const TextStyle(
              color: Color(0xFFFFA14A),
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildMapPreview() {
    final lat = _latitude;
    final lng = _longitude;
    if (lat == null || lng == null) {
      return Container(
        height: 230,
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white.withValues(alpha: 0.06),
          border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        ),
        child: Center(
          child: Text(
            'Lokasi belum tersedia',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.74),
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: SizedBox(
        height: 230,
        width: double.infinity,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: LatLng(lat, lng),
            initialZoom: 16,
            interactionOptions: const InteractionOptions(
              flags: InteractiveFlag.none,
            ),
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.reworth.mobile',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: LatLng(lat, lng),
                  width: 42,
                  height: 42,
                  child: const Icon(
                    Icons.location_on_rounded,
                    color: Color(0xFF94FF38),
                    size: 42,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    final addressLine =
        '${_jalanController.text}, ${_kelurahanController.text}, ${_kecamatanController.text}';
    final cityLine = [_kota, _provinsi].whereType<String>().where((e) => e.isNotEmpty).join(', ');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0A1E19).withValues(alpha: 0.78),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: const Color(0xFF94FF38).withValues(alpha: 0.14),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFF5BE22F),
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Lokasi Sampah',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      [
                        if (addressLine.trim().replaceAll(',', '').isNotEmpty) addressLine,
                        if (cityLine.isNotEmpty) cityLine,
                      ].join(', '),
                      style: TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        color: Colors.white.withValues(alpha: 0.74),
                      ),
                    ),
                  ],
                ),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _useManualLocation = !_useManualLocation;
                  });
                },
                child: const Text(
                  'Ubah\nLokasi',
                  style: TextStyle(
                    color: Color(0xFF5BE22F),
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          if (_useManualLocation || _latitude == null || _longitude == null) ...[
            _glassField(
              controller: _jalanController,
              hint: 'Jalan',
            ),
            const SizedBox(height: 10),
            _glassField(
              controller: _kelurahanController,
              hint: 'Kelurahan',
            ),
            const SizedBox(height: 10),
            _glassField(
              controller: _kecamatanController,
              hint: 'Kecamatan',
            ),
            const SizedBox(height: 10),
          ],
          _glassField(
            controller: _patokanController,
            hint: 'Patokan lokasi',
          ),
        ],
      ),
    );
  }

  Widget _buildDetailStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Foto Sampah *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Ambil foto sampah yang ingin dilaporkan',
          style: TextStyle(
            fontSize: 14,
            color: Colors.white.withValues(alpha: 0.68),
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            _photoPreviewCard(_selectedImage),
            const SizedBox(width: 10),
            _pickPhotoCard(
              icon: Icons.add_a_photo_outlined,
              label: 'Kamera',
              onTap: () => _pickImage(ImageSource.camera),
            ),
            const SizedBox(width: 10),
            _pickPhotoCard(
              icon: Icons.photo_library_outlined,
              label: 'Galeri',
              onTap: () => _pickImage(ImageSource.gallery),
            ),
          ],
        ),
        const SizedBox(height: 22),
        const Text(
          'Jenis Sampah *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _wasteTypes
              .map(
                (type) => _chipButton(
                  label: _capitalize(type),
                  selected: _selectedWasteType == type,
                  onTap: () => setState(() => _selectedWasteType = type),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 20),
        const Text(
          'Tingkat Keparahan *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: _severityLevels
              .map(
                (level) => _chipButton(
                  label: _capitalize(level),
                  selected: _selectedSeverity == level,
                  onTap: () => setState(() => _selectedSeverity = level),
                ),
              )
              .toList(),
        ),
        const SizedBox(height: 20),
        const Text(
          'Deskripsi *',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.25),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.white.withValues(alpha: 0.14)),
          ),
          child: TextField(
            controller: _deskripsiController,
            maxLines: 5,
            maxLength: 200,
            style: const TextStyle(color: Colors.white, fontSize: 16),
            decoration: InputDecoration(
              hintText: 'Tuliskan deskripsi kondisi sampah...',
              hintStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.45),
                fontSize: 15,
              ),
              border: InputBorder.none,
              counterStyle: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 13,
              ),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Jumlah Estimasi',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        _glassField(
          controller: _jumlahController,
          hint: 'Contoh: Banyak (> 1 karung / volume besar)',
        ),
      ],
    );
  }

  Widget _buildKonfirmasiStep() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Konfirmasi Data Laporan',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 14),
          _summaryRow('Jenis Sampah', _capitalize(_selectedWasteType ?? '-')),
          _summaryRow('Keparahan', _capitalize(_selectedSeverity ?? '-')),
          _summaryRow('Jalan', _jalanController.text.trim()),
          _summaryRow('Kelurahan', _kelurahanController.text.trim()),
          _summaryRow('Kecamatan', _kecamatanController.text.trim()),
          _summaryRow('Patokan', _patokanController.text.trim()),
          _summaryRow('Deskripsi', _deskripsiController.text.trim()),
          const SizedBox(height: 10),
          Text(
            'Status awal laporan: pending\nPoin diberikan setelah laporan dinyatakan valid oleh petugas.',
            style: TextStyle(
              fontSize: 13,
              height: 1.5,
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
        ],
      ),
    );
  }

  Widget _summaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.65),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? '-' : value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _photoPreviewCard(XFile? image) {
    return Container(
      width: 94,
      height: 94,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        color: Colors.white.withValues(alpha: 0.05),
      ),
      child: image == null
          ? Icon(
              Icons.image_outlined,
              color: Colors.white.withValues(alpha: 0.5),
            )
          : ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                File(image.path),
                fit: BoxFit.cover,
              ),
            ),
    );
  }

  Widget _pickPhotoCard({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 94,
        height: 94,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: Colors.white.withValues(alpha: 0.05),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.22),
            width: 1.4,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white.withValues(alpha: 0.78), size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _chipButton({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: selected
              ? const Color(0xFF5BE22F).withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.06),
          border: Border.all(
            color: selected
                ? const Color(0xFF5BE22F)
                : Colors.white.withValues(alpha: 0.12),
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: selected
                ? const Color(0xFF72F247)
                : Colors.white.withValues(alpha: 0.82),
          ),
        ),
      ),
    );
  }

  Widget _glassField({
    required TextEditingController controller,
    required String hint,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.12)),
      ),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 15),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 14,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        ),
      ),
    );
  }

  Widget _buildPrimaryButton() {
    final label = switch (_currentStep) {
      0 => 'Lanjutkan',
      1 => 'Lanjutkan',
      2 => 'Kirim Laporan',
      _ => _isSubmitting ? 'Mengirim...' : 'Konfirmasi & Kirim',
    };

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _onPrimaryAction,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF94FF38),
          foregroundColor: const Color(0xFF0A1A12),
          disabledBackgroundColor: const Color(0xFF94FF38).withValues(alpha: 0.6),
          minimumSize: const Size.fromHeight(60),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
          shadowColor: const Color(0xFF94FF38).withValues(alpha: 0.28),
          elevation: 10,
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value[0].toUpperCase() + value.substring(1);
  }
}
