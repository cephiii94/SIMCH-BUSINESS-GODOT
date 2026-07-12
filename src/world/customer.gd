class_name CustomerAI
extends Node2D

## Mengatur kecerdasan buatan, pergerakan navigasi, daftar belanja, dan transaksi pembayaran pelanggan.

@onready var visual_rect: PanelContainer = %VisualRect
@onready var face_label: Label = %FaceLabel
@onready var action_label: Label = %ActionLabel
@onready var float_label: Label = %FloatLabel

var speed: float = 130.0
var state: String = "SPAWNING" # SPAWNING, SHOPPING, QUEUING, PAYING, LEAVING

var shopping_list: Array = []
var basket: Array = []
var current_list_idx: int = 0
var satisfaction: String = "😊"
var overprice_complaints: int = 0

var paying_timer: float = 0.0

var _world_node: Node2D = null

func _ready() -> void:
	# Hubungkan referensi World
	var scene_root: Node = get_tree().current_scene
	if scene_root:
		_world_node = scene_root.get_node_or_null("World") as Node2D
		
	# Inisialisasi daftar belanja acak dari rak yang tersedia berdasarkan peluang kategori
	if ShopManager and DatabaseManager:
		var candidate_items: Array = []
		for rack in ShopManager.racks:
			var item_id: String = rack["item_id"]
			var item_ref = DatabaseManager.get_item(item_id)
			if item_ref:
				var chance: float = 0.5
				match item_ref.category:
					"Grocery":
						chance = 0.85
					"Clothing":
						chance = 0.45
					"Electronics":
						chance = 0.15
				
				if randf() <= chance:
					candidate_items.append(item_id)
					
		# Fallback jika tidak ada kandidat lolos, pilih rak pertama
		if candidate_items.size() == 0 and ShopManager.racks.size() > 0:
			candidate_items.append(ShopManager.racks[0]["item_id"])
			
		if candidate_items.size() > 0:
			candidate_items.shuffle()
			var buy_count: int = randi_range(1, min(3, candidate_items.size()))
			for i in range(buy_count):
				shopping_list.append(candidate_items[i])

				
	# Atur visual awal
	face_label.text = satisfaction
	action_label.text = "Masuk..."
	float_label.hide()
	
	# Random warna baju pelanggan
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = Color(randf_range(0.2, 0.8), randf_range(0.2, 0.8), randf_range(0.2, 0.8), 1.0)
	style.corner_radius_top_left = 24
	style.corner_radius_top_right = 24
	style.corner_radius_bottom_right = 24
	style.corner_radius_bottom_left = 24
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.1, 0.1, 0.1)
	if visual_rect:
		visual_rect.add_theme_stylebox_override("panel", style)

func _process(delta: float) -> void:
	# Jika game di-pause (time_scale == 0), jangan berjalan
	if TimeManager and TimeManager.time_scale == 0.0:
		return
		
	# Animasi berjalan memantul (bobbing sinus)
	if state in ["SHOPPING", "QUEUING", "LEAVING", "SPAWNING"] and global_position.distance_squared_to(_get_current_target_position()) > 36.0:
		var bob_y = abs(sin(Time.get_ticks_msec() * 0.012)) * -6.0
		if visual_rect:
			visual_rect.position.y = bob_y
	else:
		if visual_rect:
			visual_rect.position.y = 0.0
			
	if state == "PAYING":
		# Logika menghitung waktu pembayaran di kasir
		paying_timer -= delta
		if paying_timer <= 0.0:
			_process_checkout()
		return
		
	# Logika pergerakan navigasi
	var target_pos: Vector2 = _get_current_target_position()
	if global_position.distance_squared_to(target_pos) > 36.0:
		var dir: Vector2 = (target_pos - global_position).normalized()
		global_position += dir * speed * delta
	else:
		_on_reach_target()


## Mendapatkan koordinat tujuan sesuai state saat ini.
func _get_current_target_position() -> Vector2:
	if not _world_node:
		return global_position
		
	match state:
		"SPAWNING":
			# Pintu masuk toko di koridor sisi kanan
			return GameMap.cartesian_to_iso(Vector2(150, 150))
		"SHOPPING":
			# Koordinat rak barang yang ditargetkan
			if current_list_idx < shopping_list.size():
				var target_item_id: String = shopping_list[current_list_idx]
				var rack_idx: int = _find_rack_idx_for_item(target_item_id)
				if rack_idx != -1:
					var rack_slots: Node2D = _world_node.get_node_or_null("RackSlots") as Node2D
					if rack_slots:
						var slot: Marker2D = rack_slots.get_node_or_null("Slot" + str(rack_idx)) as Marker2D
						if slot:
							return slot.global_position
			return GameMap.cartesian_to_iso(Vector2(150, 150))
		"QUEUING":
			# Mengantre di kasir sisi kanan
			var cashier: Marker2D = _world_node.get_node_or_null("CashierRegister") as Marker2D
			if cashier:
				return cashier.global_position
			return GameMap.cartesian_to_iso(Vector2(200, 0))
		"LEAVING":
			# Kembali ke titik keluar jalan raya sisi kanan
			var spawn_pt: Marker2D = _world_node.get_node_or_null("CustomerSpawnPoint") as Marker2D
			if spawn_pt:
				return spawn_pt.global_position
			return GameMap.cartesian_to_iso(Vector2(850, 200))
		_:
			return global_position

func _find_rack_idx_for_item(item_id: String) -> int:
	if not ShopManager:
		return -1
	for i in range(ShopManager.racks.size()):
		if ShopManager.racks[i]["item_id"] == item_id:
			return i
	return -1

