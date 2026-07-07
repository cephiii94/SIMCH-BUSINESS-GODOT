class_name GameWorld
extends Node2D

## Mengatur visualisasi gameplay 2D dunia game, transisi siang-malam, dan manajemen box fisik, pelanggan, serta karyawan.

const BOX_ENTITY_SCENE: PackedScene = preload("res://src/world/box_entity.tscn")
const CUSTOMER_SCENE: PackedScene = preload("res://src/world/customer.tscn")
const EMPLOYEE_ENTITY_SCENE: PackedScene = preload("res://src/world/employee_entity.tscn")

@onready var spawn_point: Marker2D = $SpawnPoint
@onready var camera: Camera2D = $Camera2D
@onready var canvas_modulate: CanvasModulate = %CanvasModulate
@onready var loading_dock: Marker2D = %LoadingDock
@onready var pallet_slots_parent: Node2D = %PalletSlots
@onready var customer_spawn_point: Marker2D = %CustomerSpawnPoint
@onready var entities: Node2D = $Entities

# Kamus pelacak slot palet terisi: { slot_index (int): BoxEntity }
var slot_occupants: Dictionary = {}

# Kamus pelacak karyawan fisik terisi: { staff_id (String): EmployeeEntity }
var employee_nodes: Dictionary = {}

# Timer pemijahan pelanggan
var customer_spawn_timer: float = 2.0 # Muncul cepat saat awal bermain

func _ready() -> void:
	if spawn_point and camera:
		camera.global_position = spawn_point.global_position
		
	# Hubungkan sinyal waktu dari EventBus
	EventBus.time_tick.connect(_on_time_tick)
	
	# Set warna inisial berdasarkan waktu saat ini
	if TimeManager:
		_on_time_tick(TimeManager.day, TimeManager.hour, TimeManager.minute)

	# Hubungkan sinyal perubahan staf
	var staff_mgr: Node = get_node_or_null("/root/StaffManager")
	if staff_mgr:
		staff_mgr.staff_list_changed.connect(sync_employees)
		sync_employees()

func _process(delta: float) -> void:
	# Jalankan pemijahan pelanggan berkala jika game sedang berjalan (tidak pause)
	if TimeManager and TimeManager.time_scale > 0.0:
		# Toko Ritel buka dari jam 08:00 pagi hingga 20:00 malam
		if TimeManager.hour >= 8 and TimeManager.hour < 20:
			customer_spawn_timer -= delta
			if customer_spawn_timer <= 0.0:
				# Tentukan interval spawn berdasarkan rating reputasi aktif
				var current_rating: float = 4.0
				var rep_mgr: Node = get_node_or_null("/root/ReputationManager")
				if rep_mgr:
					current_rating = rep_mgr.rating
					
				if current_rating >= 4.0:
					customer_spawn_timer = randf_range(6.0, 10.0) # Toko ramai
				elif current_rating >= 2.5:
					customer_spawn_timer = randf_range(10.0, 15.0) # Toko sedang
				else:
					customer_spawn_timer = randf_range(16.0, 22.0) # Toko sepi
					
				spawn_customer()

## Men-spawn pelanggan baru di jalan kiri luar toko.
func spawn_customer() -> void:
	if not CUSTOMER_SCENE:
		return
		
	var customer: Node2D = CUSTOMER_SCENE.instantiate() as Node2D
	if entities:
		entities.add_child(customer)
	else:
		add_child(customer)
		
	if customer_spawn_point:
		customer.global_position = customer_spawn_point.global_position
	else:
		customer.global_position = Vector2(-850, 200)
		
	print("[INFO] Pelanggan baru memasuki toko.")

## Mensinkronisasikan entitas karyawan fisik dengan data StaffManager secara reaktif.
func sync_employees() -> void:
	var staff_mgr: Node = get_node_or_null("/root/StaffManager")
	if not staff_mgr or not EMPLOYEE_ENTITY_SCENE:
		return
		
	# 1. Hapus entitas fisik yang sudah tidak ada di data hired_staff
	var active_ids: Array = []
	for staff in staff_mgr.hired_staff:
		active_ids.append(staff["id"])
		
	var current_node_ids: Array = employee_nodes.keys()
	for staff_id in current_node_ids:
		if not staff_id in active_ids:
			var node: Node2D = employee_nodes[staff_id]
			if is_instance_valid(node):
				node.queue_free()
			employee_nodes.erase(staff_id)
			
	# 2. Spawn entitas fisik baru yang terdaftar di hired_staff tapi belum ada nodenya
	for staff in staff_mgr.hired_staff:
		var staff_id: String = staff["id"]
		if not employee_nodes.has(staff_id):
			var emp: Node2D = EMPLOYEE_ENTITY_SCENE.instantiate() as Node2D
			emp.staff_id = staff_id
			emp.staff_name = staff["name"]
			emp.role = staff["role"]
			emp.speed_mult = staff["speed"]
			
			# Penempatan posisi spawn awal
			if staff["role"] == "Cashier":
				emp.global_position = Vector2(-220, 0)
			else:
				emp.global_position = Vector2(-300, 50)
				
			if entities:
				entities.add_child(emp)
			else:
				add_child(emp)
				
			employee_nodes[staff_id] = emp

