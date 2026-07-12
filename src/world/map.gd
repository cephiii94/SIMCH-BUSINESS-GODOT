class_name GameMap
extends Node2D

## Menggambar tata letak lantai, dinding, loading dock, slot palet, rak toko, dan meja kasir secara dinamis dalam tampilan isometrik 2.5D.

const GRID_SIZE: int = 64
const MAP_SIZE: int = 2000

# Koordinat pusat untuk 16 slot palet di Gudang (Dipindahkan ke sisi kiri / negatif X)
const PALLET_SLOTS: Array = [
	Vector2(-200, -192), Vector2(-320, -192), Vector2(-440, -192), Vector2(-560, -192),
	Vector2(-200, -64), Vector2(-320, -64), Vector2(-440, -64), Vector2(-560, -64),
	Vector2(-200, 64), Vector2(-320, 64), Vector2(-440, 64), Vector2(-560, 64),
	Vector2(-200, 192), Vector2(-320, 192), Vector2(-440, 192), Vector2(-560, 192)
]

## Fungsi pembantu statis untuk mengubah koordinat 2D Kartesian ke Isometrik
static func cartesian_to_iso(cartesian: Vector2) -> Vector2:
	return Vector2(
		cartesian.x - cartesian.y,
		(cartesian.x + cartesian.y) * 0.5
	)

## Dapatkan koordinat dinamis untuk maksimal 6 rak ritel di toko (Dipindahkan ke sisi kanan / positif X).
static func get_rack_position(index: int) -> Vector2:
	var positions: Array = [
		Vector2(400, -192), # Slot 0
		Vector2(400, 0),    # Slot 1
		Vector2(400, 192),   # Slot 2
		Vector2(520, -192), # Slot 3
		Vector2(520, 0),    # Slot 4
		Vector2(520, 192)    # Slot 5
	]
	if index >= 0 and index < positions.size():
		return positions[index]
	return Vector2(400, 0)

func _ready() -> void:
	# Dengarkan perubahan rak untuk menggambar ulang peta
	var shop_mgr: Node = get_node_or_null("/root/ShopManager")
	if shop_mgr:
		shop_mgr.racks_changed.connect(func() -> void: queue_redraw())

## Menggambar persegi panjang Kartesian sebagai poligon isometrik datar
func draw_iso_rect(rect: Rect2, color: Color) -> void:
	var p1 = cartesian_to_iso(rect.position)
	var p2 = cartesian_to_iso(Vector2(rect.position.x + rect.size.x, rect.position.y))
	var p3 = cartesian_to_iso(rect.position + rect.size)
	var p4 = cartesian_to_iso(Vector2(rect.position.x, rect.position.y + rect.size.y))
	draw_polygon(PackedVector2Array([p1, p2, p3, p4]), PackedColorArray([color]))

## Menggambar dinding 2.5D berwujud balok tegak di atas alas isometrik (extruded block)
func draw_extruded_wall(rect: Rect2, height: float, base_color: Color) -> void:
	# Sudut-sudut alas dinding di lantai
	var b1 = cartesian_to_iso(rect.position)
	var b2 = cartesian_to_iso(Vector2(rect.position.x + rect.size.x, rect.position.y))
	var b3 = cartesian_to_iso(rect.position + rect.size)
	var b4 = cartesian_to_iso(Vector2(rect.position.x, rect.position.y + rect.size.y))
	
	# Sudut-sudut atap dinding (digeser ke atas sumbu Y layar)
	var offset = Vector2(0, -height)
	var t1 = b1 + offset
	var t2 = b2 + offset
	var t3 = b3 + offset
	var t4 = b4 + offset
	
	# 1. Sisi Kanan-Depan (dari b3 ke b2 ke t2 ke t3)
	var right_face = PackedVector2Array([b3, b2, t2, t3])
	var right_color = base_color.darkened(0.2)
	draw_polygon(right_face, PackedColorArray([right_color]))
	
	# 2. Sisi Kiri-Depan (dari b4 ke b3 ke t3 ke t4)
	var front_face = PackedVector2Array([b4, b3, t3, t4])
	var front_color = base_color.darkened(0.1)
	draw_polygon(front_face, PackedColorArray([front_color]))
	
	# 3. Sisi Atas/Atap (t1, t2, t3, t4)
	var roof_face = PackedVector2Array([t1, t2, t3, t4])
	var roof_color = base_color.lightened(0.15)
	draw_polygon(roof_face, PackedColorArray([roof_color]))
	
	# Tambahkan garis luar bingkai atap agar visual tegas
	draw_polyline(PackedVector2Array([t1, t2, t3, t4, t1]), base_color.lightened(0.4), 1.5)
	draw_line(t3, b3, base_color.darkened(0.3), 1.5) # Garis sudut tengah ke bawah

