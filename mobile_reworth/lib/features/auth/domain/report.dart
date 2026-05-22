import 'package:equatable/equatable.dart';
import 'waste_type.dart';
import 'severity_level.dart';

class Report extends Equatable {
  final String? id;
  final String imagePath;
  final String street;
  final String village;
  final String district;
  final String postalCode;
  final String description;
  final WasteType wasteType;
  final SeverityLevel severityLevel;
  final DateTime createdAt;
  final String? userId;
  final String? status;
  final String? rejectionReason;  //  TAMBAHKAN INI

  const Report({
    this.id,
    required this.imagePath,
    required this.street,
    required this.village,
    required this.district,
    required this.postalCode,
    required this.description,
    required this.wasteType,
    required this.severityLevel,
    required this.createdAt,
    this.userId,
    this.status,
    this.rejectionReason,  //  TAMBAHKAN INI
  });

  Report copyWith({
    String? id,
    String? imagePath,
    String? street,
    String? village,
    String? district,
    String? postalCode,
    String? description,
    WasteType? wasteType,
    SeverityLevel? severityLevel,
    DateTime? createdAt,
    String? userId,
    String? status,
    String? rejectionReason,  // TAMBAHKAN INI
  }) {
    return Report(
      id: id ?? this.id,
      imagePath: imagePath ?? this.imagePath,
      street: street ?? this.street,
      village: village ?? this.village,
      district: district ?? this.district,
      postalCode: postalCode ?? this.postalCode,
      description: description ?? this.description,
      wasteType: wasteType ?? this.wasteType,
      severityLevel: severityLevel ?? this.severityLevel,
      createdAt: createdAt ?? this.createdAt,
      userId: userId ?? this.userId,
      status: status ?? this.status,
      rejectionReason: rejectionReason ?? this.rejectionReason,  // TAMBAHKAN INI
    );
  }

  @override
  List<Object?> get props => [
        id,
        imagePath,
        street,
        village,
        district,
        postalCode,
        description,
        wasteType,
        severityLevel,
        createdAt,
        userId,
        status,
        rejectionReason,  // TAMBAHKAN INI
      ];
}