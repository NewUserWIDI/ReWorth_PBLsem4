import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../application/report_controller.dart';
import '../../domain/waste_type.dart';
import '../../domain/severity_level.dart';

class ReportPage extends ConsumerStatefulWidget {
  const ReportPage({super.key});

  @override
  ConsumerState<ReportPage> createState() => _ReportPageState();
}

class _ReportPageState extends ConsumerState<ReportPage> {
  @override
  Widget build(BuildContext context) {
    final reportState = ref.watch(reportControllerProvider);
    final reportController = ref.read(reportControllerProvider.notifier);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Laporkan Sampah Liar'),
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
      ),
      body: reportState.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildImageSection(reportController, reportState, context),
                  const SizedBox(height: 16),
                  _buildLocationSection(reportController, reportState),
                  const SizedBox(height: 16),
                  _buildWasteTypeSection(reportController, reportState),
                  const SizedBox(height: 16),
                  _buildSeveritySection(reportController, reportState),
                  const SizedBox(height: 24),
                  _buildSubmitButton(reportController, reportState, context),
                ],
              ),
            ),
    );
  }
  
  Widget _buildImageSection(ReportController controller, ReportState state, BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.all(12),
            child: Text(
              'Ambil atau Unggah Foto',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              'Pastikan Sampah Terlihat Jelas',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () => controller.showImagePickerDialog(context),
            child: Container(
              height: 200,
              margin: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: controller.imageError.isNotEmpty ? Colors.red : Colors.grey.shade300,
                ),
              ),
              child: state.imagePath.isEmpty && state.imageFile == null
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.camera_alt, size: 48, color: Colors.grey.shade400),
                          const SizedBox(height: 8),
                          Text(
                            'Tap untuk mengambil foto',
                            style: TextStyle(color: Colors.grey.shade600),
                          ),
                          Text(
                            'atau unggah dari galeri',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
                          ),
                        ],
                      ),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(state.imagePath),
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
            ),
          ),
          if (controller.imageError.isNotEmpty)
            Padding(
              padding: const EdgeInsets.all(12),
              child: Text(
                controller.imageError,
                style: const TextStyle(color: Colors.red, fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }
  
  Widget _buildLocationSection(ReportController controller, ReportState state) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Lokasi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            TextField(
              controller: controller.streetController,
              decoration: InputDecoration(
                labelText: 'Jalan',
                hintText: 'Masukkan nama jalan',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                errorText: controller.streetError.isNotEmpty ? controller.streetError : null,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.villageController,
              decoration: InputDecoration(
                labelText: 'Desa/Kelurahan',
                hintText: 'Masukkan desa/kelurahan',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                errorText: controller.villageError.isNotEmpty ? controller.villageError : null,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.districtController,
              decoration: InputDecoration(
                labelText: 'Kecamatan',
                hintText: 'Masukkan kecamatan',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                errorText: controller.districtError.isNotEmpty ? controller.districtError : null,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.postalCodeController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: 'Kode Pos',
                hintText: 'Masukkan kode pos',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                errorText: controller.postalCodeError.isNotEmpty ? controller.postalCodeError : null,
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller.descriptionController,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Deskripsi',
                hintText: 'Deskripsikan kondisi sampah',
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                errorText: controller.descriptionError.isNotEmpty ? controller.descriptionError : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildWasteTypeSection(ReportController controller, ReportState state) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Jenis Sampah', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Row(
              children: WasteType.values.map((type) {
                final isSelected = state.selectedWasteType == type;
                return Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: GestureDetector(
                      onTap: () => controller.setWasteType(type),
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? Colors.green : Colors.grey.shade100,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isSelected ? Colors.green : Colors.grey.shade300,
                          ),
                        ),
                        child: Text(
                          type.label,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (controller.wasteTypeError.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  controller.wasteTypeError,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSeveritySection(ReportController controller, ReportState state) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Tingkat Keparahan', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            const SizedBox(height: 12),
            Column(
              children: SeverityLevel.values.map((level) {
                final isSelected = state.selectedSeverity == level;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: () => controller.setSeverity(level),
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isSelected ? Colors.green : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: isSelected ? Colors.green : Colors.grey.shade300,
                        ),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                            color: isSelected ? Colors.white : Colors.grey,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            level.label,
                            style: TextStyle(
                              color: isSelected ? Colors.white : Colors.black,
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            if (controller.severityError.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  controller.severityError,
                  style: const TextStyle(color: Colors.red, fontSize: 12),
                ),
              ),
            const SizedBox(height: 8),
            if (controller.getSeverityDescription().isNotEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue.shade700),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        controller.getSeverityDescription(),
                        style: TextStyle(color: Colors.blue.shade700, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildSubmitButton(ReportController controller, ReportState state, BuildContext context) {
    if (state.isSubmitting) {
      return const Center(child: CircularProgressIndicator());
    }
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => controller.submitReport(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: const Text(
          'Konfirmasi Pelaporan',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
