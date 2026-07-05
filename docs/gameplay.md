# Mekanisme Gameplay — SimCH Business

Dokumen ini menjelaskan kontrol, sistem kamera, aksi pemain, dan interaksi entitas di dalam game.

## 1. Perspektif & Kontrol Kamera
* **Perspektif**: Tampilan 2D Top-Down atau Orthographic 2D yang memungkinkan pemain melihat seluruh area toko dan gudang dengan jelas.
* **Kontrol Kamera**:
  * **Geser (Drag)**: Klik kanan dan seret mouse (PC), atau seret dengan satu jari pada area kosong (Mobile).
  * **Perbesar/Perkecil (Zoom)**: Putar roda mouse (PC), atau cubit layar menggunakan dua jari (Mobile).
  * **Batas Kamera**: Kamera memiliki batas area peta (*camera limits*) agar pemain tidak menggeser kamera keluar dari peta permainan.

## 2. Aksi Utama Pemain (Player Actions)
Pemain berinteraksi dengan dunia simulasi melalui serangkaian panel antarmuka:
* **Membangun & Mengupgrade Toko**: Menempatkan rak barang, meja kasir, dan memperluas kapasitas area toko atau gudang.
* **Manajemen Pasokan (Inventory)**: Membeli barang grosir dari katalog distributor dan menyimpannya di gudang utama.
* **Pengaturan Harga (Pricing)**: Mengatur margin keuntungan untuk setiap jenis produk. Harga terlalu mahal membuat barang tidak laku; harga terlalu murah mengurangi profit.
* **Manajemen Karyawan**: Merekrut staf, menetapkan tugas (misal: Kasir atau Penata Rak), serta memantau tingkat produktivitas dan energi mereka.

## 3. Perilaku Pelanggan (Customer Behavior)
Pelanggan adalah entitas otonom yang dikendalikan oleh sistem kecerdasan buatan sederhana:
1. **Muncul (Spawn)**: Pelanggan muncul dari luar area peta dan berjalan menuju toko yang aktif.
2. **Belanja (Shopping)**: Pelanggan mencari produk yang ada dalam daftar belanja pribadi mereka di rak.
3. **Mengantre (Queuing)**: Setelah mendapatkan barang, pelanggan berjalan menuju kasir yang aktif dan mengantre.
4. **Membayar (Paying)**: Kasir memproses pembayaran, menambah uang kas pemain, dan pelanggan meninggalkan area peta.
5. **Kepuasan**: Jika barang habis atau antrean kasir terlalu panjang, pelanggan akan pergi dengan rasa kecewa, yang dapat menurunkan reputasi toko.
