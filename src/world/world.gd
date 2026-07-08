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
	EventBus.day_started.connect(sync_employees)
	
	# Set warna inisial berdasarkan waktu saat ini
	if TimeManager:
		_on_time_tick(TimeManager.day, TimeManager.hour, TimeManager.minute)

	# Hubungkan sinyal perubahan staf
	var staff_mgr: Node = get_node_or_null("/root/StaffManager")
	if staff_mgr:
		staff_mgr.staff_list_changed.connect(sync_employees)
		sync_employees()
		
	# Hubungkan sinyal perubahan rak toko ritel
	var shop_mgr: Node = get_node_or_null("/root/ShopManager")
	if shop_mgr:
		shop_mgr.racks_changed.connect(sync_racks)
		sync_racks()

func _process(delta: float) -> void:
	# Jalankan pemijahan pelanggan berkala jika game sedang berjalan (tidak pause)
	if TimeManager and TimeManager.time_scale > 0.0:
		# Toko Ritel buka sesuai status TimeManager.is_shop_open
		if TimeManager.is_shop_open:
			customer_spawn_timer -= delta
			if customer_spawn_timer <= 0.0:
				# Tentukan interval spawn berdasarkan rating reputasi aktif
				var current_rating: float = 4.0
				var rep_mgr: Node = get_node_or_null("/root/ReputationManager")
				if rep_mgr:
					current_rating = rep_mgr.rating
					
				var base_spawn_interval: float = 12.0
				if current_rating >= 4.0:
					base_spawn_interval = randf_range(6.0, 10.0) # Toko ramai
				elif current_rating >= 2.5:
					base_spawn_interval = randf_range(10.0, 15.0) # Toko sedang
				else:
					base_spawn_interval = randf_range(16.0, 22.0) # Toko sepi
					
				# Modifikator peristiwa acak (Random Event)
				var event_mgr: Node = get_node_or_null("/root/EventManager")
				if event_mgr and event_mgr.active_event.size() > 0:
					base_spawn_interval *= event_mgr.active_event.get("customer_spawn_mult", 1.0)
					
				customer_spawn_timer = base_spawn_interval
				spawn_customer()
				
		# Cek End of Shift (EOS)
		if TimeManager.hour >= 21 or not TimeManager.is_shop_open:
			var customer_count: int = 0
			if entities:
				for child in entities.get_children():
					if child is Node2D and child.has_method("_shop_current_item"):
						customer_count += 1
						
			if customer_count == 0 and not TimeManager.is_day_ending:
				_end_of_shift()

func _end_of_shift() -> void:
	# 1. Hentikan waktu permainan
	TimeManager.time_scale = 0.0
	TimeManager.is_day_ending = true
	
	# 2. Pulangkan karyawan secara visual
	_clear_all_employees()
	
	# 3. Pemicu akuntansi akhir hari & pemulihan energi staf di EconomyManager
	var eco_mgr: Node = get_node_or_null("/root/EconomyManager")
	if eco_mgr:
		eco_mgr.trigger_day_end_accounting()
		
	# 4. Pancarkan sinyal EOS
	EventBus.end_of_shift.emit()

func _clear_all_employees() -> void:
	for staff_id in employee_nodes:
		var node = employee_nodes[staff_id]
		if is_instance_valid(node):
			node.queue_free()
	employee_nodes.clear()


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

## Men-spawn box barang fisik di Loading Dock dan meluncurkannya ke slot palet dengan tumpukan maksimal 5 box.
func spawn_box(item_id: String) -> void:
	# Cari slot palet yang sudah berisi item yang sama dan tumpukannya < 5
	var target_slot_idx: int = -1
	for i in range(16):
		if slot_occupants.has(i) and slot_occupants[i] is Array and slot_occupants[i].size() > 0:
			var first_box = slot_occupants[i][0]
			if first_box and first_box.item_id == item_id and slot_occupants[i].size() < 5:
				target_slot_idx = i
				break
				
	# Jika tidak ditemukan slot yang sejenis, cari slot kosong sama sekali
	if target_slot_idx == -1:
		for i in range(16):
			if not slot_occupants.has(i) or not slot_occupants[i] is Array or slot_occupants[i].size() == 0:
				target_slot_idx = i
				break
				
	if target_slot_idx == -1:
		print("[WARNING-WORLD] Tidak ada slot palet kosong atau tumpukan yang tersedia di gudang!")
		return
		
	# Dapatkan Marker2D slot tujuan
	var slot_node: Marker2D = pallet_slots_parent.get_node("Slot" + str(target_slot_idx)) as Marker2D
	if not slot_node:
		return
		
	# Inisialisasi array jika slot baru terpakai
	if not slot_occupants.has(target_slot_idx) or not slot_occupants[target_slot_idx] is Array:
		slot_occupants[target_slot_idx] = []
		
	var current_stack_height: int = slot_occupants[target_slot_idx].size()
	# Hitung posisi target dengan menggeser koordinat Y ke atas 12 piksel per tumpukan
	var target_pos: Vector2 = slot_node.global_position + Vector2(0, -12 * current_stack_height)
	
	# Buat instansi BoxEntity baru di area Loading Dock
	var box = BOX_ENTITY_SCENE.instantiate()
	add_child(box)
	
	if loading_dock:
		box.global_position = loading_dock.global_position
	else:
		box.global_position = Vector2(800, 0)
		
	# Setup visual dan target pergeseran
	box.setup(item_id, target_pos)
	
	# Daftarkan ke array penanggung slot
	slot_occupants[target_slot_idx].append(box)

