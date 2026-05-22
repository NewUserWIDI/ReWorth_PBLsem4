import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../domain/report.dart';
import '../domain/waste_type.dart';
import '../domain/severity_level.dart';
import '../data/report_repository.dart';
import '../data/mock_report_repository.dart';

// Provider untuk ReportController
final reportControllerProvider = StateNotifierProvider<ReportController, ReportState>((ref) {
  return ReportController();
});

// State untuk Report
class ReportState {
  final bool isLoading;
  final bool isSubmitting;
  final String imagePath;
  final XFile? imageFile;
  final WasteType? selectedWasteType;
  final SeverityLevel? selectedSeverity;
  final List<Report> allReports;
  final Map<String, String> errors;

  const ReportState({
    this.isLoading = false,
    this.isSubmitting = false,
    this.imagePath = '',
    this.imageFile = null,
    this.selectedWasteType = null,
    this.selectedSeverity = null,
    this.allReports = const [],
    this.errors = const {},
  });

  ReportState copyWith({
    bool? isLoading,
    bool? isSubmitting,
    String? imagePath,
    XFile? imageFile,
    WasteType? selectedWasteType,
    SeverityLevel? selectedSeverity,
    List<Report>? allReports,
    Map<String, String>? errors,
  }) {
    return ReportState(
      isLoading: isLoading ?? this.isLoading,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      imagePath: imagePath ?? this.imagePath,
      imageFile: imageFile ?? this.imageFile,
      selectedWasteType: selectedWasteType ?? this.selectedWasteType,
      selectedSeverity: selectedSeverity ?? this.selectedSeverity,
      allReports: allReports ?? this.allReports,
      errors: errors ?? this.errors,
    );
  }
}

class ReportController extends StateNotifier<ReportState> {
  final ReportRepository _repository = MockReportRepository();
  final ImagePicker _picker = ImagePicker();
  
  // TextEditingControllers
  final streetController = TextEditingController();
  final villageController = TextEditingController();
  final districtController = TextEditingController();
  final postalCodeController = TextEditingController();
  final descriptionController = TextEditingController();

  ReportController() : super(const ReportState());

  // Getters untuk nilai form
  String get street => streetController.text;
  String get village => villageController.text;
  String get district => districtController.text;
  String get postalCode => postalCodeController.text;
  String get description => descriptionController.text;

  // Error getters
  String get imageError => state.errors['image'] ?? '';
  String get streetError => state.errors['street'] ?? '';
  String get villageError => state.errors['village'] ?? '';
  String get districtError => state.errors['district'] ?? '';
  String get postalCodeError => state.errors['postalCode'] ?? '';
  String get descriptionError => state.errors['description'] ?? '';
  String get wasteTypeError => state.errors['wasteType'] ?? '';
  String get severityError => state.errors['severity'] ?? '';

  @override
  void dispose() {
    streetController.dispose();
    villageController.dispose();
    districtController.dispose();
    postalCodeController.dispose();
    descriptionController.dispose();
    super.dispose();
  }

