class_name StaticEntity
extends Node2D

## Node visual untuk menggambarkan Rak dan Kasir secara menjaga Y-sorting dengan karakter,
## lengkap dengan gambar isi barang visual dan animasi membal saat restock/pembelian.

@export var type: String = "rack" # "rack" atau "cashier"
@export var index: int = 0

var last_stock: int = -1

func _ready() -> void:
	# Pastikan node ini mendukung Y-sorting
	y_sort_enabled = true
	queue_redraw()

func _process(_delta: float) -> void:
	# Pantau stok rak jika tipe adalah rak
	if type == "rack" and ShopManager:
		if index >= 0 and index < ShopManager.racks.size():
			var rack = ShopManager.racks[index]
			var current_stock = rack.get("current_stock", 0)
			if current_stock != last_stock:
				if last_stock != -1:
					_play_bounce_animation()
				last_stock = current_stock
				queue_redraw()

## Memutar animasi membal (squash & stretch) secara halus menggunakan Tween
func _play_bounce_animation() -> void:
	var tween = create_tween().set_parallel(false)
	# Squash (memipih mendatar)
	tween.tween_property(self, "scale", Vector2(1.15, 0.85), 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# Stretch (memanjang meninggi)
	tween.tween_property(self, "scale", Vector2(0.92, 1.08), 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	# Kembali normal
	tween.tween_property(self, "scale", Vector2.ONE, 0.06).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func _draw() -> void:
	if type == "rack":
		var rack_color: Color = Color(0.45, 0.32, 0.20, 1.0)
		var rack_border_color: Color = Color(0.60, 0.45, 0.30, 1.0)
		var shadow_color: Color = Color(0.12, 0.08, 0.05, 0.4)
		
		# A. Gambar footprint/bayangan alas di lantai (relatif terhadap 0,0 lokal)
		var foot_rect: Rect2 = Rect2(-40, -40, 80, 80)
		var p1 = GameMap.cartesian_to_iso(foot_rect.position)
		var p2 = GameMap.cartesian_to_iso(Vector2(foot_rect.position.x + foot_rect.size.x, foot_rect.position.y))
		var p3 = GameMap.cartesian_to_iso(foot_rect.position + foot_rect.size)
		var p4 = GameMap.cartesian_to_iso(Vector2(foot_rect.position.x, foot_rect.position.y + foot_rect.size.y))
		draw_polygon(PackedVector2Array([p1, p2, p3, p4]), PackedColorArray([shadow_color]))
		
		# B. Gambar badan rak berdiri tegak (upright)
		var body_rect: Rect2 = Rect2(-36, -75, 72, 75)
		draw_rect(body_rect, rack_color, true)
		draw_rect(body_rect, rack_border_color, false, 3.0)
		
		# Gambar rak tingkat garis-garis
		draw_line(Vector2(-28, -50), Vector2(28, -50), Color(0.15, 0.15, 0.15), 2.0)
		draw_line(Vector2(-28, -25), Vector2(28, -25), Color(0.15, 0.15, 0.15), 2.0)

		# C. Gambar barang yang ada di rak secara visual
		if ShopManager and index >= 0 and index < ShopManager.racks.size():
			var rack = ShopManager.racks[index]
			var item_id = rack.get("item_id", "")
			var current_stock = rack.get("current_stock", 0)
			
			# Tentukan warna barang berdasarkan kategori / item_id
			var item_color = Color(0.8, 0.2, 0.2) # Default merah
			var is_clothing = false
			var is_bread = false
			
			if item_id.begins_with("grocery_milk"):
				item_color = Color(0.2, 0.6, 0.9) # Biru susu
			elif item_id.begins_with("grocery_bread"):
				item_color = Color(0.9, 0.7, 0.3) # Kuning roti
				is_bread = true
			elif item_id.begins_with("clothing"):
				item_color = Color(0.8, 0.3, 0.6) # Pink pakaian
				is_clothing = true
			elif item_id.begins_with("electronics"):
				item_color = Color(0.2, 0.2, 0.2) # Hitam gadget
				
			# Gambar tiap unit barang (maksimal 15 visual item, 5 per tingkat rak)
			var visual_items = min(current_stock, 15)
			for item_idx in range(visual_items):
				var shelf_level = item_idx / 5 # 0 = bawah, 1 = tengah, 2 = atas
				var slot_idx = item_idx % 5 # 0 s/d 4
				
				# Koordinat X: disebar dari -24 ke 24
				var item_x = -24 + slot_idx * 12
				
				# Koordinat Y berdasarkan tingkat rak
				var item_y = 0
				if shelf_level == 0:
					item_y = -3
				elif shelf_level == 1:
					item_y = -28
				else:
					item_y = -53
					
				# Gambar bentuk barang
				var item_rect = Rect2(item_x, item_y - 12, 8, 12)
				if is_clothing:
					# Lipatan baju (horizontal rect)
					draw_rect(Rect2(item_x, item_y - 8, 9, 8), item_color, true)
					draw_rect(Rect2(item_x, item_y - 8, 9, 8), Color(0.1, 0.1, 0.1, 0.3), false, 1.0)
				elif is_bread:
					# Bulatan roti
					draw_circle(Vector2(item_x + 4, item_y - 6), 5, item_color)
					draw_circle(Vector2(item_x + 4, item_y - 6), 5, Color(0.1, 0.1, 0.1, 0.3), false, 1.0)
				else:
					# Kotak/Botol standar
					draw_rect(item_rect, item_color, true)
					draw_rect(item_rect, Color(0.1, 0.1, 0.1, 0.3), false, 1.0)

	elif type == "cashier":
		var cashier_color: Color = Color(0.12, 0.20, 0.28, 1.0)
		var cashier_border_color: Color = Color(0.121569, 0.529412, 0.901961, 1.0)
		
		# A. Gambar alas kasir di lantai
		var foot_rect: Rect2 = Rect2(-40, -40, 80, 80)
		var p1 = GameMap.cartesian_to_iso(foot_rect.position)
		var p2 = GameMap.cartesian_to_iso(Vector2(foot_rect.position.x + foot_rect.size.x, foot_rect.position.y))
		var p3 = GameMap.cartesian_to_iso(foot_rect.position + foot_rect.size)
		var p4 = GameMap.cartesian_to_iso(Vector2(foot_rect.position.x, foot_rect.position.y + foot_rect.size.y))
		draw_polygon(PackedVector2Array([p1, p2, p3, p4]), PackedColorArray([Color(0.08, 0.12, 0.18, 0.5)]))
		
		# B. Gambar meja kasir berdiri tegak (upright)
		var cashier_body: Rect2 = Rect2(-36, -70, 72, 70)
		draw_rect(cashier_body, cashier_color, true)
		draw_rect(cashier_body, cashier_border_color, false, 2.5)
		
		# Gambar mesin kasir kecil berdiri di atas meja
		draw_rect(Rect2(-10, -95, 20, 25), Color(0.8, 0.8, 0.8, 1.0), true)
		draw_rect(Rect2(-6, -87, 12, 10), Color(0.1, 0.1, 0.1, 1.0), true)
