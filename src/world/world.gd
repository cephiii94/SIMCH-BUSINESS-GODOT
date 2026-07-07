class_name GameWorld
extends Node2D

## Mengatur visualisasi gameplay 2D dunia game, transisi siang-malam, dan manajemen box fisik.

const BOX_ENTITY_SCENE: PackedScene = preload("res://src/world/box_entity.tscn")

@onready var spawn_point: Marker2D = $SpawnPoint
@onready var camera: Camera2D = $Camera2D
@onready var canvas_modulate: CanvasModulate = %CanvasModulate
@onready var loading_dock: Marker2D = %LoadingDock
@onready var pallet_slots_parent: Node2D = %PalletSlots

# Kamus pelacak slot palet terisi: { slot_index (int): BoxEntity }
var slot_occupants: Dictionary = {}

func _ready() -> void:
	if spawn_point and camera:
		camera.global_position = spawn_point.global_position
		
	# Hubungkan sinyal waktu dari EventBus
	EventBus.time_tick.connect(_on_time_tick)
	
	# Set warna inisial berdasarkan waktu saat ini
	if TimeManager:
		_on_time_tick(TimeManager.day, TimeManager.hour, TimeManager.minute)

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
	var box: BoxEntity = BOX_ENTITY_SCENE.instantiate() as BoxEntity
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
	var found_box: BoxEntity = null
	
	for slot_idx in slot_occupants:
		var box: BoxEntity = slot_occupants[slot_idx]
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
