class RewardItem {
  final int idReward;
  final String namaReward;
  final String jenisReward; // 'Pulsa' atau 'Kuota'
  final String? provider;
  final String? nominalReward;
  final int poinDibutuhkan;
  final String statusReward; // 'Aktif' atau 'Nonaktif'

  RewardItem({
    required this.idReward,
    required this.namaReward,
    required this.jenisReward,
    this.provider,
    this.nominalReward,
    required this.poinDibutuhkan,
    required this.statusReward,
  });

  factory RewardItem.fromJson(Map<String, dynamic> json) {
    return RewardItem(
      idReward: json['id_reward'] as int,
      namaReward: json['nama_reward'] as String,
      jenisReward: json['jenis_reward'] as String,
      provider: json['provider'] as String?,
      nominalReward: json['nominal_reward'] as String?,
      poinDibutuhkan: json['poin_dibutuhkan'] as int,
      statusReward: json['status_reward'] as String,
    );
  }

  String get description {
    if (jenisReward == 'Pulsa') {
      return 'Pulsa ${provider != null ? '$provider ' : ''}Rp ${_formatNominal(nominalReward ?? '0')}';
    } else if (jenisReward == 'Kuota') {
      return 'Kuota Internet ${provider != null ? '$provider ' : ''}${nominalReward ?? '0'}';
    }
    return 'Tukarkan poin Anda';
  }

  String _formatNominal(String nominal) {
    if (nominal.isEmpty) return '0';
    final number = int.tryParse(nominal.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    if (number >= 1000000) {
      return '${(number / 1000000).toStringAsFixed(0)}jt';
    } else if (number >= 1000) {
      return '${(number / 1000).toStringAsFixed(0)}rb';
    }
    return number.toString();
  }

  Map<String, dynamic> toJson() {
    return {
      'id_reward': idReward,
      'nama_reward': namaReward,
      'jenis_reward': jenisReward,
      'provider': provider,
      'nominal_reward': nominalReward,
      'poin_dibutuhkan': poinDibutuhkan,
      'status_reward': statusReward,
    };
  }
}