## Mengeluarkan box barang fisik paling atas dari tumpukan slot palet dan mengarahkannya meluncur keluar gudang.
func remove_box(item_id: String) -> void:
	# Cari slot terisi yang memuat item_id tersebut
	var found_slot_idx: int = -1
	var found_box = null
	
	for slot_idx in slot_occupants:
		var stack = slot_occupants[slot_idx]
		if stack is Array and stack.size() > 0:
			var base_box = stack[0]
			if base_box and base_box.item_id == item_id:
				found_slot_idx = slot_idx
				found_box = stack[stack.size() - 1] # Ambil box paling atas dari tumpukan
				break
				
	if found_box:
		# Hapus dari array tumpukan
		slot_occupants[found_slot_idx].erase(found_box)
		if slot_occupants[found_slot_idx].size() == 0:
			slot_occupants.erase(found_slot_idx)
			
		# Luncurkan box ke koridor penghubung tengah (keluar dari gudang menuju toko)
		var exit_pos: Vector2 = Vector2(-200, 0)
		found_box.dispatch(exit_pos)
	else:
		print("[WARNING-WORLD] Box barang untuk item '", item_id, "' tidak ditemukan di gudang!")

## Memuat dan menempatkan ulang box barang fisik di slot palet secara instan dengan tumpukan vertikal (untuk load game).
func load_warehouse_boxes() -> void:
	# Bersihkan box lama
	for slot_idx in slot_occupants:
		var stack = slot_occupants[slot_idx]
		if stack is Array:
			for box in stack:
				if is_instance_valid(box):
					box.queue_free()
	slot_occupants.clear()
	
	if not ShopManager or not ShopManager.warehouse_inventory or not DatabaseManager:
		return
		
	# Loop untuk memulihkan visual tumpukan kardus secara presisi
	for item_id in ShopManager.warehouse_inventory.items:
		var count: int = ShopManager.warehouse_inventory.items[item_id]
		var item_ref = DatabaseManager.get_item(item_id)
		if item_ref and count > 0:
			# Hitung jumlah box utuh
			var box_count: int = int(ceil(float(count) / float(item_ref.box_size)))
			for b in range(box_count):
				# Cari slot yang cocok (item_id sama dan tinggi < 5) atau slot kosong
				var target_slot_idx: int = -1
				for i in range(16):
					if slot_occupants.has(i) and slot_occupants[i] is Array and slot_occupants[i].size() > 0:
						if slot_occupants[i][0].item_id == item_id and slot_occupants[i].size() < 5:
							target_slot_idx = i
							break
				if target_slot_idx == -1:
					for i in range(16):
						if not slot_occupants.has(i) or not slot_occupants[i] is Array or slot_occupants[i].size() == 0:
							target_slot_idx = i
							break
							
				if target_slot_idx != -1:
					if not slot_occupants.has(target_slot_idx) or not slot_occupants[target_slot_idx] is Array:
						slot_occupants[target_slot_idx] = []
						
					var slot_node: Marker2D = pallet_slots_parent.get_node_or_null("Slot" + str(target_slot_idx)) as Marker2D
					if slot_node:
						var current_height: int = slot_occupants[target_slot_idx].size()
						var target_pos: Vector2 = slot_node.global_position + Vector2(0, -12 * current_height)
						
						var box = BOX_ENTITY_SCENE.instantiate()
						add_child(box)
						box.global_position = target_pos # Instan pos di slot
						box.setup(item_id, target_pos)
						
						slot_occupants[target_slot_idx].append(box)




## Mensinkronisasikan penanda koordinat rak ritel otonom untuk navigasi AI.
func sync_racks() -> void:
	var rack_slots: Node2D = get_node_or_null("RackSlots") as Node2D
	if not rack_slots or not ShopManager:
		return
		
	# Bersihkan penanda lama
	for child in rack_slots.get_children():
		child.queue_free()
		
	# Buat ulang penanda otonom Marker2D sesuai koordinat dinamis dari GameMap
	for i in range(ShopManager.racks.size()):
		var marker: Marker2D = Marker2D.new()
		marker.name = "Slot" + str(i)
		marker.global_position = GameMap.get_rack_position(i)
		rack_slots.add_child(marker)

func _on_time_tick(_day: int, hour: int, minute: int) -> void:
	if canvas_modulate:
		canvas_modulate.color = _get_day_color(hour, minute)
		
	# Cek pemicuan koran pagi pukul 08:00
	if hour == 8 and minute == 0:
		var event_mgr: Node = get_node_or_null("/root/EventManager")
		if event_mgr and event_mgr.active_event.size() > 0 and not event_mgr.event_shown_today:
			event_mgr.event_shown_today = true
			var scene_root: Node = get_tree().current_scene
			if scene_root and scene_root.has_method("_show_daily_event_popup"):
				scene_root._show_daily_event_popup(event_mgr.active_event)

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
