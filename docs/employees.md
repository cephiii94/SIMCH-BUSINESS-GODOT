# Sistem Karyawan (Employees) — SimCH Business

Untuk mengotomatisasi operasional bisnis, pemain dapat merekrut karyawan dengan berbagai peran dan statistik kerja.

## 1. Peran Karyawan (Employee Roles)

### A. Kasir (Cashier)
* **Tanggung Jawab**: Berjaga di meja kasir toko ritel, melayani transaksi pelanggan, dan memproses pembayaran.
* **Metrik Utama**: Kecepatan Transaksi. Jika kasir lambat, antrean akan memanjang dan membuat pelanggan tidak sabar (bisa membatalkan belanja).

### B. Penata Rak (Stocker / Clerk)
* **Tanggung Jawab**: Memantau kapasitas rak toko ritel. Jika rak kosong, Stocker pergi ke Gudang, mengambil Box barang, membukanya, dan menyusun produk di rak toko ritel.
* **Metrik Utama**: Kecepatan Jalan, Kecepatan Penataan Rak.

### C. Sopir Truk (Truck Driver) — *Fase Logistik*
* **Tanggung Jawab**: Mengemudikan kendaraan logistik untuk memindahkan barang dari Gudang Utama ke Toko-Toko Cabang.

---

## 2. Statistik Karyawan (Employee Stats)
Setiap karyawan memiliki profil dengan statistik unik yang memengaruhi kinerjanya:
1. **Kecepatan (Speed)**: Menentukan seberapa cepat mereka berjalan atau memproses transaksi/barang.
2. **Energi (Energy)**: Bernilai `0% - 100%`. Energi berkurang saat bekerja. Jika energi di bawah `20%`, kecepatan kerja melambat drastis. Jika mencapai `0%`, mereka harus beristirahat di ruang istirahat (*break room*).
3. **Kepuasan/Loyalitas (Satisfaction)**: Dipengaruhi oleh ketepatan pembayaran gaji. Jika kepuasan terlalu rendah, mereka bisa mengajukan pengunduran diri.
4. **Gaji Harian (Daily Wage)**: Biaya operasional tetap harian yang harus dibayarkan pemain untuk mempertahankan karyawan tersebut.

---

## 3. Rekrutmen & Pasar Tenaga Kerja (Labor Market)
* **Merekrut**: Pemain dapat membuka panel rekrutmen untuk melihat daftar calon karyawan yang melamar (dengan statistik dan ekspektasi gaji acak).
* **Biaya Rekrut**: Ada biaya administrasi awal saat mempekerjakan karyawan baru.
* **Memecat**: Pemain dapat memecat karyawan kapan saja tanpa pesangon (atau dengan pesangon kecil harian) untuk menghemat biaya operasional saat bisnis sedang sepi.
