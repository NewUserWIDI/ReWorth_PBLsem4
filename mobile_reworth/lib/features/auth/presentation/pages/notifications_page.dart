import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotificationsPage extends StatefulWidget {
  const NotificationsPage({super.key});

  @override
  State<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  final SupabaseClient _client = Supabase.instance.client;

  bool _isLoading = true;
  List<_NotificationItem> _items = const [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) {
      if (!mounted) return;
      setState(() {
        _items = _fallbackNotifications();
        _isLoading = false;
      });
      return;
    }

    final items = <_NotificationItem>[];

    try {
      final reportRows = List<Map<String, dynamic>>.from(
        await _client
                .from('laporan_sampah')
                .select(
                  'status_laporan,poin_diberikan,waktu_lapor,jalan,kelurahan,kecamatan',
                )
                .eq('id_masyarakat', userId)
                .order('waktu_lapor', ascending: false)
                .limit(6)
                .timeout(const Duration(seconds: 10))
            as List,
      );

      for (final row in reportRows) {
        final status = (row['status_laporan'] ?? '').toString().toLowerCase();
        final location = [
          (row['jalan'] ?? '').toString().trim(),
          (row['kelurahan'] ?? '').toString().trim(),
          (row['kecamatan'] ?? '').toString().trim(),
        ].where((part) => part.isNotEmpty).join(', ');
        final occurredAt = _parseDate(row['waktu_lapor']?.toString());
        final points = (row['poin_diberikan'] as num?)?.toInt() ?? 0;

        if (status.contains('ditolak') || status.contains('rejected')) {
          items.add(
            _NotificationItem(
              title: 'Laporan ditolak',
              subtitle: location.isEmpty
                  ? 'Laporan belum bisa diverifikasi. Anda tetap mendapat apresiasi.'
                  : location,
              meta: points > 0 ? '+$points poin' : '+3 poin',
              icon: Icons.close_rounded,
              iconColor: const Color(0xFFE58F41),
              occurredAt: occurredAt,
            ),
          );
        } else if (status.contains('selesai') ||
            status.contains('valid') ||
            status.contains('diterima') ||
            status.contains('approved')) {
          items.add(
            _NotificationItem(
              title: 'Laporan diterima',
              subtitle: location.isEmpty
                  ? 'Laporan Anda berhasil diverifikasi admin.'
                  : location,
              meta: points > 0 ? '+$points poin' : '+10 poin',
              icon: Icons.check_rounded,
              iconColor: const Color(0xFF6DAE6F),
              occurredAt: occurredAt,
            ),
          );
        } else {
          items.add(
            _NotificationItem(
              title: 'Laporan sedang ditinjau',
              subtitle: location.isEmpty
                  ? 'Admin sedang meninjau laporan terbaru Anda.'
                  : location,
              meta: 'Sedang diproses',
              icon: Icons.schedule_rounded,
              iconColor: const Color(0xFF7BA9C8),
              occurredAt: occurredAt,
            ),
          );
        }
      }
    } catch (_) {}

    try {
      final orderRows = List<Map<String, dynamic>>.from(
        await _client
                .from('pesanan')
                .select(
                  'status_pesanan,tanggal_pesanan,total_bayar,kode_pesanan',
                )
                .eq('id_masyarakat', userId)
                .order('tanggal_pesanan', ascending: false)
                .limit(6)
                .timeout(const Duration(seconds: 10))
            as List,
      );

      for (final row in orderRows) {
        final status = (row['status_pesanan'] ?? '').toString();
        final total = (row['total_bayar'] as num?)?.toDouble() ?? 0;
        final orderCode = (row['kode_pesanan'] ?? '').toString();
        final occurredAt = _parseDate(row['tanggal_pesanan']?.toString());

        items.add(
          _NotificationItem(
            title: 'Update pesanan',
            subtitle: orderCode.isEmpty
                ? status
                : '$orderCode • ${status.isEmpty ? 'Pesanan baru' : status}',
            meta: _formatCurrency(total),
            icon: Icons.shopping_bag_outlined,
            iconColor: const Color(0xFF6F98B1),
            occurredAt: occurredAt,
          ),
        );
      }
    } catch (_) {}

    items.sort((a, b) {
      final aTime = a.occurredAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final bTime = b.occurredAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bTime.compareTo(aTime);
    });

    if (!mounted) return;
    setState(() {
      _items = items.isEmpty
          ? _fallbackNotifications()
          : items.take(12).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final groupedItems = _groupNotifications(_items);

    return Scaffold(
      backgroundColor: const Color(0xFF041914),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF0C3A2E), Color(0xFF082C23), Color(0xFF041914)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 10),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: IconButton.styleFrom(
                        backgroundColor: Colors.white.withValues(alpha: 0.08),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(
                        Icons.arrow_back_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Notifikasi',
                            style: GoogleFonts.poppins(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Pantau update laporan dan pesanan Anda.',
                            style: GoogleFonts.poppins(
                              fontSize: 12.5,
                              color: Colors.white.withValues(alpha: 0.68),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: _loadNotifications,
                  color: const Color(0xFFAED688),
                  backgroundColor: const Color(0xFF102720),
                  child: _isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFAED688),
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
                          itemCount: groupedItems.length,
                          itemBuilder: (context, index) {
                            final section = groupedItems[index];
                            return Padding(
                              padding: EdgeInsets.only(
                                bottom: index == groupedItems.length - 1
                                    ? 0
                                    : 18,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                      left: 2,
                                      bottom: 10,
                                    ),
                                    child: Text(
                                      section.label,
                                      style: GoogleFonts.poppins(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w600,
                                        color: const Color(0xFFE7F2D9),
                                      ),
                                    ),
                                  ),
                                  ...section.items.map(
                                    (item) => Padding(
                                      padding: const EdgeInsets.only(
                                        bottom: 12,
                                      ),
                                      child: _NotificationCard(item: item),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  const _NotificationCard({required this.item});

  final _NotificationItem item;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: item.iconColor.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(item.icon, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  item.subtitle,
                  style: GoogleFonts.poppins(
                    fontSize: 12.5,
                    height: 1.5,
                    color: Colors.white.withValues(alpha: 0.72),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.08),
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        item.meta,
                        style: GoogleFonts.poppins(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w500,
                          color: const Color(0xFFECE7DA),
                        ),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      _timeAgo(item.occurredAt),
                      style: GoogleFonts.poppins(
                        fontSize: 11.5,
                        color: Colors.white.withValues(alpha: 0.56),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationSection {
  const _NotificationSection({required this.label, required this.items});

  final String label;
  final List<_NotificationItem> items;
}

class _NotificationItem {
  const _NotificationItem({
    required this.title,
    required this.subtitle,
    required this.meta,
    required this.icon,
    required this.iconColor,
    required this.occurredAt,
  });

  final String title;
  final String subtitle;
  final String meta;
  final IconData icon;
  final Color iconColor;
  final DateTime? occurredAt;
}

List<_NotificationItem> _fallbackNotifications() {
  final now = DateTime.now();
  return [
    _NotificationItem(
      title: 'Laporan sedang ditinjau',
      subtitle: 'Admin sedang memeriksa laporan terbaru Anda.',
      meta: 'Sedang diproses',
      icon: Icons.schedule_rounded,
      iconColor: const Color(0xFF7BA9C8),
      occurredAt: now.subtract(const Duration(minutes: 12)),
    ),
    _NotificationItem(
      title: 'Poin berhasil ditambahkan',
      subtitle: 'Kontribusi lingkungan Anda berhasil menambah poin akun.',
      meta: '+10 poin',
      icon: Icons.check_rounded,
      iconColor: const Color(0xFF6DAE6F),
      occurredAt: now.subtract(const Duration(hours: 2)),
    ),
  ];
}

DateTime? _parseDate(String? raw) {
  if (raw == null || raw.trim().isEmpty) {
    return null;
  }
  return DateTime.tryParse(raw);
}

String _formatCurrency(double amount) {
  return NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  ).format(amount);
}

String _timeAgo(DateTime? dateTime) {
  if (dateTime == null) {
    return 'Baru saja';
  }

  final diff = DateTime.now().difference(dateTime);
  if (diff.inMinutes < 1) return 'Baru saja';
  if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
  if (diff.inHours < 24) return '${diff.inHours} jam lalu';
  return '${diff.inDays} hari lalu';
}

List<_NotificationSection> _groupNotifications(List<_NotificationItem> items) {
  final sections = <_NotificationSection>[];
  final grouped = <String, List<_NotificationItem>>{};
  final now = DateTime.now();

  for (final item in items) {
    final occurredAt = item.occurredAt ?? now;
    final dateKey = DateFormat('yyyy-MM-dd').format(occurredAt);
    grouped.putIfAbsent(dateKey, () => []).add(item);
  }

  final sortedKeys = grouped.keys.toList()..sort((a, b) => b.compareTo(a));

  for (final key in sortedKeys) {
    final date = DateTime.tryParse(key);
    if (date == null) {
      continue;
    }
    sections.add(
      _NotificationSection(
        label: _sectionDateLabel(date, now),
        items: grouped[key]!,
      ),
    );
  }

  return sections;
}

String _sectionDateLabel(DateTime date, DateTime now) {
  final normalizedDate = DateTime(date.year, date.month, date.day);
  final normalizedNow = DateTime(now.year, now.month, now.day);
  final dayDiff = normalizedNow.difference(normalizedDate).inDays;

  if (dayDiff == 0) return 'Hari ini';
  if (dayDiff == 1) return 'Kemarin';
  return DateFormat('d MMMM yyyy', 'id_ID').format(date);
}
