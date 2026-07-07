class_name GameMap
extends Node2D

## Menggambar tata letak lantai, dinding, loading dock, slot palet, rak toko, dan meja kasir.

const GRID_SIZE: int = 64
const MAP_SIZE: int = 2000

# Koordinat pusat untuk 16 slot palet di Gudang
const PALLET_SLOTS: Array = [
	Vector2(200, -192), Vector2(320, -192), Vector2(440, -192), Vector2(560, -192),
	Vector2(200, -64), Vector2(320, -64), Vector2(440, -64), Vector2(560, -64),
	Vector2(200, 64), Vector2(320, 64), Vector2(440, 64), Vector2(560, 64),
	Vector2(200, 192), Vector2(320, 192), Vector2(440, 192), Vector2(560, 192)
]

# Koordinat pusat untuk 3 rak eceran di Toko
const SHOP_RACKS: Array = [
	Vector2(-400, -192),
	Vector2(-400, 0),
	Vector2(-400, 192)
]

func _draw() -> void:
	var half_size: int = MAP_SIZE / 2
	
	# 1. Gambar Area Lantai
	# Lantai Toko Ritel (Sisi Kiri, x < -100) - Coklat Kayu Hangat
	draw_rect(Rect2(-half_size, -half_size, half_size - 100, MAP_SIZE), Color(0.24, 0.20, 0.16, 1.0))
	
	# Lantai Gudang (Sisi Kanan, x > 100) - Kelabu Beton
	draw_rect(Rect2(100, -half_size, half_size - 100, MAP_SIZE), Color(0.16, 0.18, 0.21, 1.0))
	
	# Koridor Penghubung Tengah (-100 <= x <= 100) - Abu-Abu Gelap
	draw_rect(Rect2(-100, -half_size, 200, MAP_SIZE), Color(0.12, 0.13, 0.15, 1.0))
	
	# 2. Gambar Garis Kisi-Kisi (Grid Overlay)
	var grid_color: Color = Color(0.25, 0.28, 0.33, 0.25) # Sangat tipis agar tidak mengganggu visual
	for x in range(-half_size, half_size + 1, GRID_SIZE):
		draw_line(Vector2(x, -half_size), Vector2(x, half_size), grid_color, 1.0)
	for y in range(-half_size, half_size + 1, GRID_SIZE):
		draw_line(Vector2(-half_size, y), Vector2(half_size, y), grid_color, 1.0)
		
	# 3. Gambar Area Loading Dock (Bongkar Muat, Sisi Kanan: x dari 700 ke 900, y dari -150 ke 150)
	var dock_rect: Rect2 = Rect2(700, -150, 200, 300)
	draw_rect(dock_rect, Color(0.18, 0.19, 0.15, 1.0)) # Latar belakang semen kasar
	
	# Gambar bingkai garis kuning-hitam di sekeliling Loading Dock
	var dock_border_color: Color = Color(0.85, 0.70, 0.10, 1.0) # Kuning cerah
	draw_rect(dock_rect, dock_border_color, false, 3.0)
	
	# Gambar garis-garis silang tanda bahaya kuning di loading dock
	for y_line in range(-130, 140, 40):
		draw_line(Vector2(705, y_line), Vector2(895, y_line + 20), Color(0.85, 0.70, 0.10, 0.4), 2.0)

	# 4. Gambar Penanda Slot Palet di Gudang (16 Slot)
	var slot_border_color: Color = Color(0.3, 0.35, 0.42, 0.6)
	var slot_bg_color: Color = Color(0.2, 0.22, 0.26, 0.5)
	for slot_pos in PALLET_SLOTS:
		# Slot berukuran 80x80 piksel
		var rect: Rect2 = Rect2(slot_pos.x - 40, slot_pos.y - 40, 80, 80)
		draw_rect(rect, slot_bg_color, true)
		draw_rect(rect, slot_border_color, false, 1.5)
		
	# 5. Gambar Rak Toko Ritel (3 Unit di Toko)
	var rack_color: Color = Color(0.45, 0.32, 0.20, 1.0) # Kayu coklat
	var rack_border_color: Color = Color(0.60, 0.45, 0.30, 1.0) # Kayu terang untuk bingkai
	for rack_pos in SHOP_RACKS:
		# Ukuran rak: 80x80 piksel
		var rect: Rect2 = Rect2(rack_pos.x - 40, rack_pos.y - 40, 80, 80)
		draw_rect(rect, rack_color, true)
		draw_rect(rect, rack_border_color, false, 3.0)
		# Gambar rak tingkat garis-garis
		draw_line(Vector2(rack_pos.x - 30, rack_pos.y - 15), Vector2(rack_pos.x + 30, rack_pos.y - 15), Color(0.15, 0.15, 0.15), 2.0)
		draw_line(Vector2(rack_pos.x - 30, rack_pos.y + 15), Vector2(rack_pos.x + 30, rack_pos.y + 15), Color(0.15, 0.15, 0.15), 2.0)

	# 6. Gambar Meja Kasir (1 Unit di Toko, posisi -200, 0)
	var cashier_color: Color = Color(0.12, 0.20, 0.28, 1.0) # Biru navy/mahoni gelap
	var cashier_border_color: Color = Color(0.121569, 0.529412, 0.901961, 1.0) # Aksen biru muda
	var cashier_rect: Rect2 = Rect2(-240, -40, 80, 80)
	draw_rect(cashier_rect, cashier_color, true)
	draw_rect(cashier_rect, cashier_border_color, false, 2.5)
	# Gambar mesin kasir kecil
	draw_rect(Rect2(-210, -15, 20, 30), Color(0.8, 0.8, 0.8, 1.0), true)
	draw_rect(Rect2(-205, -5, 10, 10), Color(0.1, 0.1, 0.1, 1.0), true)

	# 7. Gambar Dinding Pembatas Tengah
	# Dinding Kiri Pembatas Toko (x = -100) dan Dinding Kanan Pembatas Gudang (x = 100)
	var wall_color: Color = Color(0.08, 0.09, 0.11, 1.0)
	
	# Dinding atas (y dari -half_size sampai -96)
	draw_rect(Rect2(-100, -half_size, 200, half_size - 96), wall_color)
	# Dinding bawah (y dari 96 sampai half_size)
	draw_rect(Rect2(-100, 96, 200, half_size - 96), wall_color)
	
	# Celah pintu berada di x antara -100 dan 100, y dari -96 ke 96 (Pintu Terbuka)
	# Gambar bingkai pintu
	draw_line(Vector2(-100, -96), Vector2(100, -96), Color(0.35, 0.35, 0.35), 3.0)
	draw_line(Vector2(-100, 96), Vector2(100, 96), Color(0.35, 0.35, 0.35), 3.0)
