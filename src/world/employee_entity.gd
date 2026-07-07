class_name EmployeeEntity
extends Node2D

## Mengatur visualisasi fisik karyawan, pergerakan navigasi otonom, dan kecerdasan buatan tugas kasir/stocker dengan dukungan modifikator peristiwa harian.

@onready var visual_rect: PanelContainer = %VisualRect
@onready var face_label: Label = %FaceLabel
@onready var action_label: Label = %ActionLabel

var staff_id: String = ""
var staff_name: String = ""
var role: String = "" # Cashier atau Stocker
var speed_mult: float = 1.0
var base_speed: float = 120.0

var state: String = "IDLE" # IDLE, WALKING_TO_WAREHOUSE, RESTOCKING, WALKING_TO_SHELF
var target_rack_idx: int = -1
var target_item_id: String = ""
var restock_delay_timer: float = 0.0

var _world_node: Node2D = null

func _ready() -> void:
	# Hubungkan referensi World
	var scene_root: Node = get_tree().current_scene
	if scene_root:
		_world_node = scene_root.get_node_or_null("World") as Node2D
		
	# Setup visual warna baju dan ikon peran
	_setup_visual()

func _setup_visual() -> void:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.corner_radius_top_left = 24
	style.corner_radius_top_right = 24
	style.corner_radius_bottom_right = 24
	style.corner_radius_bottom_left = 24
	style.border_width_left = 2
	style.border_width_top = 2
	style.border_width_right = 2
	style.border_width_bottom = 2
	style.border_color = Color(0.1, 0.1, 0.1)
	
	if role == "Cashier":
		style.bg_color = Color(0.85, 0.40, 0.60, 1.0) # Pink Kasir
		if face_label:
			face_label.text = "😐"
	elif role == "Stocker":
		style.bg_color = Color(0.20, 0.65, 0.40, 1.0) # Hijau Stocker
		if face_label:
			face_label.text = "🔧"
	else:
		style.bg_color = Color(0.5, 0.5, 0.5, 1.0)
		
	if visual_rect:
		visual_rect.add_theme_stylebox_override("panel", style)
		
	if action_label:
		action_label.text = staff_name + " (Siaga)"

func _get_current_speed() -> float:
	var speed = base_speed * speed_mult
	var event_mgr: Node = get_node_or_null("/root/EventManager")
	if event_mgr and event_mgr.active_event.size() > 0:
		speed *= event_mgr.active_event.get("staff_speed_mult", 1.0)
	return speed

func _process(delta: float) -> void:
	# Jika game di-pause (time_scale == 0), jangan bergerak
	if TimeManager and TimeManager.time_scale == 0.0:
		return
		
	match role:
		"Cashier":
			_process_cashier_ai(delta)
		"Stocker":
			_process_stocker_ai(delta)

func _process_cashier_ai(delta: float) -> void:
	# Kasir selalu berjaga di Meja Kasir
	var cashier_target: Vector2 = Vector2(-220, 0)
	if _world_node:
		var cashier_node: Marker2D = _world_node.get_node_or_null("CashierRegister") as Marker2D
		if cashier_node:
			# Berdiri sedikit di belakang meja kasir
			cashier_target = cashier_node.global_position + Vector2(-20, 0)
			
	if global_position.distance_to(cashier_target) > 5.0:
		var dir: Vector2 = (cashier_target - global_position).normalized()
		global_position += dir * _get_current_speed() * delta
		if action_label:
			action_label.text = staff_name + " (Ke Kasir)"
	else:
		if action_label:
			action_label.text = staff_name + " (Kasir)"

func _process_stocker_ai(delta: float) -> void:
	match state:
		"IDLE":
			# Cari rak yang stoknya di bawah 50% kapasitas dan gudang memiliki stoknya
			var found_rack_idx: int = -1
			var found_item_id: String = ""
			
			if ShopManager and ShopManager.warehouse_inventory:
				for i in range(ShopManager.racks.size()):
					var rack: Dictionary = ShopManager.racks[i]
					var current: int = rack["current_stock"]
					var max_cap: int = rack["max_capacity"]
					var item_id: String = rack["item_id"]
					
					# Pemicu jika stok rak kurang dari setengah
					if current <= max_cap / 2:
						var wh_stock: int = ShopManager.warehouse_inventory.get_stock(item_id)
						if wh_stock > 0:
							found_rack_idx = i
							found_item_id = item_id
							break
							
			if found_rack_idx != -1:
				target_rack_idx = found_rack_idx
				target_item_id = found_item_id
				state = "WALKING_TO_WAREHOUSE"
				if action_label:
					action_label.text = "Ambil " + DatabaseManager.get_item(target_item_id).name.split(" ")[0]
			else:
				# Kembali siaga di tengah toko ritel
				var home_pos: Vector2 = Vector2(-300, 50)
				if global_position.distance_to(home_pos) > 8.0:
					var dir: Vector2 = (home_pos - global_position).normalized()
					global_position += dir * _get_current_speed() * delta
				else:
					if action_label:
						action_label.text = staff_name + " (Siaga)"
						
		"WALKING_TO_WAREHOUSE":
			# Cari posisi koordinat box fisik di gudang
			var target_pos: Vector2 = Vector2(400, 0) # Default posisi tengah gudang
			if _world_node:
				var found_slot_idx: int = -1
				for slot_idx in _world_node.slot_occupants:
					var box = _world_node.slot_occupants[slot_idx]
					if box and box.item_id == target_item_id:
						found_slot_idx = slot_idx
						break
				
				if found_slot_idx != -1:
					var slot_node: Marker2D = _world_node.pallet_slots_parent.get_node("Slot" + str(found_slot_idx)) as Marker2D
					if slot_node:
						target_pos = slot_node.global_position
						
			if global_position.distance_to(target_pos) > 6.0:
				var dir: Vector2 = (target_pos - global_position).normalized()
				global_position += dir * _get_current_speed() * delta
			else:
				state = "RESTOCKING"
				restock_delay_timer = 0.8 # Jeda 0.8 detik mengambil barang
				if action_label:
					action_label.text = "Mengambil..."
					
		"RESTOCKING":
			restock_delay_timer -= delta
			if restock_delay_timer <= 0.0:
				# Jalankan transaksi restock di ShopManager
				var success: bool = ShopManager.restock_rack(target_rack_idx)
				# Lanjut bawa barang ke rak ritel
				state = "WALKING_TO_SHELF"
				if action_label:
					action_label.text = "Menata Rak"
					
		"WALKING_TO_SHELF":
			# Cari koordinat rak ritel di toko
			var target_pos: Vector2 = Vector2(-400, 0)
			if _world_node:
				var rack_slots: Node2D = _world_node.get_node_or_null("RackSlots") as Node2D
				if rack_slots:
					var slot: Marker2D = rack_slots.get_node_or_null("Slot" + str(target_rack_idx)) as Marker2D
					if slot:
						target_pos = slot.global_position
						
			if global_position.distance_to(target_pos) > 6.0:
				var dir: Vector2 = (target_pos - global_position).normalized()
				global_position += dir * _get_current_speed() * delta
			else:
				# Selesai menata barang, kembali patroli
				state = "IDLE"
				if action_label:
					action_label.text = "Selesai!"