## Men-spawn box barang fisik di Loading Dock dan meluncurkannya ke slot palet yang kosong.
func spawn_box(item_id: String) -> void:
	# Cari slot palet yang kosong
	var target_slot_idx: int = -1
	for i in range(16):
		if not slot_occupants.has(i):
			target_slot_idx = i
			break
			
	if target_slot_idx == -1:
		print("[WARNING-WORLD] Tidak ada slot palet kosong di gudang!")
		return
		
	# Dapatkan Marker2D slot tujuan
	var slot_node: Marker2D = pallet_slots_parent.get_node("Slot" + str(target_slot_idx)) as Marker2D
	if not slot_node:
		return
		
	# Buat instansi BoxEntity baru di area Loading Dock
	var box = BOX_ENTITY_SCENE.instantiate()
	add_child(box)
	
	if loading_dock:
		box.global_position = loading_dock.global_position
	else:
		box.global_position = Vector2(800, 0)
		
	# Setup visual dan target pergeseran
	box.setup(item_id, slot_node.global_position)
	
	# Daftarkan penanggung slot
	slot_occupants[target_slot_idx] = box

## Mengeluarkan box barang fisik dari slot palet dan mengarahkannya meluncur keluar gudang.
func remove_box(item_id: String) -> void:
	# Cari slot terisi yang memuat item_id tersebut
	var found_slot_idx: int = -1
	var found_box = null
	
	for slot_idx in slot_occupants:
		var box = slot_occupants[slot_idx]
		if box and box.item_id == item_id:
			found_slot_idx = slot_idx
			found_box = box
			break
			
	if found_box:
		# Hapus dari daftar penanggung slot
		slot_occupants.erase(found_slot_idx)
		
		# Luncurkan box ke koridor penghubung tengah (keluar dari gudang menuju toko)
		var exit_pos: Vector2 = Vector2(-200, 0)
		found_box.dispatch(exit_pos)
	else:
		print("[WARNING-WORLD] Box barang untuk item '", item_id, "' tidak ditemukan di gudang!")

## Memuat dan menempatkan ulang box barang fisik di slot palet secara instan (untuk load game).
func load_warehouse_boxes() -> void:
	# Bersihkan box lama
	for slot_idx in slot_occupants:
		var box = slot_occupants[slot_idx]
		if is_instance_valid(box):
			box.queue_free()
	slot_occupants.clear()
	
	if not ShopManager or not ShopManager.warehouse_inventory:
		return
		
	var idx: int = 0
	for item_id in ShopManager.warehouse_inventory.items:
		var count: int = ShopManager.warehouse_inventory.items[item_id]
		if count > 0 and idx < 16:
			var slot_node: Marker2D = pallet_slots_parent.get_node_or_null("Slot" + str(idx)) as Marker2D
			if slot_node:
				var box = BOX_ENTITY_SCENE.instantiate()
				add_child(box)
				box.global_position = slot_node.global_position
				box.setup(item_id, slot_node.global_position)
				slot_occupants[idx] = box
				idx += 1

func _on_time_tick(_day: int, hour: int, minute: int) -> void:
	if canvas_modulate:
		canvas_modulate.color = _get_day_color(hour, minute)

func _get_day_color(h: int, m: int) -> Color:
	var time_val: float = h + m / 60.0
	
	# Batas warna (Warna modern)
	var day_color: Color = Color(1.0, 1.0, 1.0, 1.0)
	var sunset_color: Color = Color(0.85, 0.62, 0.48, 1.0)
	var night_color: Color = Color(0.38, 0.38, 0.58, 1.0)
	
	if time_val >= 6.0 and time_val < 8.0:
		var t: float = (time_val - 6.0) / 2.0
		return night_color.lerp(day_color, t)
	elif time_val >= 8.0 and time_val < 17.0:
		return day_color
	elif time_val >= 17.0 and time_val < 19.0:
		var t: float = (time_val - 17.0) / 2.0
		return day_color.lerp(sunset_color, t)
	elif time_val >= 19.0 and time_val < 20.5:
		var t: float = (time_val - 19.0) / 1.5
		return sunset_color.lerp(night_color, t)
	else:
		return night_color
