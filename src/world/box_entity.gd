class_name BoxEntity
extends Node2D

## Mengatur visualisasi fisik kardus barang di gudang beserta gerakan meluncurnya.

@onready var panel: PanelContainer = %Panel
@onready var label: Label = %ProductLabel

var item_id: String = ""
var target_position: Vector2 = Vector2.ZERO
var speed: float = 6.0
var is_dispatched: bool = false

var _has_landed: bool = false

func _ready() -> void:
	# Coba setup visual jika data sudah terisi saat diinstansiasi
	if item_id != "":
		setup_visual()

func _process(delta: float) -> void:
	# Meluncur secara halus ke posisi target
	global_position = global_position.lerp(target_position, speed * delta)
	
	# Deteksi mendarat pertama kali di slot target
	if not is_dispatched and not _has_landed and global_position.distance_squared_to(target_position) < 25.0:
		_has_landed = true
		_play_land_animation()
	
	# Jika box sedang dikeluarkan (dispatch) dan sudah mendekati target keluar, hancurkan objek
	if is_dispatched and global_position.distance_squared_to(target_position) < 25.0:
		queue_free()


func _play_land_animation() -> void:
	# Animasikan membal squash & stretch dari pusat origin
	var tween = create_tween().set_parallel(false)
	# Squash (menipis mendatar)
	tween.tween_property(self, "scale", Vector2(1.2, 0.8), 0.12).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	# Stretch (memanjang meninggi)
	tween.tween_property(self, "scale", Vector2(0.9, 1.15), 0.10).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	# Kembali normal
	tween.tween_property(self, "scale", Vector2.ONE, 0.08).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


## Melakukan konfigurasi nama produk, posisi target, dan visual warna kardus.
func setup(p_item_id: String, p_target_pos: Vector2) -> void:
	item_id = p_item_id
	target_position = p_target_pos
	
	if is_inside_tree():
		setup_visual()

func setup_visual() -> void:
	if not DatabaseManager:
		return
		
	var item_data = DatabaseManager.get_item(item_id)
	if not item_data:
		return
		
	# Ambil kata pertama saja agar muat di box kecil
	var name_parts: PackedStringArray = item_data.name.split(" ")
	if label:
		label.text = name_parts[0]
		
	# Atur warna latar belakang kardus berdasarkan kategorinya
	var bg_style: StyleBoxFlat = StyleBoxFlat.new()
	bg_style.corner_radius_top_left = 6
	bg_style.corner_radius_top_right = 6
	bg_style.corner_radius_bottom_right = 6
	bg_style.corner_radius_bottom_left = 6
	bg_style.border_width_left = 2
	bg_style.border_width_top = 2
	bg_style.border_width_right = 2
	bg_style.border_width_bottom = 2
	bg_style.border_color = Color(0.1, 0.1, 0.1, 0.8)
	
	match item_data.category:
		"Grocery":
			bg_style.bg_color = Color(0.55, 0.42, 0.31, 1.0) # Coklat kardus
		"Electronics":
			bg_style.bg_color = Color(0.18, 0.38, 0.58, 1.0) # Biru kelam
		"Clothing":
			bg_style.bg_color = Color(0.68, 0.38, 0.18, 1.0) # Jingga bata
		_:
			bg_style.bg_color = Color(0.35, 0.35, 0.35, 1.0)
			
	if panel:
		panel.add_theme_stylebox_override("panel", bg_style)

## Memerintahkan box untuk meluncur keluar gudang dan menghancurkan diri.
func dispatch(exit_pos: Vector2) -> void:
	target_position = exit_pos
	is_dispatched = true
	speed = 8.0 # Lebih cepat saat keluar
