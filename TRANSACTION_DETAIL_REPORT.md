# Fitur Transaksi Detail di Halaman Reports

## Deskripsi
Telah ditambahkan fitur baru untuk menampilkan semua transaksi dengan detail lengkap di halaman Reports. Fitur ini memungkinkan pengguna untuk melihat, memfilter, dan menganalisis semua transaksi yang dicatat.

## File yang Ditambahkan

### 1. `lib/features/reports/widgets/transaction_list_filter.dart`
Widget untuk memfilter transaksi berdasarkan:
- **Anggota/Member**: Filter berdasarkan nama anggota
- **Jenis Transaksi**: Pemasukan atau Pengeluaran
- **Periode**: Pilih tanggal mulai dan akhir
- **Pencarian**: Cari berdasarkan catatan/notes
- **Reset**: Tombol untuk mereset semua filter

### 2. `lib/features/reports/widgets/transaction_detail_item.dart`
Widget untuk menampilkan item transaksi individual dengan informasi lengkap:
- Nama anggota dan tanggal transaksi
- Jumlah transaksi dengan warna berbeda (hijau untuk pemasukan, merah untuk pengeluaran)
- Kategori transaksi dan jenis (badge)
- Catatan transaksi
- Detail daging (jika ada item daging)
- Status pembayaran dan sisa pembayaran (jika berlaku)

### 3. `lib/features/reports/widgets/transaction_detail_list_widget.dart`
Widget utama yang menampilkan:
- Filter transaksi (menggunakan `TransactionListFilter`)
- Summary statistik (total pemasukan dan pengeluaran)
- List transaksi yang sudah difilter (menggunakan `TransactionDetailItem`)
- Menampilkan pesan ketika tidak ada transaksi

### 4. Update `lib/features/reports/screens/reports_screen.dart`
Tambahan:
- Import widget baru: `transaction_detail_list_widget.dart`
- Penambahan tipe laporan baru: `'transactions'`
- Button "Transaksi" di selector jenis laporan
- Kondisi untuk menampilkan `TransactionDetailListWidget` ketika tipe laporan adalah `'transactions'`

## Cara Penggunaan

1. Buka halaman **Reports** (Laporan Detail)
2. Klik tab **"Transaksi"** di bagian selector jenis laporan
3. Gunakan filter untuk menyaring transaksi:
   - Pilih anggota tertentu atau semua anggota
   - Pilih jenis transaksi (pemasukan/pengeluaran) atau semua
   - Tentukan periode tanggal
   - Cari berdasarkan catatan
4. Lihat summary pemasukan dan pengeluaran
5. Scroll untuk melihat daftar transaksi detail

## Fitur Filter

### Filter Anggota
- Dropdown untuk memilih anggota spesifik
- Default: Semua Anggota

### Filter Jenis Transaksi
- Pemasukan
- Pengeluaran
- Semua Jenis (default)

### Filter Periode
- Picker tanggal untuk "Dari" dan "Sampai"
- Default: 30 hari terakhir

### Pencarian
- TextField untuk mencari berdasarkan catatan transaksi
- Case-insensitive search

### Reset Filter
- Tombol "Reset" untuk mengembalikan semua filter ke nilai default

## Informasi yang Ditampilkan

Setiap transaksi menampilkan:
1. **Header**:
   - Nama anggota
   - Tanggal dan waktu transaksi
   - Jumlah (dengan tanda +/- dan warna)

2. **Badges**:
   - Kategori (Penjualan Daging, Pembelian Daging, Pelanggan RDFF, Lainnya)
   - Jenis (Pemasukan/Pengeluaran)

3. **Detail Tambahan**:
   - Catatan (jika ada)
   - Detail daging dengan jumlah, harga per kg, dan total (jika ada)
   - Status pembayaran dan sisa pembayaran (jika ada)

## Summary Statistik
Menampilkan total pemasukan dan pengeluaran dalam periode yang dipilih dengan card yang terpisah.

## Integrasi dengan Existing Code
- Menggunakan `TransactionProvider` untuk mengakses data transaksi
- Menggunakan `MemberProvider` untuk mengakses data anggota
- Menggunakan `CurrencyFormatter` untuk format mata uang
- Menggunakan tema dan styling dari `app_colors.dart` dan `app_typography.dart`
