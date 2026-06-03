// lib/features/profile/presentation/pages/profile_edit_page.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'package:intl/intl.dart';

import '../../application/profile_controller.dart';

class ProfileEditPage extends ConsumerStatefulWidget {
  const ProfileEditPage({super.key});

  @override
  ConsumerState<ProfileEditPage> createState() => _ProfileEditPageState();
}

class _ProfileEditPageState extends ConsumerState<ProfileEditPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _namaController;
  late TextEditingController _noTelpController;

  File? _selectedImage;
  String? _currentFotoUrl;
  bool _isUploadingImage = false;
  String? _originalNama;
  String? _originalNoTelp;

  @override
  void initState() {
    super.initState();
    _namaController = TextEditingController();
    _noTelpController = TextEditingController();
    _loadCurrentData();
  }

  @override
  void dispose() {
    _namaController.dispose();
    _noTelpController.dispose();
    super.dispose();
  }

  void _loadCurrentData() {
    final user = ref.read(profileControllerProvider).user;
    if (user != null) {
      _namaController.text = user.nama;
      _noTelpController.text = user.noTelp;
      _currentFotoUrl = user.fotoProfil;
      _originalNama = user.nama;
      _originalNoTelp = user.noTelp;
    }
  }

  Future<void> _pickImage() async {
    if (_isUploadingImage) return;

    try {
      final picker = ImagePicker();
      final XFile? picked = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 800,
        maxHeight: 800,
      );

      if (picked != null && mounted) {
        final Directory tempDir = await getTemporaryDirectory();
        final String timestamp = DateTime.now().millisecondsSinceEpoch
            .toString();
        final File tempFile = File('${tempDir.path}/profile_$timestamp.jpg');
        await File(picked.path).copy(tempFile.path);

        final Uint8List bytes = await tempFile.readAsBytes();
        if (bytes.isNotEmpty && bytes.length > 1000) {
          setState(() {
            _selectedImage = tempFile;
          });
          print('✅ Image valid: ${bytes.length} bytes');
        } else {
          throw Exception('File gambar tidak valid');
        }
      }
    } catch (e) {
      print('❌ Error picking image: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memilih gambar: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<String?> _uploadImageToStorage(File imageFile) async {
    final client = Supabase.instance.client;
    final String? userId = client.auth.currentUser?.id;
    if (userId == null) return null;

    try {
      final Uint8List fileBytes = await imageFile.readAsBytes();

      if (fileBytes.isEmpty || fileBytes.length < 100) {
        print('❌ File terlalu kecil atau kosong');
        return null;
      }

      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = '${userId}_$timestamp.jpg';
      const String bucket = 'profil';

      print('📤 Uploading $fileName (${fileBytes.length} bytes)');

      await client.storage
          .from(bucket)
          .uploadBinary(
            fileName,
            fileBytes,
            fileOptions: const FileOptions(contentType: 'image/jpeg'),
          );

      final String publicUrl = client.storage
          .from(bucket)
          .getPublicUrl(fileName);
      print('✅ Upload success: $publicUrl');
      return publicUrl;
    } catch (e) {
      print('❌ Error uploading: $e');
      return null;
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final String currentNama = _namaController.text.trim();
    final String currentNoTelp = _noTelpController.text.trim();
    final bool hasNameChanged = currentNama != _originalNama;
    final bool hasPhoneChanged = currentNoTelp != _originalNoTelp;
    final bool hasImageChanged = _selectedImage != null;

    if (!hasNameChanged && !hasPhoneChanged && !hasImageChanged) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Tidak ada perubahan'),
            backgroundColor: Colors.orange,
          ),
        );
        context.pop(false);
      }
      return;
    }

    setState(() => _isUploadingImage = true);

    String? fotoUrl = _currentFotoUrl;

    if (_selectedImage != null) {
      final String? uploadedUrl = await _uploadImageToStorage(_selectedImage!);
      if (uploadedUrl != null && uploadedUrl.isNotEmpty) {
        fotoUrl = uploadedUrl;
      } else {
        setState(() => _isUploadingImage = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Gagal upload foto, coba lagi'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }
    }

    final client = Supabase.instance.client;
    final String? userId = client.auth.currentUser?.id;

    if (userId == null) {
      setState(() => _isUploadingImage = false);
      return;
    }

    final Map<String, dynamic> updateData = {
      'nama_lengkap': currentNama,
      'nama': currentNama,
      'no_telp': currentNoTelp,
      'nomor_hp': currentNoTelp,
      'updated_at': DateTime.now().toIso8601String(),
    };

    if (fotoUrl != null && fotoUrl.isNotEmpty) {
      updateData['foto_profil'] = fotoUrl;
    }

    try {
      await client.from('profiles').update(updateData).eq('id', userId);

      setState(() => _isUploadingImage = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profil berhasil diperbarui!'),
            backgroundColor: Color(0xFF4CAF50),
          ),
        );
        await ref.read(profileControllerProvider.notifier).loadProfile();
        context.pop(true);
      }
    } catch (e) {
      print('❌ Error update: $e');
      setState(() => _isUploadingImage = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal update: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _getStatusPengajuanDisplay(String status) {
    switch (status) {
      case 'pending':
        return '⏳ Menunggu Verifikasi';
      case 'aktif':
        return '✅ Aktif';
      case 'ditolak':
        return '❌ Ditolak';
      case 'Belum Daftar':
        return '📝 Belum Daftar';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final user = profileState.user;
    final isUpdating = profileState.isUpdatingProfile || _isUploadingImage;

    return Scaffold(
      backgroundColor: const Color(0xFF001F1A),
      appBar: AppBar(
        title: const Text(
          'Edit Profil',
          style: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF003B2F),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(false),
        ),
      ),
      body: user == null
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF94FF38)),
            )
          : Stack(
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
                SafeArea(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Profile Photo Section
                        _buildProfilePhotoSection(),
                        const SizedBox(height: 24),

                        // Form Container
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF0A1E19,
                            ).withValues(alpha: 0.78),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(
                                0xFF94FF38,
                              ).withValues(alpha: 0.22),
                            ),
                          ),
                          child: Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                _buildTextField(
                                  controller: _namaController,
                                  label: 'Nama Lengkap',
                                  icon: Icons.person_outline,
                                  hintText: 'Masukkan nama lengkap Anda',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'Nama harus diisi';
                                    }
                                    if (value.length < 3) {
                                      return 'Minimal 3 karakter';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                _buildTextField(
                                  controller: _noTelpController,
                                  label: 'Nomor Telepon',
                                  icon: Icons.phone,
                                  keyboardType: TextInputType.phone,
                                  hintText: 'Contoh: 081234567890',
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return 'No telepon harus diisi';
                                    }
                                    final clean = value.replaceAll(
                                      RegExp(r'[^0-9]'),
                                      '',
                                    );
                                    if (clean.length < 10) {
                                      return 'Minimal 10 digit';
                                    }
                                    return null;
                                  },
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        // Info Container (Read-only)
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: const Color(
                              0xFF0A1E19,
                            ).withValues(alpha: 0.78),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: const Color(
                                0xFF94FF38,
                              ).withValues(alpha: 0.22),
                            ),
                          ),
                          child: Column(
                            children: [
                              _buildInfoRow(
                                icon: Icons.email_outlined,
                                label: 'Email',
                                value: user.email,
                              ),
                              const Divider(color: Colors.white10, height: 16),
                              _buildInfoRow(
                                icon: Icons.storefront_outlined,
                                label: 'Status Seller',
                                value: _getStatusPengajuanDisplay(
                                  user.statusPengajuanSeller,
                                ),
                              ),
                              const Divider(color: Colors.white10, height: 16),
                              _buildInfoRow(
                                icon: Icons.calendar_today_outlined,
                                label: 'Bergabung Sejak',
                                value: DateFormat(
                                  'dd MMMM yyyy',
                                ).format(user.createdAt),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),

                        // Save Button
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isUpdating ? null : _saveProfile,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF94FF38),
                              foregroundColor: const Color(0xFF0A1A12),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                            ),
                            child: isUpdating
                                ? const SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Color(0xFF0A1A12),
                                    ),
                                  )
                                : const Text(
                                    'Simpan Perubahan',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildProfilePhotoSection() {
    final user = ref.read(profileControllerProvider).user;
    final avatarUrl = _currentFotoUrl ?? user?.fotoProfil ?? '';

    return GestureDetector(
      onTap: _pickImage,
      child: Column(
        children: [
          Stack(
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: const Color(0xFF94FF38).withValues(alpha: 0.8),
                    width: 2.5,
                  ),
                ),
                child: CircleAvatar(
                  backgroundColor: Colors.white.withValues(alpha: 0.12),
                  backgroundImage: _selectedImage != null
                      ? FileImage(_selectedImage!)
                      : (avatarUrl.isNotEmpty ? NetworkImage(avatarUrl) : null),
                  child: avatarUrl.isEmpty && _selectedImage == null
                      ? const Icon(
                          Icons.person,
                          color: Color(0xFF94FF38),
                          size: 56,
                        )
                      : null,
                ),
              ),
              Positioned(
                right: 2,
                bottom: 2,
                child: Container(
                  width: 34,
                  height: 34,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFF94FF38),
                    border: Border.all(
                      color: const Color(0xFF0A1A12),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.camera_alt,
                    size: 18,
                    color: Color(0xFF0A1A12),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            'Klik untuk mengganti foto',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool enabled = true,
    String? hintText,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 15),
      decoration: InputDecoration(
        labelText: label,
        hintText: hintText,
        hintStyle: TextStyle(
          color: Colors.white.withValues(alpha: 0.3),
          fontSize: 13,
        ),
        labelStyle: TextStyle(
          color: enabled
              ? const Color(0xFF94FF38).withValues(alpha: 0.8)
              : Colors.white.withValues(alpha: 0.5),
          fontSize: 14,
        ),
        prefixIcon: Icon(icon, color: const Color(0xFF94FF38), size: 22),
        filled: true,
        fillColor: enabled
            ? const Color(0xFF0A2A22).withValues(alpha: 0.6)
            : const Color(0xFF0A2A22).withValues(alpha: 0.3),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: const Color(0xFF94FF38).withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFF94FF38), width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: const Color(0xFF94FF38).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: const Color(0xFF94FF38), size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.5),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
