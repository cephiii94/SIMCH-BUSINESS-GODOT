# Walkthrough: Fase 2 & Fase 3 — Core and Expansion Systems

Dokumen ini mendokumentasikan pengerjaan, struktur file, dan cara memverifikasi sistem utama: **Sistem Karyawan Ritel (Sprint 13)**, **Sistem Reputasi Toko**, **Sistem Penyimpanan & Pemuatan (Sprint 14)**, **Sistem Properti Ritel (Sprint 15)**, dan **Sistem Peristiwa Acak Harian (Sprint 18)**.

---

## 1. Sistem Karyawan Ritel (Employee System — Sprint 13)

### Ringkasan Perubahan
* **[staff_manager.gd](file:///d:/ME/VSCODE/SIMCH-BUSINESS-GODOT/src/autoload/staff_manager.gd)**:
  * Bursa kerja lowongan dengan pelamar kerja (peran Kasir & Stocker) dengan nominal gaji harian, kecepatan kerja, dan biaya rekrutmen awal.
  * Logika mempekerjakan (`hire_employee`) memotong uang investasi awal dan memecat (`fire_employee`).
* **[economy_manager.gd](file:///d:/ME/VSCODE/SIMCH-BUSINESS-GODOT/src/autoload/economy_manager.gd)**:
  * Memodifikasi fungsi ganti hari agar menjumlahkan seluruh gaji harian staf aktif di `StaffManager` dan memotong kas secara otomatis sebagai biaya gaji (`ExpenseType.WAGES`).
* **[employee_entity.tscn](file:///d:/ME/VSCODE/SIMCH-BUSINESS-GODOT/src/world/employee_entity.tscn)** & **[employee_entity.gd](file:///d:/ME/VSCODE/SIMCH-BUSINESS-GODOT/src/world/employee_entity.gd)**:
  * Karyawan diwakili oleh lingkaran berwarna hijau (Stocker, emoticon `🔧`) dan merah muda (Cashier, emoticon `😐`).
  * **Kasir (Cashier AI)**: Berjalan menuju meja kasir dan bersiap menjaga di sana secara pencapaian untuk mempercepat checkout antrean pelanggan dari 1.8s menjadi **0.6s**.
  * **Penata Rak (Stocker AI)**: Memantau rak eceran toko secara otonom. Jika stok rak di bawah 50% kapasitas, ia otomatis berjalan ke gudang mengambil box barang, memicu restock di data, dan berjalan kembali ke rak toko untuk menata persediaan eceran.
* **[staff_panel.tscn](file:///d:/ME/VSCODE/SIMCH-BUSINESS-GODOT/src/ui/staff_panel.tscn)** & **[staff_panel.gd](file:///d:/ME/VSCODE/SIMCH-BUSINESS-GODOT/src/ui/staff_panel.gd)**:
  * Panel UI manajemen staf dengan 2 Tab (Staf Aktif & Lowongan Kerja) untuk merekrut dan memecat karyawan.

---

## 2. Sistem Reputasi & Ulasan Komentar Pelanggan

### Ringkasan Perubahan
* **[reputation_manager.gd](file:///d:/ME/VSCODE/SIMCH-BUSINESS-GODOT/src/autoload/reputation_manager.gd)**:
  * Menghitung rating bintang berjalan (*rolling average*) secara dinamis dari ulasan-ulasan belanja pembeli.
  * `generate_customer_review(...)` menentukan rating bintang (1-5 Bintang) berdasarkan rasio keberhasilan belanja dan keberadaan kasir aktif, serta menggenerasikan komentar ulasan yang serasi.
* **[world.gd](file:///d:/ME/VSCODE/SIMCH-BUSINESS-GODOT/src/world/world.gd)**:
  * Mengintegrasikan rating reputasi aktif dengan laju kedatangan pelanggan:
    * **Rating Ramai (`>= 4.0`)**: Pelanggan memijah cepat (6 s/d 10 detik).
    * **Rating Sedang (`2.5 - 4.0`)**: Pelanggan memijah normal (10 s/d 15 detik).
    * **Rating Sepi (`< 2.5`)**: Pelanggan memijah lambat (16 s/d 22 detik).
* **[reputation_panel.tscn](file:///d:/ME/VSCODE/SIMCH-BUSINESS-GODOT/src/ui/reputation_panel.tscn)** & **[reputation_panel.gd](file:///d:/ME/VSCODE/SIMCH-BUSINESS-GODOT/src/ui/reputation_panel.gd)**:
  * Panel ulasan terbaru pelanggan lengkap dengan skor rata-rata (misal: `4.2 ⭐`) dan komentar yang diberi warna visual.
* **[hud.tscn](file:///d:/ME/VSCODE/SIMCH-BUSINESS-GODOT/src/ui/hud.tscn)** & **[hud.gd](file:///d:/ME/VSCODE/SIMCH-BUSINESS-GODOT/src/ui/hud.gd)**:
  * Menampilkan bintang rating berjalan `⭐ 4.0` di bar atas HUD dan tombol **Reviews** di bar bawah HUD.

---

## 3. Sistem Penyimpanan & Pemuatan Game (Save & Load — Sprint 14)

### Ringkasan Perubahan
* **[save_manager.gd](file:///d:/ME/VSCODE/SIMCH-BUSINESS-GODOT/src/autoload/save_manager.gd)**:
  * **Save**: Mengubah seluruh status permainan aktif (waktu, saldo kas, laporan harian, persediaan gudang, status rak ritel, harga produk, profil staf yang dipekerjakan, dan riwayat ulasan reputasi) menjadi format teks JSON dan menulisnya ke file `user://save_game.json`.
  * **Load**: Membaca file JSON, mengurai datanya, merekonstruksi kondisi seluruh singleton/manager permainan, dan memerintahkan dunia game untuk menyinkronkan kembali entitas fisik secara asinkron.
  * **Auto Save**: Menyambungkan ke sinyal `daily_report_generated` untuk melakukan penyimpanan otomatis secara otonom ke berkas setiap kali pergantian hari terjadi (tengah malam).
* **[world.gd](file:///d:/ME/VSCODE/SIMCH-BUSINESS-GODOT/src/world/world.gd)**:
  * Menambahkan fungsi `load_warehouse_boxes()` untuk secara instan menghapus box visual lama dan memposisikan box visual baru di slot palet gudang yang sesuai setelah game dimuat.
* **[settings_menu.tscn](file:///d:/ME/VSCODE/SIMCH-BUSINESS-GODOT/src/ui/settings_menu.tscn)** & **[settings_menu.gd](file:///d:/ME/VSCODE/SIMCH-BUSINESS-GODOT/src/ui/settings_menu.gd)**:
  * Menyisipkan tombol **Save Game** baru di menu Settings.
  * Menghubungkan klik tombol untuk memanggil `SaveManager.save_game()` dan memperbarui teks tombol secara interaktif menjadi *"Game Saved!"* selama 1.5 detik.
* **[game_manager.gd](file:///d:/ME/VSCODE/SIMCH-BUSINESS-GODOT/src/core/game_manager.gd)**:
  * Memanggil `SaveManager.load_game()` ketika tombol **Continue** di menu utama ditekan.
  * Mengontrol visibilitas tombol **Save Game** di menu Settings secara dinamis (hanya terlihat ketika sedang berada di dalam permainan).

---

## 4. Sistem Konstruksi & Properti Ritel (Building System — Sprint 15)

### Ringkasan Perubahan
* **[shop_manager.gd](file:///d:/ME/VSCODE/SIMCH-BUSINESS-GODOT/src/autoload/shop_manager.gd)**:
  * Mendeklarasikan sinyal `racks_changed` saat terjadi perubahan pada struktur penempatan rak di toko ritel.
  * `build_rack(item_id)`: Memotong uang modal `$250` untuk membangun rak baru berkapasitas dasar di slot kosong aktif (mendukung maksimal hingga 6 rak).
  * `upgrade_rack(rack_idx)`: Mengurangi uang kas sesuai biaya tingkat upgrade ($150 / $300) untuk menggandakan kapasitas stok rak eceran.
  * `destroy_rack(rack_idx)`: Menghapus rak dari array, membuang stok, dan mengembalikan uang refund investasi sebesar `$100`.
* **[map.gd](file:///d:/ME/VSCODE/SIMCH-BUSINESS-GODOT/src/world/map.gd)**:
  * Menghubungkan sinyal `racks_changed` ke `queue_redraw()` untuk memperbarui visual peta toko secara real-time.
  * `get_rack_position(index)` mendefinisikan layout 2 grid baris rak di sisi barat toko ritel. Gambar rak coklat akan otomatis digambar dinamis sesuai jumlah rak aktif di data.
* **[world.gd](file:///d:/ME/VSCODE/SIMCH-BUSINESS-GODOT/src/world/world.gd)**:
  * `sync_racks()` secara dinamis memperbarui node Marker2D (`Slot0` s/d `Slot5`) di bawah `RackSlots` agar AI pelanggan dan Stocker otomatis menyesuaikan rute jalan menuju rak baru tersebut saat di-build atau di-destroy.
* **[shop_panel.gd](file:///d:/ME/VSCODE/SIMCH-BUSINESS-GODOT/src/ui/shop_panel.gd)**:
  * Menampilkan tombol **Upgrade** dan **Hancurkan** di bawah setiap baris rak aktif.
  * Menyediakan baris slot kosong di paling bawah panel lengkap dengan OptionButton dropdown pilihan produk dari database dan tombol **Bangun Rak ($250)**.

---

## 5. Sistem Peristiwa Acak Harian (Random Events — Sprint 18)

### Ringkasan Perubahan
* **[event_manager.gd](file:///d:/ME/VSCODE/SIMCH-BUSINESS-GODOT/src/autoload/event_manager.gd)**:
  * Singleton otonom baru untuk mengelola pemicuan peristiwa harian (peluang 40% terjadi pada pagi hari).
  * Menyediakan modifikator event aktif, seperti `customer_spawn_mult`, pengali harga beli grosir (`grocery_milk_wholesale_mult`, `grocery_bread_wholesale_mult`), `staff_speed_mult`, dan denda instan `immediate_cash_deduct`.
* **[event_popup.tscn](file:///d:/ME/VSCODE/SIMCH-BUSINESS-GODOT/src/ui/event_popup.tscn)** & **[event_popup.gd](file:///d:/ME/VSCODE/SIMCH-BUSINESS-GODOT/src/ui/event_popup.gd)**:
  * Halaman koran berita utama premium *"THE RETAIL POST"* berlatar belakang kertas koran daur ulang hangat dan tinta arang. Tampil menjeda permainan (jeda waktu) secara otomatis pada pukul 08:00 pagi saat event terpicu.
* **[shop_manager.gd](file:///d:/ME/VSCODE/SIMCH-BUSINESS-GODOT/src/autoload/shop_manager.gd)**:
  * Menambahkan metode `get_wholesale_price(item_id)` untuk merumuskan harga beli grosir reaktif yang terpengaruh peristiwa pasar (inflasi/subsidi) secara dinamis.
* **[warehouse_panel.gd](file:///d:/ME/VSCODE/SIMCH-BUSINESS-GODOT/src/ui/warehouse_panel.gd)**:
  * Menghubungkan visualisasi label harga di gudang retail ke `ShopManager.get_wholesale_price(item_id)`.
  * Memotong uang kas pemain secara nyata (`record_expense`) saat memesan box barang grosir.
* **[world.gd](file:///d:/ME/VSCODE/SIMCH-BUSINESS-GODOT/src/world/world.gd)**:
  * Mengalikan laju kedatangan pelanggan dengan modifikator cuaca/pasar (`customer_spawn_mult`) dari event aktif.
  * Memicu pemunculan visual `EventPopup` pada pukul 08:00 pagi.
* **[employee_entity.gd](file:///d:/ME/VSCODE/SIMCH-BUSINESS-GODOT/src/world/employee_entity.gd)**:
  * Mengalikan kecepatan berjalan karyawan dengan modifikator `staff_speed_mult` dari event aktif.
* **[save_manager.gd](file:///d:/ME/VSCODE/SIMCH-BUSINESS-GODOT/src/autoload/save_manager.gd)**:
  * Mengintegrasikan penyimpanan status `active_event` dan `event_shown_today` ke dalam save file JSON agar peristiwa acak tetap konsisten berjalan setelah pemuatan game.

---

## Verifikasi & Cara Pengujian (Sprint 18)

Buka proyek di **Godot Engine**, jalankan game, dan lakukan langkah pengujian berikut:

1. **Uji Koran Pagi (Pukul 08:00)**:
   * Mainkan game, biarkan waktu berjalan hingga berganti ke hari berikutnya.
   * Pada pukul 08:00 pagi saat toko dibuka, pastikan game terjedah dan koran berita utama muncul menjelaskan situasi hari itu.
2. **Uji Efek Fluktuasi Harga (Gudang)**:
   * Jika koran pagi memuat judul **"Kelangkaan Susu Sapi"**, buka panel **Warehouse**.
   * Pastikan harga beli grosir Susu Kotak naik 50% dan terwarnai merah pudar (menunjukkan kenaikan harga).
   * Pastikan uang kas terpotong sesuai harga baru tersebut saat Anda mengklik tombol **+1 Box**.
3. **Uji Efek Laju Pengunjung**:
   * Jika koran memuat judul **"Hari Pasar Meriah"**, amati laju kedatangan pembeli baru. Interval kedatangan mereka akan jauh lebih cepat.
   * Jika koran memuat judul **"Hujan Badai Besar"**, kedatangan pembeli baru akan melambat secara signifikan.
4. **Uji Efek Kerja Staf**:
   * Jika koran memuat judul **"Hari Apresiasi Pekerja"**, amati gerakan jalan penata rak (Stocker). Kecepatan jalan mereka bertambah gesit 30%.
5. **Uji Save & Load**:
   * Simpan game sewaktu event aktif masih berlangsung.
   * Muat kembali game via **Continue**, pastikan data event aktif tetap persis berjalan konsisten.
