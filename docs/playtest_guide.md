# Panduan & Checklist Playtest: SimCH Business (Sprint 1 - 25)

Dokumen ini adalah panduan pengujian manual (**Playtest Guide**) untuk memverifikasi fungsionalitas seluruh fitur yang telah dibangun dari **Sprint 1 hingga Sprint 25**. Gunakan panduan ini untuk menandai hasil pengujian sebelum melangkah ke tahap kompilasi/rilis (Sprint 26 & 27).

---

## Tombol Pintas Debugging & Kontrol (Hotkeys)

Untuk mempercepat pengujian di dalam game, Anda dapat menggunakan tombol keyboard berikut:
- **`W`, `A`, `S`, `D` / Tombol Panah**: Menggeser kamera di game world.
- **Mouse Scroll (Roda Mouse)**: Zoom In (perbesar) dan Zoom Out (perkecil) kamera.
- **Klik Kanan Mouse (Drag)**: Menggeser kamera secara bebas dengan menyeret mouse.
- **Tombol `I`**: Menambah uang kas secara instan sebesar **+$150.00** per ketukan (Gunakan untuk verifikasi pencapaian kas atau belanja besar).
- **Tombol `O`**: Mengurangi uang kas secara instan sebesar **-$75.00** per ketukan.
- **Tombol `ESC`**: Menutup panel modal UI yang sedang aktif (Shop, Warehouse, Staff, Reviews, Achievements, Stats, Settings) dan mengembalikan HUD ke status aktif.

---

## Tabel Checklist Pengujian Fitur

