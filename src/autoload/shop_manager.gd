extends Node

## Mengatur inventaris gudang global dan status penjualan rak toko ritel.

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
