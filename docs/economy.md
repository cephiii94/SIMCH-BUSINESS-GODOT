# Sistem Ekonomi & Keuangan — SimCH Business

Dokumen ini mendefinisikan struktur keuangan game, rumus penetapan harga, pengeluaran operasional, dan simulasi pasar.

## 1. Arus Kas Proyeksi (Cash Flow)
Setiap transaksi keuangan dicatat secara instan dalam sistem buku besar (*ledger*) game:

### Pendapatan (Incomes)
* **Penjualan Toko (Retail Sales)**: Hasil langsung dari pelanggan yang membeli produk di meja kasir.

### Pengeluaran (Expenses)
* **Biaya Pokok Pembelian (Cost of Goods Sold - COGS)**: Pengeluaran untuk membeli barang grosir dari distributor.
* **Gaji Karyawan (Payroll)**: Dibayarkan secara berkala (misal: setiap akhir hari atau setiap akhir minggu).
* **Sewa & Pemeliharaan (Rent & Maintenance)**: Biaya tetap harian untuk sewa gedung toko dan utilitas (listrik, air).
* **Investasi Pembangunan**: Biaya satu kali (*one-time fee*) untuk membangun rak baru, mengupgrade gudang, atau membeli kendaraan logistik.

---

## 2. Rumus & Perhitungan Matematika

### Perhitungan Laba Bersih (Net Profit)
Laba bersih dihitung secara periodik (harian/bulanan):
$$\text{Laba Bersih} = \text{Total Pendapatan} - (\text{COGS} + \text{Total Gaji} + \text{Biaya Sewa} + \text{Biaya Utilitas})$$

### Rumus Penetapan Harga Jual (Pricing)
Pemain dapat menentukan harga jual eceran berdasarkan persentase margin keuntungan:
$$\text{Harga Jual} = \text{Harga Grosir} \times (1 + \text{Margin Margin})$$
* *Rekomendasi Margin*: $20\% \text{ s/d } 80\%$.

### Kurva Permintaan Pelanggan (Demand Elasticity)
Peluang pelanggan membeli suatu barang bergantung pada rasio harga jual terhadap harga pasar wajar (harga referensi):
$$P(\text{beli}) = \frac{1}{1 + e^{A \times \left(\frac{\text{Harga Jual}}{\text{Harga Referensi}} - B\right)}}$$
* Di mana:
  * $A$ adalah tingkat sensitivitas harga (semakin tinggi, semakin cepat peluang turun jika harga mahal).
  * $B$ adalah titik tengah (toleransi harga, biasanya mendekati $1.1$ atau $10\%$ di atas harga pasar).
  * Jika peluang beli rendah, pelanggan akan mengabaikan barang tersebut dan pergi mencari barang lain.
