import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../shared/widgets/auth_header_sheet_layout.dart';
import '../../application/profile_controller.dart';
import '../../domain/profile_user.dart';

class EditProfilePage extends ConsumerStatefulWidget {
  const EditProfilePage({super.key});

  @override
  ConsumerState<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends ConsumerState<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _namaController;
  late TextEditingController _emailController;
  late TextEditingController _teleponController;
  late TextEditingController _jalanController;
  late TextEditingController _rtRwController;
  late TextEditingController _desaKelurahanController;
  late TextEditingController _kecamatanController;
  late TextEditingController _kotaController;
  late TextEditingController _provinsiController;

  String? _selectedJenisKelamin;
  DateTime? _selectedTanggalLahir;
  bool _isLoading = false;

  final List<String> _jenisKelaminOptions = ['Laki-laki', 'Perempuan'];

  @override
  void initState() {
    super.initState();
    final user = ref.read(profileControllerProvider).user;
    _initializeControllers(user);
  }

  void _initializeControllers(ProfileUser? user) {
    _namaController = TextEditingController(text: user?.nama ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    _teleponController = TextEditingController();
    _jalanController = TextEditingController();
    _rtRwController = TextEditingController();
    _desaKelurahanController = TextEditingController();
    _kecamatanController = TextEditingController();
    _kotaController = TextEditingController();
    _provinsiController = TextEditingController();
    _selectedJenisKelamin = null;
    _selectedTanggalLahir = null;
  }

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _teleponController.dispose();
    _jalanController.dispose();
    _rtRwController.dispose();
    _desaKelurahanController.dispose();
    _kecamatanController.dispose();
    _kotaController.dispose();
    _provinsiController.dispose();
    super.dispose();
  }