  // Fungsi untuk mengambil foto dari kamera
  Future<void> pickImageFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      
      if (image != null) {
        state = state.copyWith(
          imageFile: image,
          imagePath: image.path,
          errors: {...state.errors}..remove('image'),
        );
      }
    } catch (e) {
      // Handle error
    }
  }
  
  // Fungsi untuk memilih foto dari galeri
  Future<void> pickImageFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      
      if (image != null) {
        state = state.copyWith(
          imageFile: image,
          imagePath: image.path,
          errors: {...state.errors}..remove('image'),
        );
      }
    } catch (e) {
      // Handle error
    }
  }
  
  // Menampilkan dialog pilihan kamera atau galeri
  void showImagePickerDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pilih Foto'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Ambil Foto'),
              onTap: () {
                Navigator.pop(context);
                pickImageFromCamera();
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Pilih dari Galeri'),
              onTap: () {
                Navigator.pop(context);
                pickImageFromGallery();
              },
            ),
          ],
        ),
      ),
    );
  }
  
  bool validateForm() {
    final newErrors = <String, String>{};
    
    if (state.imagePath.isEmpty && state.imageFile == null) {
      newErrors['image'] = 'Foto wajib diambil/diunggah';
    }
    
    if (streetController.text.trim().isEmpty) {
      newErrors['street'] = 'Jalan wajib diisi';
    }
    
    if (villageController.text.trim().isEmpty) {
      newErrors['village'] = 'Desa/Kelurahan wajib diisi';
    }
    
    if (districtController.text.trim().isEmpty) {
      newErrors['district'] = 'Kecamatan wajib diisi';
    }
    
    if (postalCodeController.text.trim().isEmpty) {
      newErrors['postalCode'] = 'Kode Pos wajib diisi';
    } else if (postalCodeController.text.length < 5) {
      newErrors['postalCode'] = 'Kode Pos minimal 5 digit';
    }
    
    if (descriptionController.text.trim().isEmpty) {
      newErrors['description'] = 'Deskripsi wajib diisi';
    }
    
    if (state.selectedWasteType == null) {
      newErrors['wasteType'] = 'Pilih jenis sampah';
    }
    
    if (state.selectedSeverity == null) {
      newErrors['severity'] = 'Pilih tingkat keparahan';
    }
    
    state = state.copyWith(errors: newErrors);
    return newErrors.isEmpty;
  }
  
  Future<void> submitReport(BuildContext context) async {
    if (!validateForm()) return;
    
    state = state.copyWith(isSubmitting: true);
    
    final report = Report(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      imagePath: state.imagePath,
      street: streetController.text.trim(),
      village: villageController.text.trim(),
      district: districtController.text.trim(),
      postalCode: postalCodeController.text.trim(),
      description: descriptionController.text.trim(),
      wasteType: state.selectedWasteType!,
      severityLevel: state.selectedSeverity!,
      createdAt: DateTime.now(),
      userId: 'current_user_id',
      status: 'pending',
    );
    
    final result = await _repository.submitReport(report);
    
    state = state.copyWith(isSubmitting: false);
    
    if (result.success) {
      // Tambahkan ke history
      final newReports = [report, ...state.allReports];
      state = state.copyWith(allReports: newReports);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Laporan berhasil dikirim'), backgroundColor: Colors.green),
        );
        clearForm();
        Navigator.pop(context);
      }
    } else {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(result.message ?? 'Gagal mengirim laporan'), backgroundColor: Colors.red),
        );
      }
    }
  }
  
  void clearForm() {
    streetController.clear();
    villageController.clear();
    districtController.clear();
    postalCodeController.clear();
    descriptionController.clear();
    state = state.copyWith(
      imagePath: '',
      imageFile: null,
      selectedWasteType: null,
      selectedSeverity: null,
      errors: {},
    );
  }
  
  void setWasteType(WasteType? type) {
    state = state.copyWith(
      selectedWasteType: type,
      errors: {...state.errors}..remove('wasteType'),
    );
  }
  
  void setSeverity(SeverityLevel? level) {
    state = state.copyWith(
      selectedSeverity: level,
      errors: {...state.errors}..remove('severity'),
    );
  }
  
  String getSeverityDescription() {
    return state.selectedSeverity?.description ?? '';
  }
  
  // Fungsi untuk history
  List<Report> getReportsByStatus(String status) {
    switch (status) {
      case 'aktif':
        return state.allReports.where((r) => 
          r.status == 'pending' || r.status == 'processing'
        ).toList();
      case 'selesai':
        return state.allReports.where((r) => r.status == 'completed').toList();
      case 'ditolak':
        return state.allReports.where((r) => r.status == 'rejected').toList();
      default:
        return [];
    }
  }
  
  Future<void> loadReportHistory() async {
    state = state.copyWith(isLoading: true);
    final userId = 'current_user_id';
    final reports = await _repository.getUserReports(userId);
    state = state.copyWith(allReports: reports, isLoading: false);
  }
}