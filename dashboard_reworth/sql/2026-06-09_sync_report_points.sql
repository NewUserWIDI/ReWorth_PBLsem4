with accepted_reports as (
    select
        l.id_laporan,
        l.id_masyarakat,
        coalesce(l.poin_diberikan, 0) as poin_diberikan,
        coalesce(l.updated_at, l.waktu_lapor, now()) as tanggal_riwayat
    from public.laporan_sampah l
    where lower(coalesce(l.status_laporan, '')) in (
        'processing',
        'completed',
        'selesai',
        'valid',
        'diterima',
        'approved'
    )
    and coalesce(l.poin_diberikan, 0) > 0
),
missing_histories as (
    select ar.*
    from accepted_reports ar
    where not exists (
        select 1
        from public.riwayat_poin rp
        where rp.id_masyarakat = ar.id_masyarakat
          and lower(coalesce(rp.sumber_poin, '')) = 'verifikasi laporan sampah'
          and coalesce(rp.keterangan, '') ilike ('%Laporan #' || ar.id_laporan || '%')
    )
),
inserted_histories as (
    insert into public.riwayat_poin (
        id_masyarakat,
        jenis_transaksi,
        sumber_poin,
        jumlah_poin,
        saldo_setelah,
        keterangan,
        tanggal
    )
    select
        mh.id_masyarakat,
        'Masuk',
        'Verifikasi Laporan Sampah',
        mh.poin_diberikan,
        0,
        'Laporan #' || mh.id_laporan || ' status sinkronisasi',
        mh.tanggal_riwayat
    from missing_histories mh
    returning id_masyarakat, jumlah_poin
),
point_adjustments as (
    select
        id_masyarakat,
        sum(jumlah_poin)::int as total_tambahan_poin
    from inserted_histories
    group by id_masyarakat
),
valid_report_totals as (
    select
        l.id_masyarakat,
        count(*)::int as total_laporan_valid
    from public.laporan_sampah l
    where lower(coalesce(l.status_laporan, '')) in (
        'processing',
        'completed',
        'selesai',
        'valid',
        'diterima',
        'approved'
    )
    group by l.id_masyarakat
)
update public.profiles p
set
    total_poin = coalesce(p.total_poin, 0) + coalesce(pa.total_tambahan_poin, 0),
    total_laporan_valid = coalesce(vrt.total_laporan_valid, 0),
    updated_at = now()
from valid_report_totals vrt
left join point_adjustments pa on pa.id_masyarakat = vrt.id_masyarakat
where p.id = vrt.id_masyarakat;
