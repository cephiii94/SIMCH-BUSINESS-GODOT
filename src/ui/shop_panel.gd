class_name ShopPanel
extends Control

## Mengatur UI panel Manajemen Toko Ritel (Shop Panel).

signal close_pressed

@onready var racks_container: VBoxContainer = %RacksContainer
@onready var close_button: Button = %CloseButton

func _ready() -> void:
	close_button.pressed.connect(func() -> void: close_pressed.emit())
	
	# Render daftar rak
	_populate_racks_list()

func _populate_racks_list() -> void:
	# Bersihkan daftar UI lama
	for child in racks_container.get_children():
		child.queue_free()
		
	if not ShopManager or not DatabaseManager:
		return
		
	for i in range(ShopManager.racks.size()):
		var rack_idx: int = i
		var rack: Dictionary = ShopManager.racks[rack_idx]
		var item_ref = DatabaseManager.get_item(rack["item_id"])
		if not item_ref:
			continue
			
		var cost: float = item_ref.wholesale_price
		
		# VBox untuk satu baris Rak
		var rack_box: VBoxContainer = VBoxContainer.new()
		rack_box.add_theme_constant_override("separation", 8)
		
		# HBox Baris 1: Nama Produk, Kapasitas Bar, dan Jumlah Stok
		var header_hbox: HBoxContainer = HBoxContainer.new()
		header_hbox.add_theme_constant_override("separation", 12)
		
		var lbl_name: Label = Label.new()
		lbl_name.text = item_ref.name
		lbl_name.size_flags_horizontal = SIZE_EXPAND_FILL
		lbl_name.add_theme_font_size_override("font_size", 16)
		
		var lbl_stock: Label = Label.new()
		lbl_stock.text = "Rak: %d/%d u" % [rack["current_stock"], rack["max_capacity"]]
		lbl_stock.custom_minimum_size = Vector2(90, 0)
		
		var stock_bar: ProgressBar = ProgressBar.new()
		stock_bar.max_value = rack["max_capacity"]
		stock_bar.value = rack["current_stock"]
		stock_bar.show_percentage = false
		stock_bar.custom_minimum_size = Vector2(120, 16)
		stock_bar.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		
		header_hbox.add_child(lbl_name)
		header_hbox.add_child(lbl_stock)
		header_hbox.add_child(stock_bar)
		rack_box.add_child(header_hbox)
		
		# HBox Baris 2: Harga Jual Slider & Info Margin Keuntungan
		var price_hbox: HBoxContainer = HBoxContainer.new()
		price_hbox.add_theme_constant_override("separation", 16)
		
		var current_price: float = ShopManager.get_price(item_ref.id)
		
		var lbl_price_info: Label = Label.new()
		lbl_price_info.custom_minimum_size = Vector2(240, 0)
		lbl_price_info.add_theme_font_size_override("font_size", 13)
		
		# HSlider untuk mengatur harga jual eceran
		var price_slider: HSlider = HSlider.new()
		price_slider.min_value = cost # Batas bawah adalah harga beli grosir
		price_slider.max_value = cost * 2.5 # Batas atas 2.5x harga grosir
		price_slider.step = 0.05
		price_slider.value = current_price
		price_slider.size_flags_horizontal = SIZE_EXPAND_FILL
		price_slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
		
		# Fungsi lokal untuk memperbarui info label harga dan profit secara real-time
		var update_price_label = func(val: float) -> void:
			var profit: float = val - cost
			var margin_pct: float = (profit / cost) * 100.0 if cost > 0 else 0.0
			lbl_price_info.text = "Harga: $%.2f | Grosir: $%.2f | Untung: +$%.2f (%.0f%%)" % [val, cost, profit, margin_pct]
			if profit > 0:
				lbl_price_info.modulate = Color(0.239216, 0.760784, 0.447059, 1.0) # Hijau
			else:
				lbl_price_info.modulate = Color(1.0, 1.0, 1.0, 1.0)
				
		update_price_label.call(current_price)
		
		price_slider.value_changed.connect(func(new_val: float) -> void:
			ShopManager.set_price(item_ref.id, new_val)
			update_price_label.call(new_val)
		)
		
		price_hbox.add_child(lbl_price_info)
		price_hbox.add_child(price_slider)
		rack_box.add_child(price_hbox)
		
		# HBox Baris 3: Tombol Aksi Restock dan Jual
		var actions_hbox: HBoxContainer = HBoxContainer.new()
		actions_hbox.add_theme_constant_override("separation", 8)
		actions_hbox.alignment = BoxContainer.ALIGNMENT_END
		
		var btn_restock: Button = Button.new()
		btn_restock.text = "Restock (Gudang)"
		btn_restock.custom_minimum_size = Vector2(140, 32)
		btn_restock.pressed.connect(func() -> void:
			var success: bool = ShopManager.restock_rack(rack_idx)
			if success:
				lbl_stock.text = "Rak: %d/%d u" % [rack["current_stock"], rack["max_capacity"]]
				stock_bar.value = rack["current_stock"]
		)
		
		var btn_sell: Button = Button.new()
		btn_sell.text = "Jual 1 Unit"
		btn_sell.custom_minimum_size = Vector2(100, 32)
		btn_sell.pressed.connect(func() -> void:
			var success: bool = ShopManager.sell_unit(rack_idx)
			if success:
				lbl_stock.text = "Rak: %d/%d u" % [rack["current_stock"], rack["max_capacity"]]
				stock_bar.value = rack["current_stock"]
		)
		
		actions_hbox.add_child(btn_restock)
		actions_hbox.add_child(btn_sell)
		rack_box.add_child(actions_hbox)
		
		# Divider pembatas antar rak
		if rack_idx < ShopManager.racks.size() - 1:
			var separator: HSeparator = HSeparator.new()
			rack_box.add_child(separator)
			
		racks_container.add_child(rack_box)