## Logika eksekusi ketika pelanggan sampai di target pergerakan.
func _on_reach_target() -> void:
	match state:
		"SPAWNING":
			state = "SHOPPING"
			current_list_idx = 0
			action_label.text = "Belanja..."
		"SHOPPING":
			_shop_current_item()
		"QUEUING":
			state = "PAYING"
			
			var has_cashier: bool = false
			var cashier_energy: float = 100.0
			var staff_mgr: Node = get_node_or_null("/root/StaffManager")
			if staff_mgr:
				for staff in staff_mgr.hired_staff:
					if staff["role"] == "Cashier":
						has_cashier = true
						cashier_energy = staff.get("energy", 100.0)
						break
						
			if has_cashier:
				if cashier_energy <= 0.0:
					paying_timer = 2.0 # Kasir lelah melayani lambat
				else:
					paying_timer = 0.6
			else:
				paying_timer = 1.8
			action_label.text = "Membayar..."

		"LEAVING":
			queue_free()

func _shop_current_item() -> void:
	if current_list_idx >= shopping_list.size() or not ShopManager:
		state = "QUEUING"
		action_label.text = "Ke Kasir..."
		return
		
	var target_item_id: String = shopping_list[current_list_idx]
	var rack_idx: int = _find_rack_idx_for_item(target_item_id)
	
	if rack_idx != -1:
		var rack: Dictionary = ShopManager.racks[rack_idx]
		# Ambil barang dari rak jika stok masih ada
		if rack["current_stock"] > 0:
			var item_ref = DatabaseManager.get_item(target_item_id)
			var price: float = ShopManager.get_price(target_item_id)
			var ref_price: float = item_ref.reference_price if item_ref else price
			
			var markup: float = price / ref_price if ref_price > 0.0 else 1.0
			var buy_chance: float = 1.0
			if markup > 1.0:
				# Markup 1.25x -> 50% peluang. Markup >= 1.5x -> 0% peluang
				buy_chance = clamp(1.0 - (markup - 1.0) * 2.0, 0.0, 1.0)
				
			if randf() <= buy_chance:
				rack["current_stock"] -= 1
				basket.append(target_item_id)
				_show_temp_feedback("+1 " + item_ref.name.split(" ")[0])
			else:
				# Komplain harga terlalu mahal
				overprice_complaints += 1
				satisfaction = "😡"
				face_label.text = satisfaction
				_show_temp_feedback("Kemahalan!")
		else:
			# Kecewa jika stok habis
			satisfaction = "😡"
			face_label.text = satisfaction
			_show_temp_feedback("Habis!")
			
	# Lanjut ke item berikutnya di daftar belanja
	current_list_idx += 1
	if current_list_idx >= shopping_list.size():
		state = "QUEUING"
		action_label.text = "Ke Kasir..."
	else:
		state = "SHOPPING"

func _process_checkout() -> void:
	var total_served_revenue: float = 0.0
	
	# Cek apakah ada kasir aktif
	var has_cashier: bool = false
	var active_cashier_id: String = ""
	var staff_mgr: Node = get_node_or_null("/root/StaffManager")
	if staff_mgr:
		for staff in staff_mgr.hired_staff:
			if staff["role"] == "Cashier":
				has_cashier = true
				active_cashier_id = staff["id"]
				break
				
	# Catat kontribusi kasir jika ada
	if has_cashier and active_cashier_id != "":
		staff_mgr.record_staff_work(active_cashier_id, 1, 1.0) # Kurangi 1.0% energi kasir, tambah 1 produktivitas
				
	# Picu ulasan di ReputationManager
	var rep_mgr: Node = get_node_or_null("/root/ReputationManager")

	if rep_mgr:
		if rep_mgr.has_method("generate_customer_review"):
			rep_mgr.generate_customer_review(basket.size(), shopping_list.size(), has_cashier, overprice_complaints)
		else:
			rep_mgr.generate_customer_review(basket.size(), shopping_list.size(), has_cashier)

		
	if basket.size() > 0:
		for item_id in basket:
			var price: float = ShopManager.get_price(item_id)
			total_served_revenue += price
			if EconomyManager:
				EconomyManager.record_income(price)
				
		# Tampilkan balon uang hijau
		float_label.text = "+$%.2f" % total_served_revenue
		float_label.modulate = Color(0.24, 0.76, 0.45, 1.0) # Hijau
		float_label.show()
		
		# Animasikan balon melayang sedikit ke atas
		var tween: Tween = create_tween()
		tween.tween_property(float_label, "position:y", float_label.position.y - 40, 1.0)
		
		# Pancarkan sinyal keberhasilan di EventBus
		EventBus.customer_served.emit(total_served_revenue)
	else:
		# Kecewa tidak belanja apa-apa karena rak kosong
		satisfaction = "😡"
		face_label.text = satisfaction
		float_label.text = "Kecewa!"
		float_label.modulate = Color(0.85, 0.35, 0.35, 1.0) # Merah
		float_label.show()
		var tween: Tween = create_tween()
		tween.tween_property(float_label, "position:y", float_label.position.y - 40, 1.0)
		
	# Pulang setelah transaksi kasir selesai
	state = "LEAVING"
	action_label.text = "Pulang..."

func _show_temp_feedback(txt: String) -> void:
	if float_label:
		float_label.text = txt
		float_label.position.y = -50
		float_label.show()
		
		# Sembunyikan label umpan balik setelah 0.8 detik
		var t: SceneTreeTimer = get_tree().create_timer(0.8)
		t.timeout.connect(func() -> void:
			if float_label:
				float_label.hide()
		)
