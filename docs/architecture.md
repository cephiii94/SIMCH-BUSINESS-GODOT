# Arsitektur Teknis — SimCH Business

Dokumen ini menjelaskan rancangan teknis, hirarki scene, struktur folder skrip, Autoload (Singleton), Custom Resources, dan skema penyimpanan data untuk game **SimCH Business** di Godot 4.

---

## 1. Hirarki Scene Utama (Scene Tree)

Game menggunakan struktur scene terpisah untuk memisahkan logika simulasi (`World`), antarmuka pengguna (`UI`), dan kontrol alur permainan (`GameManager`).

```
Main (Node)
├── GameManager (Node) - Mengontrol alur state game (MainMenu, Playing, Paused)
├── World (Node2D) - Memproses visualisasi gameplay 2D
│   ├── Camera2D (Camera2D) - Kamera top-down dengan skrip drag & zoom
│   ├── Map (Node2D/TileMap) - Area bangunan toko dan gudang
│   └── Entities (Node2D) - Penampung instansi Customer dan Employee
└── UI (CanvasLayer) - Manajemen seluruh elemen antarmuka pengguna
    ├── MainMenu (Control) - Layar awal game
    ├── HUD (Control) - Panel informasi atas (Waktu, Kas, dll)
    └── Panels (Control) - Wadah panel pop-up (Shop, Warehouse, Staff, Stats)
```

---

## 2. Struktur Folder Proyek
Semua kode sumber diletakkan di dalam folder `src/` dengan pembagian modular:

```
src/
├── autoload/        # Global Autoload / Singleton (EventBus, TimeManager, dll)
├── core/            # Kelas dasar, Custom Resources, data kalkulasi
├── ui/              # Scene dan skrip UI (.tscn, .gd)
└── world/           # Logika dunia game, kamera, kecerdasan buatan entitas
```

---

## 3. Singleton / Autoload
Sistem-sistem global yang berjalan sepanjang sesi permainan:

### A. `EventBus.gd`
Digunakan sebagai perantara komunikasi sinyal antar sistem agar tetap terputus (*decoupled*). Contoh sinyal:
* `signal time_tick(day: int, hour: int, minute: int)`
* `signal money_changed(new_balance: float)`
* `signal stock_updated(item_id: String, new_count: int)`
* `signal customer_served(revenue: float)`

### B. `TimeManager.gd`
Mengelola sistem waktu dalam game.
* Mengubah detik riil menjadi menit/jam game.
* Mendukung percepatan waktu (`time_scale` = 0.0 untuk pause, 1.0 untuk normal, 3.0 untuk fast-forward).
* Memancarkan sinyal `time_tick` melalui `EventBus` setiap menit game berlalu.

### C. `EconomyManager.gd`
Mengelola keuangan pemain.
* Menyimpan variabel `cash` (uang kas).
* Menangani transaksi masuk (penjualan) dan keluar (gaji, sewa, pembelian grosir).
* Memancarkan sinyal `money_changed` jika ada perubahan saldo.

### D. `DatabaseManager.gd`
* Memuat seluruh database statis barang (`ItemData` Resource) dari folder aset.
* Menyediakan fungsi pencarian data barang berdasarkan ID untuk sistem toko dan gudang.

### E. `SaveManager.gd`
* Menangani serialisasi state game saat ini menjadi format JSON.
* Menyimpan data ke `user://save_game.json` dan memuatnya kembali saat pemain memilih "Continue".

---

## 4. Struktur Data & Custom Resources

### A. `ItemData` (Resource)
Mendefinisikan data statis produk. Disimpan sebagai file `.tres` untuk setiap produk.
* `id: String` (ID unik, misal: `grocery_bread`)
* `name: String` (Nama tampilan)
* `category: String` (Sembako, Elektronik, Pakaian)
* `wholesale_price: float` (Harga beli grosir)
* `reference_price: float` (Harga referensi pasar)
* `box_size: int` (Jumlah unit dalam 1 box grosir)
* `icon: Texture2D` (Sprite produk)

### B. `EmployeeData` (Resource)
Mendefinisikan data karyawan.
* `id: String` (ID acak)
* `name: String` (Nama karyawan)
* `role: String` (Kasir, Penata Rak)
* `speed: float` (Kecepatan kerja)
* `energy: float` (0% - 100%)
* `salary: float` (Gaji harian)

---

## 5. Skema Penyimpanan Data (Save Game Schema - JSON)
Progres permainan disimpan ke file `user://save_game.json` dengan format berikut:

```json
{
  "save_version": 1,
  "game_state": {
    "cash": 15250.50,
    "time": {
      "day": 5,
      "hour": 14,
      "minute": 30
    }
  },
  "warehouse": {
    "capacity_level": 1,
    "inventory": {
      "grocery_milk": 12,
      "grocery_bread": 8,
      "electronics_phone": 2
    }
  },
  "shop": {
    "size_level": 1,
    "pricing": {
      "grocery_milk": 3.50,
      "grocery_bread": 2.20,
      "electronics_phone": 450.00
    },
    "racks": [
      {
        "rack_id": "rack_01",
        "item_id": "grocery_milk",
        "current_stock": 5,
        "max_capacity": 10
      }
    ]
  },
  "employees": [
    {
      "id": "emp_001",
      "name": "Budi",
      "role": "Cashier",
      "speed": 1.2,
      "energy": 85.0,
      "salary": 150.00
    }
  ]
}
```
