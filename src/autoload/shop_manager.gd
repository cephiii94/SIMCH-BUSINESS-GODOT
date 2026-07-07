extends Node

## Mengatur inventaris gudang global dan status penjualan rak toko ritel.

signal racks_changed

const InventoryScript: Script = preload("res://src/core/inventory.gd")

var warehouse_inventory: RefCounted
var prices: Dictionary = {}
var racks: Array[Dictionary] = []

func _ready() -> void:
	# Inisialisasi inventaris gudang global kapasitas 100
	warehouse_inventory = InventoryScript.new(100)
	
	# Tunggu satu frame agar DatabaseManager siap
	await get_tree().process_frame
	
	# Set harga jual default mengikuti harga pasar (reference price)
	if DatabaseManager:
		for item in DatabaseManager.get_all_items():
			var item_ref = item
			prices[item_ref.id] = item_ref.reference_price
			
	# Buat 3 rak default di Toko Ritel
	racks = [
		{
			"rack_id": "rack_01",
			"item_id": "grocery_milk",
			"current_stock": 0,
			"max_capacity": 15
		},
		{
			"rack_id": "rack_02",
			"item_id": "grocery_bread",
			"current_stock": 0,
			"max_capacity": 15
		},
		{
			"rack_id": "rack_03",
			"item_id": "clothing_shirt",
			"current_stock": 0,
			"max_capacity": 10
		}
	]

## Penyetelan harga jual eceran.
func set_price(item_id: String, price: float) -> void:
	prices[item_id] = price

## Mendapatkan harga jual eceran aktif.
func get_price(item_id: String) -> float:
	return prices.get(item_id, 0.0)

## Mendapatkan harga beli grosir aktif dengan modifikator peristiwa harian jika ada.
func get_wholesale_price(item_id: String) -> float:
	if not DatabaseManager:
		return 0.0
		
	var item_data = DatabaseManager.get_item(item_id)
	if not item_data:
		return 0.0
		
	var base_price: float = item_data.wholesale_price
	
	var event_mgr: Node = get_node_or_null("/root/EventManager")
	if event_mgr and event_mgr.active_event.size() > 0:
		var modifier_key: String = item_id + "_wholesale_mult"
		if event_mgr.active_event.has(modifier_key):
			return base_price * event_mgr.active_event[modifier_key]
			
	return base_price

## Membangun rak baru. Biaya awal $250.
func build_rack(item_id: String) -> bool:
	if racks.size() >= 6:
		return false # Maksimal 6 rak
		
	if EconomyManager and EconomyManager.cash >= 250.0:
		EconomyManager.record_expense(250.0, EconomyManager.ExpenseType.INVESTMENT)
		
		# ID rak baru
		var new_id = "rack_0" + str(racks.size() + 1)
		
		# Tentukan kapasitas default berdasarkan item
		var default_cap = 15
		if item_id.begins_with("clothing"):
			default_cap = 10
			
		racks.append({
			"rack_id": new_id,
			"item_id": item_id,
			"current_stock": 0,
			"max_capacity": default_cap
		})
		
		racks_changed.emit()
		return true
		
	return false

## Membongkar/hancurkan rak. Mendapatkan refund $100.
func destroy_rack(rack_idx: int) -> void:
	if rack_idx < 0 or rack_idx >= racks.size():
		return
		
	racks.remove_at(rack_idx)
	
	if EconomyManager:
		EconomyManager.record_income(100.0) # Refund seharga $100
		
	racks_changed.emit()

## Meningkatkan kapasitas rak. Level 1 -> 2 ($150), Level 2 -> 3 ($300).
func upgrade_rack(rack_idx: int) -> bool:
	if rack_idx < 0 or rack_idx >= racks.size():
		return false
		
	var rack = racks[rack_idx]
	var current_capacity = rack["max_capacity"]
	
	# Ambil kapasitas dasar berdasarkan item id
	var base_cap = 15
	if rack["item_id"].begins_with("clothing"):
		base_cap = 10
		
	var cost = 150.0
	if current_capacity >= base_cap * 2:
		cost = 300.0
		
	if current_capacity >= base_cap * 4:
		return false # Sudah kapasitas maksimal (Level 3)
		
	if EconomyManager and EconomyManager.cash >= cost:
		EconomyManager.record_expense(cost, EconomyManager.ExpenseType.INVESTMENT)
		rack["max_capacity"] = current_capacity * 2
		racks_changed.emit()
		return true
		
	return false

## Melakukan pengisian rak (restock) dari gudang ke toko ritel.
func restock_rack(rack_idx: int) -> bool:
	if rack_idx < 0 or rack_idx >= racks.size():
		return false
		
	var rack: Dictionary = racks[rack_idx]
	var space: int = rack["max_capacity"] - rack["current_stock"]
	if space <= 0:
		print("[WARNING-SHOP] Rak sudah penuh!")
		return false
		
	var wh_stock: int = warehouse_inventory.get_stock(rack["item_id"])
	if wh_stock <= 0:
		print("[WARNING-SHOP] Stok barang di gudang kosong!")
		return false
		
	# Jumlah unit yang bisa diambil (maksimal sebesar sisa ruang rak atau stok gudang)
	var draw_amount: int = min(space, wh_stock)
	
	# Kurangi dari gudang
	var success: bool = warehouse_inventory.remove_item(rack["item_id"], draw_amount)
	if success:
		# Tambahkan ke rak
		rack["current_stock"] += draw_amount
		
		# Pemicu visual pengeluaran box dari gudang
		var scene_root: Node = get_tree().current_scene
		if scene_root:
			var world_node: Node2D = scene_root.get_node_or_null("World") as Node2D
			if world_node and world_node.has_method("remove_box"):
				world_node.remove_box(rack["item_id"])
		return true
		
	return false

## Mensimulasikan penjualan eceran 1 unit barang dari rak.
func sell_unit(rack_idx: int) -> bool:
	if rack_idx < 0 or rack_idx >= racks.size():
		return false
		
	var rack: Dictionary = racks[rack_idx]
	if rack["current_stock"] > 0:
		rack["current_stock"] -= 1
		
		# Tambah kas pemain berdasarkan harga jual produk
		var price: float = get_price(rack["item_id"])
		if EconomyManager:
			EconomyManager.record_income(price)
		return true
		
	return false
