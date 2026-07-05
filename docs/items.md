# Sistem Barang & Inventaris (Items) — SimCH Business

Game ini memiliki database produk yang dikelompokkan ke dalam kategori dengan karakteristik ekonomi yang berbeda.

## 1. Struktur Data Barang (Item Properties)
Setiap produk diidentifikasi dengan properti dasar berikut:
* `id` (String): ID unik produk (misal: `grocery_milk`).
* `name` (String): Nama tampilan produk (misal: "Susu Kotak 1L").
* `category` (String): Kategori produk (Sembako, Elektronik, Pakaian).
* `wholesale_price` (Float): Harga beli grosir dari distributor.
* `reference_price` (Float): Harga eceran standar pasar (harga referensi pelanggan).
* `volume` (Int): Kapasitas ruang yang digunakan per barang (di rak/gudang).
* `box_size` (Int): Jumlah unit eceran dalam satu kotak grosir (misal: 1 Box = 10 Unit).

---

## 2. Kategori Produk & Karakteristik

### A. Sembako / Bahan Pangan (Grocery)
* **Karakteristik**: Penjualan sangat cepat, volume penyimpanan kecil, margin keuntungan rendah ($15\% - 30\%$).
* **Contoh**: Roti, Susu, Mi Instan.

### B. Elektronik (Electronics)
* **Karakteristik**: Penjualan lambat, volume penyimpanan besar, margin keuntungan sangat tinggi ($40\% - 80\%$).
* **Contoh**: Ponsel Pintar, Laptop, Kipas Angin.

### C. Pakaian (Clothing)
* **Karakteristik**: Penjualan sedang, volume penyimpanan sedang, sensitivitas harga menengah ($30\% - 50\%$).
* **Contoh**: Kaus Polos, Jaket Hoodie.

---

## 3. Unit Penyimpanan (Inventory Units)
Untuk mensimulasikan sistem logistik retail yang nyata:
* **Unit Grosir (Box)**: Pembelian barang dari distributor dan penyimpanan di **Gudang** dihitung dalam bentuk **Box** (Karton/Kardus).
* **Unit Eceran (Single Unit)**: Ketika barang dipindahkan dari Gudang ke **Rak Toko Ritel**, Box dibuka dan dihitung sebagai **Single Unit**.
* **Konversi**: `1 Box = 10 Unit` (dapat bervariasi per produk). Karyawan Penata Rak bertugas melakukan pembongkaran box ini di area toko.
