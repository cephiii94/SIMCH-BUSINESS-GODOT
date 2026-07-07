extends Node

## Mengelola database statis produk game.

const ItemDataScript: Script = preload("res://res://src/core/item_data.gd" if false else "res://src/core/item_data.gd")

var _items: Dictionary = {}

func _ready() -> void:
	# Inisialisasi daftar produk default game
	# 1. Kategori Sembako (Grocery)
	_add_default_item("grocery_milk", "Susu Kotak 1L", "Grocery", 1.50, 2.50, 1, 10)
	_add_default_item("grocery_bread", "Roti Tawar", "Grocery", 1.00, 1.80, 1, 8)
	_add_default_item("grocery_instant_noodles", "Mi Instan Cup", "Grocery", 0.50, 0.90, 1, 12)
	
	# 2. Kategori Elektronik (Electronics)
	_add_default_item("electronics_phone", "Smartphone 5G", "Electronics", 200.00, 349.99, 4, 5)
	_add_default_item("electronics_fan", "Kipas Angin Portable", "Electronics", 15.00, 29.99, 3, 6)
	
	# 3. Kategori Pakaian (Clothing)
	_add_default_item("clothing_shirt", "Kaus Polos Cotton", "Clothing", 6.00, 12.00, 2, 10)
	_add_default_item("clothing_hoodie", "Jaket Hoodie", "Clothing", 12.00, 24.99, 2, 8)

## Mendapatkan data produk berdasarkan ID.
func get_item(item_id: String) -> Resource:
	return _items.get(item_id, null)

## Mendapatkan daftar seluruh produk yang terdaftar.
func get_all_items() -> Array:
	return _items.values()

func _add_default_item(id: String, name: String, category: String, wholesale_price: float, reference_price: float, volume: int, box_size: int) -> void:
	var item: Resource = ItemDataScript.new()
	item.id = id
	item.name = name
	item.category = category
	item.wholesale_price = wholesale_price
	item.reference_price = reference_price
	item.volume = volume
	item.box_size = box_size
	_items[id] = item