  Future<void> _selectTanggalLahir(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedTanggalLahir ?? DateTime(2000),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xff2E7D32),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTanggalLahir = picked;
      });
    }
  }

  Future<void> _simpanPerubahan() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      // Simulasi penyimpanan data
      await Future.delayed(const Duration(seconds: 1));

      // Di sini nanti Anda bisa menyimpan ke repository/Supabase
      // Contoh: await _repository.updateProfile(...)

      if (mounted) {
        setState(() => _isLoading = false);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui'),
            backgroundColor: Color(0xff2E7D32),
            behavior: SnackBarBehavior.floating,
          ),
        );

        Navigator.pop(context);
      }
    }
  }

  String _formatTanggal(DateTime? date) {
    if (date == null) return 'Pilih Tanggal Lahir';
    final List<String> bulan = [
      'Januari',
      'Februari',
      'Maret',
      'April',
      'Mei',
      'Juni',
      'Juli',
      'Agustus',
      'September',
      'Oktober',
      'November',
      'Desember',
    ];
    return '${date.day} ${bulan[date.month - 1]} ${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final user = profileState.user;

    return AuthHeaderSheetLayout(
      title: 'Detail Profile',
      child: Stack(
        children: [
          SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Foto Profile
                  _buildFotoProfileSection(user),
                  const SizedBox(height: 24),

                  // Informasi Pribadi Title
                  _buildSectionTitle('Informasi Pribadi'),
                  const SizedBox(height: 16),

                  // Nama Lengkap
                  _buildTextField(
                    controller: _namaController,
                    label: 'Nama Lengkap',
                    required: true,
                    icon: Icons.person_outline_rounded,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Nama lengkap harus diisi';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // Jenis Kelamin
                  _buildJenisKelaminField(),
                  const SizedBox(height: 16),

                  // Tanggal Lahir
                  _buildTanggalLahirField(),
                  const SizedBox(height: 16),

                  // Kontak Title
                  _buildSectionTitle('Kontak'),
                  const SizedBox(height: 16),

                  // Email
                  _buildTextField(
                    controller: _emailController,
                    label: 'Email',
                    keyboardType: TextInputType.emailAddress,
                    icon: Icons.email_outlined,
                    enabled: false, // Email tidak bisa diubah
                  ),
                  const SizedBox(height: 16),

                  // No. Telepon
                  _buildTextField(
                    controller: _teleponController,
                    label: 'No. Telepon',
                    keyboardType: TextInputType.phone,
                    icon: Icons.phone_outlined,
                    hint: 'Contoh: 081234567890',
                  ),
                  const SizedBox(height: 16),

                  // Alamat Title
                  _buildSectionTitle('Alamat'),
                  const SizedBox(height: 16),

                  // Jalan
                  _buildTextField(
                    controller: _jalanController,
                    label: 'Jalan',
                    icon: Icons.home_outlined,
                    hint: 'Nama jalan, nomor rumah, blok, dll.',
                  ),
                  const SizedBox(height: 16),

                  // RT RW
                  _buildTextField(
                    controller: _rtRwController,
                    label: 'RT RW',
                    icon: Icons.map_outlined,
                    hint: 'Contoh: 001/002',
                  ),
                  const SizedBox(height: 16),

                  // Desa/Kelurahan
                  _buildTextField(
                    controller: _desaKelurahanController,
                    label: 'Desa/Kelurahan',
                    icon: Icons.location_city_outlined,
                  ),
                  const SizedBox(height: 16),

                  // Kecamatan
                  _buildTextField(
                    controller: _kecamatanController,
                    label: 'Kecamatan',
                    icon: Icons.place_outlined,
                  ),
                  const SizedBox(height: 16),

                  // Kota
                  _buildTextField(
                    controller: _kotaController,
                    label: 'Kota',
                    icon: Icons.business_outlined,
                  ),
                  const SizedBox(height: 16),

                  // Provinsi
                  _buildTextField(
                    controller: _provinsiController,
                    label: 'Provinsi',
                    icon: Icons.public_outlined,
                  ),
                  const SizedBox(height: 32),

                  // Tombol Simpan Perubahan
                  _buildSimpanButton(),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(Color(0xff2E7D32)),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFotoProfileSection(ProfileUser? user) {
    return Center(
      child: Stack(
        children: [
          CircleAvatar(
            radius: 60,
            backgroundColor: Colors.grey.shade200,
            backgroundImage:
                user?.fotoProfil != null && user!.fotoProfil.isNotEmpty
                ? NetworkImage(user.fotoProfil)
                : null,
            child: user?.fotoProfil == null || user!.fotoProfil.isEmpty
                ? Icon(Icons.person, size: 60, color: Colors.grey.shade400)
                : null,
          ),
          // Catatan: Untuk fitur ganti foto, nanti bisa ditambahkan image_picker
          // Tampilkan indikator bahwa fitur akan datang
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xff2E7D32),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 3),
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: Color(0xff1F5E23),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool required = false,
    bool enabled = true,
    TextInputType keyboardType = TextInputType.text,
    IconData? icon,
    String? Function(String?)? validator,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        enabled: enabled,
        keyboardType: keyboardType,
        validator: validator,
        decoration: InputDecoration(
          labelText: required ? '$label *' : label,
          hintText: hint,
          prefixIcon: icon != null
              ? Icon(icon, color: const Color(0xff2E7D32))
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade200),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xff2E7D32), width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildJenisKelaminField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InputDecorator(
        decoration: InputDecoration(
          labelText: 'Jenis Kelamin',
          prefixIcon: const Icon(
            Icons.person_outline,
            color: Color(0xff2E7D32),
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xff2E7D32), width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
        ),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: _selectedJenisKelamin,
            hint: const Text('Pilih Jenis Kelamin'),
            isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xff2E7D32)),
            items: _jenisKelaminOptions.map((String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                _selectedJenisKelamin = newValue;
              });
            },
          ),
        ),
      ),
    );
  }

  Widget _buildTanggalLahirField() {
    return GestureDetector(
      onTap: () => _selectTanggalLahir(context),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: InputDecorator(
          decoration: InputDecoration(
            labelText: 'Tanggal Lahir',
            prefixIcon: const Icon(
              Icons.cake_outlined,
              color: Color(0xff2E7D32),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xff2E7D32), width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                _formatTanggal(_selectedTanggalLahir),
                style: TextStyle(
                  color: _selectedTanggalLahir != null
                      ? Colors.black
                      : Colors.grey.shade500,
                ),
              ),
              const Icon(
                Icons.calendar_today,
                size: 20,
                color: Color(0xff2E7D32),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSimpanButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _simpanPerubahan,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xff2E7D32),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 2,
        ),
        child: const Text(
          'Simpan Perubahan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
