class_name WarehousePanel
extends Control

## Mengatur UI panel Manajemen Gudang (Warehouse/Inventory Panel).

signal close_pressed

const InventoryScript: Script = preload("res://src/core/inventory.gd")
const ItemDataScript: Script = preload("res://src/core/item_data.gd")

@onready var capacity_bar: ProgressBar = %CapacityBar
@onready var capacity_label: Label = %CapacityLabel
@onready var upgrade_button: Button = %UpgradeButton
@onready var items_container: VBoxContainer = %ItemsContainer
@onready var close_button: Button = %CloseButton

var inventory: RefCounted
var _world: Node2D = null

func _ready() -> void:
	# Gunakan inventaris gudang global dari ShopManager
	if ShopManager:
		inventory = ShopManager.warehouse_inventory
	else:
		inventory = InventoryScript.new(100)
	
	# Hubungkan sinyal kapasitas inventaris
	inventory.capacity_updated.connect(_on_capacity_updated)
	
	# Hubungkan tombol-tombol
	upgrade_button.pressed.connect(_on_upgrade_pressed)
	close_button.pressed.connect(func() -> void: close_pressed.emit())
	
	# Render daftar item
	_populate_items_list()
	
	# Update visual awal
	_on_capacity_updated(inventory.get_current_volume(), inventory.max_capacity)

func _on_capacity_updated(current: int, max_cap: int) -> void:
	capacity_bar.max_value = max_cap
	capacity_bar.value = current
	capacity_label.text = "Kapasitas: %d / %d" % [current, max_cap]

func _on_upgrade_pressed() -> void:
	# Biaya upgrade: $500.00
	const UPGRADE_COST: float = 500.00
	
	if EconomyManager and EconomyManager.cash >= UPGRADE_COST:
		EconomyManager.record_expense(UPGRADE_COST, EconomyManager.ExpenseType.INVESTMENT)
		inventory.max_capacity += 50
		_on_capacity_updated(inventory.get_current_volume(), inventory.max_capacity)
		print("[INFO] Kapasitas gudang diupgrade menjadi: ", inventory.max_capacity)
	else:
		print("[WARNING] Uang tidak cukup untuk upgrade kapasitas gudang!")

func _get_world() -> Node2D:
	if _world == null:
		var scene_root: Node = get_tree().current_scene
		if scene_root:
			_world = scene_root.get_node_or_null("World") as Node2D
	return _world

func _populate_items_list() -> void:
	# Bersihkan daftar UI lama
	for child in items_container.get_children():
		child.queue_free()
		
	if not DatabaseManager:
		return
		
	var all_items: Array = DatabaseManager.get_all_items()
	for item in all_items:
		var item_ref: Resource = item as Resource
		
		var hbox: HBoxContainer = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 12)
		
		# Kolom Nama
		var lbl_name: Label = Label.new()
		lbl_name.text = item_ref.name
		lbl_name.size_flags_horizontal = SIZE_EXPAND_FILL
		
		# Kolom Info Volume dan Ukuran Box
		var lbl_info: Label = Label.new()
		lbl_info.text = "Vol: %d | 1 Box: %d u" % [item_ref.volume, item_ref.box_size]
		lbl_info.custom_minimum_size = Vector2(150, 0)
		lbl_info.modulate = Color(0.5, 0.55, 0.6, 1.0)
		
		# Kolom Jumlah Stok
		var lbl_stock: Label = Label.new()
		lbl_stock.text = "Stok: %d u" % inventory.get_stock(item_ref.id)
		lbl_stock.custom_minimum_size = Vector2(80, 0)
		
		# Koneksi perubahan stok secara reaktif
		inventory.stock_changed.connect(func(id: String, new_count: int) -> void:
			if id == item_ref.id:
				lbl_stock.text = "Stok: %d u" % new_count
		)
		
		# Tombol Kurang Stok
		var btn_sub: Button = Button.new()
		btn_sub.text = "-1 Box"
		btn_sub.custom_minimum_size = Vector2(80, 32)
		btn_sub.pressed.connect(func() -> void:
			var success: bool = inventory.remove_item(item_ref.id, item_ref.box_size)
			if success:
				var world_node = _get_world()
				if world_node and world_node.has_method("remove_box"):
					world_node.remove_box(item_ref.id)
		)
		
		# Tombol Tambah Stok
		var btn_add: Button = Button.new()
		btn_add.text = "+1 Box"
		btn_add.custom_minimum_size = Vector2(80, 32)
		btn_add.pressed.connect(func() -> void:
			var success: bool = inventory.add_item(item_ref.id, item_ref.box_size)
			if success:
				var world_node = _get_world()
				if world_node and world_node.has_method("spawn_box"):
					world_node.spawn_box(item_ref.id)
			else:
				print("[WARNING] Gudang penuh! Gagal menambahkan ", item_ref.name)
		)
		
		hbox.add_child(lbl_name)
		hbox.add_child(lbl_info)
		hbox.add_child(lbl_stock)
		hbox.add_child(btn_sub)
		hbox.add_child(btn_add)
		
		items_container.add_child(hbox)