| No | Kategori Fitur | Deskripsi Cara Pengujian | Status (Lulus / Gagal / Belum) | Catatan |
|---|---|---|---|---|
| **A** | **Menu, Pengaturan & Audio** | | | |
| 1 | Menu Utama | Jalankan game. Pastikan tombol *New Game*, *Continue*, *Settings*, dan *Exit* berfungsi. Tombol *Continue* harus mati jika belum ada berkas save file. | `[x]` Lulus | |
| 2 | Pengaturan Volume | Klik **Settings**. Geser slider **Master**, **Music**, atau **SFX** lalu lepaskan. Pastikan terdengar bunyi bip klik retro (`click` SFX) saat dilepaskan. | `[x]` Lulus | |
| 3 | Mute Bus Audio | Setel salah satu slider volume ke 0%. Pastikan suara di bus bersangkutan mati total. | `[x]` Lulus | |
| 4 | Simpan Manual | Klik **Save Game** di Settings. Pastikan teks tombol berubah menjadi *"Game Saved!"* selama 1.5 detik lalu kembali normal. | `[x]` Lulus | |
| 5 | Tombol Kembali | Klik **Back** di Settings. Panel tertutup dan kembali ke Menu Utama/HUD dengan lancar. | `[x]` Lulus | |
| **B** | **Navigasi Kamera & Waktu** | | | |
| 6 | Gerak Kamera | Geser kamera dengan tombol `W/A/S/D` atau seret dengan Klik Kanan mouse. Pastikan gerakannya mulus. | `[x]` Lulus | |
| 7 | Perbesaran Kamera | Putar roda mouse untuk zoom in/out. Pastikan perbesaran dibatasi secara wajar dan tidak pecah. | `[x]` Lulus | |
| 8 | Waktu Operasi | Toko harus dimulai pada pukul **07:00 pagi** (Fase Persiapan) dalam keadaan **TUTUP**. Toko otomatis buka pukul **08:00** dan beroperasi hingga pukul **21:00** (09:00 malam). | `[x]` Lulus | |
| 9 | Kontrol Waktu | Klik tombol kontrol waktu di HUD. Uji **Pause (||)**, **Play (>)** (skala 1x), dan **Fast Forward (>>)** (kecepatan gerak staf, pelanggan, dan seluruh animasi di layar ikut dipercepat 3x lipat!). | `[x]` Lulus | |
| 10 | Siang-Malam | Biarkan waktu melintasi pukul 17:00 s/d 21:00. Pastikan warna layar meredup kebiruan (malam) dan kembali terang pukul 08:00 (siang). | `[x]` Lulus | |
| **C** | **Logistik & Gudang** | | | |
| 11 | Beli Kardus Barang | Buka **Warehouse**. Klik **+1 Box** pada salah satu produk. Pastikan uang berkurang dan kardus fisik (`BoxEntity`) muncul di *Loading Dock* kanan. | `[x]` Lulus | |
| 12 | Animasi Kardus | Amati kardus yang meluncur ke slot palet gudang. Pastikan kardus membal elastis (*squash & stretch*) saat mendarat di slot palet. | `[x]` Lulus | |
| 13 | Sinkronisasi Kardus | Beli **5 Box Susu Kotak 1L** (visual gudang terisi 5 box). Pastikan seluruh 5 box tersebut **ditumpuk secara vertikal (ke atas)** di **satu slot palet yang sama** (tidak tersebar ke 5 slot berbeda). Lakukan Save, keluar ke Menu Utama, lalu klik **Continue**. Pastikan visual tumpukan vertikal 5 kardus tersebut **tetap terpulihkan secara akurat** setelah memuat game. | `[x]` Lulus | |
| 14 | Pengurangan Kardus | Klik **-1 Box** di Warehouse. Kardus paling atas dari tumpukan vertikal harus dihapus (atau meluncur) terlebih dahulu secara akurat, menyisakan tumpukan box di bawahnya secara presisi. | `[x]` Lulus | |
| **D** | **Toko Ritel & Penjualan** | | | |
| 15 | Bangun Rak Baru | Buka **Shop**. Pilih produk di slot kosong, lalu klik **Bangun Rak ($250)**. Pastikan rak ritel digambar di toko. | `[x]` Lulus | |
| 16 | Hancurkan Rak | Klik **Hancurkan (+$100)** pada rak (jumlah rak aktif > 1). Pastikan rak terhapus dari toko dan kas mendapat refund $100.00. | `[x]` Lulus | |
| 17 | Pelanggan Menolak Harga | Buka **Shop**. Patok harga *Susu Kotak 1L* menjadi **$4.00** (markup > 50% dari referensi $2.50). Pelanggan harus membatalkan beli, memunculkan balon merah **"Kemahalan!"**, dan kepuasan berubah menjadi `😡`. | `[x]` Lulus | |
| 18 | Pelanggan Setuju Harga | Setel harga Susu Kotak kembali ke normal **$2.50**. Pelanggan harus kembali membelinya dengan gembira (muncul balon hijau `+1 Susu` di kepalanya). | `[x]` Lulus | |
| 19 | Siklus Checkout | Pelanggan berjalan mengantre di kasir. Saat pembayaran selesai: uang kas bertambah, muncul balon hijau **+$xx.xx**, SFX koin (`cash`) berbunyi, dan pelanggan pulang bersih. | `[x]` Lulus | |
| **E** | **Manajemen Staf & AI** | | | |
| 20 | Rekrut & Pecat Staf | Rekrut pelamar *Stocker* (🔧) dan *Cashier* (😐) di panel **Staff**. Pastikan entitas fisik muncul di peta. Klik **Pecat** untuk menghapusnya secara bersih. | `[x]` Lulus | |
| 21 | AI Kerja Stocker | Biarkan stok rak ritel di bawah 50%. Stocker harus otomatis berjalan ke gudang mengambil kardus, lalu menatanya kembali di rak ritel. | `[x]` Lulus | |
| 22 | Karyawan Lelah | Biarkan energi karyawan 0%. Stocker harus berjalan melambat (kecepatan 20%) dengan ekspresi wajah `😴` dan langkah lesu. Kasir harus melayani lebih lambat (2.0 detik dari sebelumnya 0.6 detik). | `[x]` Lulus | |
| 23 | Reset Energi Harian | Jalankan game hingga berganti hari (mengklik tombol Next Day). Pastikan energi seluruh karyawan pulih kembali ke 100%. | `[x]` Lulus | |
| **F** | **Siklus Hari Kerja Baru, Closing & EOS Dashboard** | | | |
| 24 | Fase Persiapan Pagi | Mulai New Game. Waktu harus berada di pukul **07:00 Pagi** dengan status **[TUTUP]**. Staf aktif harus tampil berdiri bersiaga di layar. Pelanggan baru tidak boleh spawn. Tombol **Buka Toko** harus muncul di HUD. | `[x]` Belum | |
| 25 | Tombol Buka Toko | Klik **Buka Toko**. Pastikan jam melompat ke pukul **08:00**, status toko berubah menjadi **[BUKA]**, tombol buka toko hilang, dan pelanggan mulai berdatangan. | `[x]` Belum | |
| 26 | Penutupan Toko (9 Malam) | Biarkan jam mencapai pukul **21:00**. Status toko di HUD harus berubah menjadi **[TUTUP]** dan spawn pelanggan baru mati. Sisa pelanggan di dalam toko **harus dibiarkan menyelesaikan belanjanya dan melakukan checkout di kasir**. | `[x]` Belum | |
| 27 | Dashboard End of Shift (EOS) | Tepat saat pelanggan terakhir keluar toko (setelah pukul 21:00): Game ter-pause otomatis, karyawan fisik pulang (menghilang dari layar), dan **Stats Panel (Laporan Keuangan)** otomatis terbuka di layar sebagai dashboard ringkasan harian. | `[x]` Belum | |
| 28 | Laporan Keuangan Harian | Di Stats Panel, pastikan diagram garis grafik laba bersih, rincian biaya sewa/utilitas/gaji, dan performa produktivitas staf terupdate. | `[x]` Belum | |
| 29 | Tombol Hari Berikutnya | Tombol **Hari Berikutnya** harus aktif di HUD saat akhir shift. Klik tombol ini: hari bertambah 1, jam kembali ke **07:00 pagi**, karyawan fisik di-spawn ulang, dan tombol "Buka Toko" muncul kembali. | `[x]` Belum | |
| 30 | Buka Pencapaian | Tekan tombol `I` berkali-kali untuk menambah saldo kas melampaui **$15,000.00**. Pastikan muncul popup emas *"PENCAPAIAN TERBUKA"*, bunyi SFX melodi kemenangan (`unlock`), dan status pencapaian berubah menjadi emas *"SELESAI"*. | `[x]` Belum | |
