# Sistem Bangunan & Properti — SimCH Business

Game ini memiliki sistem bangunan terpisah untuk membagi fungsi penjualan, penyimpanan, dan manajemen.

## 1. Jenis Bangunan (Building Types)

### A. Toko Ritel (Retail Shop)
* **Fungsi**: Tempat utama untuk memajang dan menjual produk kepada pelanggan.
* **Komponen di Dalam Toko**:
  * **Rak Barang**: Menyimpan produk agar bisa diambil oleh pelanggan. Kapasitas penyimpanan di rak sangat terbatas.
  * **Meja Kasir**: Tempat pelanggan mengantre untuk membayar belanjaan mereka.
* **Metrik Utama**: Tingkat Kunjungan Pelanggan (foot traffic), Kapasitas Rak, Jumlah Kasir Aktif.

### B. Gudang (Warehouse)
* **Fungsi**: Pusat penyimpanan stok cadangan dalam jumlah besar yang dikirim oleh distributor.
* **Komponen di Dalam Gudang**:
  * **Rak Palet**: Menyimpan kotak barang grosir berkapasitas besar.
  * **Area Bongkar Muat**: Tempat truk distributor menurunkan barang dan truk logistik pemain memuat barang untuk dikirim ke toko ritel.
* **Metrik Utama**: Kapasitas Palet (Storage Capacity), Kecepatan Bongkar Muat.

### C. Kantor Pusat (HQ / Office) — *Fase Lanjut*
* **Fungsi**: Pusat riset dan pemasaran.
* **Fungsi Utama**: Menjalankan riset produk baru, kampanye iklan untuk mendatangkan lebih banyak pelanggan, dan manajemen cabang toko ritel baru.

---

## 2. Mekanisme Upgrade Bangunan
Pemain dapat meningkatkan efisiensi dan kapasitas bangunan dengan biaya investasi satu kali:

| Bangunan | Jenis Upgrade | Dampak Upgrade |
| :--- | :--- | :--- |
| **Toko Ritel** | Ekspansi Lantai | Menambah luas area untuk menaruh rak dan kasir baru. |
| **Toko Ritel** | Kecepatan Kasir | Mengurangi waktu tunggu pelanggan saat mengantre di kasir. |
| **Gudang** | Kapasitas Palet | Menambah batas maksimal kotak penyimpanan barang. |
| **Gudang** | Forklift/Alat Berat | Mempercepat proses pemindahan barang dari truk ke penyimpanan. |
