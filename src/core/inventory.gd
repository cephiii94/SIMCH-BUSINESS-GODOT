class_name Inventory
extends RefCounted

## Komponen logis penyimpanan inventaris barang (Gudang atau Rak Toko).

signal stock_changed(item_id: String, new_count: int)
signal capacity_updated(current_volume: int, max_capacity: int)

var max_capacity: int = 100

# Kamus data stok barang: { "item_id": jumlah_unit (int) }
var items: Dictionary = {}

func _init(p_max_capacity: int) -> void:
	max_capacity = p_max_capacity

## Menghitung total volume terisi saat ini.
func get_current_volume() -> int:
	var total: int = 0
	for item_id in items:
		var count: int = items[item_id]
		var item_data: Resource = DatabaseManager.get_item(item_id)
		if item_data:
			total += count * item_data.volume
	return total

## Menambah item ke inventaris. Mengembalikan true jika berhasil.
func add_item(item_id: String, count: int) -> bool:
	var item_data: Resource = DatabaseManager.get_item(item_id)
	if not item_data:
		return false
		
	var needed_volume: int = count * item_data.volume
	if get_current_volume() + needed_volume > max_capacity:
		return false # Kapasitas penuh
		
	if items.has(item_id):
		items[item_id] += count
	else:
		items[item_id] = count
		
	stock_changed.emit(item_id, items[item_id])
	capacity_updated.emit(get_current_volume(), max_capacity)
	return true

## Mengurangi item dari inventaris. Mengembalikan true jika berhasil.
func remove_item(item_id: String, count: int) -> bool:
	if not items.has(item_id) or items[item_id] < count:
		return false
		
	items[item_id] -= count
	if items[item_id] == 0:
		items.erase(item_id)
		
	var new_count: int = items.get(item_id, 0)
	stock_changed.emit(item_id, new_count)
	capacity_updated.emit(get_current_volume(), max_capacity)
	return true

## Mendapatkan jumlah stok unit item saat ini.
func get_stock(item_id: String) -> int:
	return items.get(item_id, 0)