func _draw() -> void:
	var half_size: int = MAP_SIZE / 2
	
	# 1. Gambar Area Lantai Isometrik (Toko di kanan, Gudang di kiri)
	# Lantai Toko Ritel (Sisi Kanan, x > 100) - Coklat Kayu Hangat
	draw_iso_rect(Rect2(100, -half_size, half_size - 100, MAP_SIZE), Color(0.24, 0.20, 0.16, 1.0))
	
	# Lantai Gudang (Sisi Kiri, x < -100) - Kelabu Beton
	draw_iso_rect(Rect2(-half_size, -half_size, half_size - 100, MAP_SIZE), Color(0.16, 0.18, 0.21, 1.0))
	
	# Koridor Penghubung Tengah (-100 <= x <= 100) - Abu-Abu Gelap
	draw_iso_rect(Rect2(-100, -half_size, 200, MAP_SIZE), Color(0.12, 0.13, 0.15, 1.0))
	
	# 2. Gambar Garis Kisi-Kisi miring (Grid Overlay)
	var grid_color: Color = Color(0.25, 0.28, 0.33, 0.25)
	for x in range(-half_size, half_size + 1, GRID_SIZE):
		draw_line(cartesian_to_iso(Vector2(x, -half_size)), cartesian_to_iso(Vector2(x, half_size)), grid_color, 1.0)
	for y in range(-half_size, half_size + 1, GRID_SIZE):
		draw_line(cartesian_to_iso(Vector2(-half_size, y)), cartesian_to_iso(Vector2(half_size, y)), grid_color, 1.0)
		
	# 3. Gambar Area Loading Dock Isometrik (Dipindahkan ke kiri: x dari -900 ke -700)
	var dock_rect: Rect2 = Rect2(-900, -150, 200, 300)
	draw_iso_rect(dock_rect, Color(0.18, 0.19, 0.15, 1.0))
	
	# Garis bingkai kuning Loading Dock
	var dock_border_color: Color = Color(0.85, 0.70, 0.10, 1.0)
	var dp1 = cartesian_to_iso(dock_rect.position)
	var dp2 = cartesian_to_iso(Vector2(dock_rect.position.x + dock_rect.size.x, dock_rect.position.y))
	var dp3 = cartesian_to_iso(dock_rect.position + dock_rect.size)
	var dp4 = cartesian_to_iso(Vector2(dock_rect.position.x, dock_rect.position.y + dock_rect.size.y))
	draw_polyline(PackedVector2Array([dp1, dp2, dp3, dp4, dp1]), dock_border_color, 3.0)
	
	# Garis tanda bahaya kuning di loading dock (Dipindahkan ke kiri)
	for y_line in range(-130, 140, 40):
		draw_line(cartesian_to_iso(Vector2(-895, y_line)), cartesian_to_iso(Vector2(-705, y_line + 20)), Color(0.85, 0.70, 0.10, 0.4), 2.0)
 
	# 4. Gambar Penanda Slot Palet di Gudang (16 Slot)
	var slot_border_color: Color = Color(0.3, 0.35, 0.42, 0.6)
	var slot_bg_color: Color = Color(0.2, 0.22, 0.26, 0.5)
	for slot_pos in PALLET_SLOTS:
		var rect: Rect2 = Rect2(slot_pos.x - 40, slot_pos.y - 40, 80, 80)
		draw_iso_rect(rect, slot_bg_color)
		
		# Hubungkan border dengan garis luar isometrik
		var sp1 = cartesian_to_iso(rect.position)
		var sp2 = cartesian_to_iso(Vector2(rect.position.x + rect.size.x, rect.position.y))
		var sp3 = cartesian_to_iso(rect.position + rect.size)
		var sp4 = cartesian_to_iso(Vector2(rect.position.x, rect.position.y + rect.size.y))
		draw_polyline(PackedVector2Array([sp1, sp2, sp3, sp4, sp1]), slot_border_color, 1.5)
		
	# 5. Rak Toko Ritel dan Meja Kasir digambar sebagai StaticEntity terpisah (lihat world.gd) untuk mendukung Y-sorting.

 
	# 7. Gambar Dinding Pembatas Tengah (Krem semi-transparan untuk pembatas koridor)
	var wall_base_color: Color = Color(0.85, 0.80, 0.74, 0.5) # Transparansi 50% krem
	
	# Dinding atas (y dari -half_size sampai -96)
	draw_extruded_wall(Rect2(-100, -half_size, 200, half_size - 96), 40.0, wall_base_color)
	# Dinding bawah (y dari 96 sampai half_size)
	draw_extruded_wall(Rect2(-100, 96, 200, half_size - 96), 40.0, wall_base_color)
	
	# Celah pintu terbuka (y dari -96 ke 96) - Gambar garis ambang pintu
	draw_line(cartesian_to_iso(Vector2(-100, -96)), cartesian_to_iso(Vector2(100, -96)), Color(0.35, 0.35, 0.35), 3.0)
	draw_line(cartesian_to_iso(Vector2(-100, 96)), cartesian_to_iso(Vector2(100, 96)), Color(0.35, 0.35, 0.35), 3.0)
	
	# 8. Gambar Dinding Batas Luar Peta (Solid 80px Tinggi - Krem hangat pejal untuk efek ruangan dalam reference)
	var outer_wall_color: Color = Color(0.85, 0.80, 0.74, 1.0) # Pejal 100% krem
	
	# Dinding batas kiri (x = -half_size)
	draw_extruded_wall(Rect2(-half_size, -half_size, 24, MAP_SIZE), 80.0, outer_wall_color)
	# Dinding batas atas (y = -half_size)
	draw_extruded_wall(Rect2(-half_size, -half_size, MAP_SIZE, 24), 80.0, outer_wall_color)

