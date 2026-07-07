class_name ShopPanel
extends Control

## Mengatur UI panel Manajemen Toko Ritel (Shop Panel) dengan dukungan Upgrade, Destroy, dan Build.

signal close_pressed

@onready var racks_container: VBoxContainer = %RacksContainer
@onready var close_button: Button = %CloseButton

func _ready() -> void:
	close_button.pressed.connect(func() -> void: close_pressed.emit())
	
	# Hubungkan reaktif jika rak berubah
	var shop_mgr: Node = get_node_or_null("/root/ShopManager")
	if shop_mgr:
		shop_mgr.racks_changed.connect(_populate_racks_list)
		
	# Render daftar rak
	_populate_racks_list()

func _populate_racks_list() -> void:
	# Bersihkan daftar UI lama
	for child in racks_container.get_children():
		child.queue_free()
		
	if not ShopManager or not DatabaseManager:
		return
		
	# 1. Render seluruh rak aktif
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
		
		# HBox Baris 3: Tombol Aksi Restock, Jual, Upgrade, dan Hancurkan
		var actions_hbox: HBoxContainer = HBoxContainer.new()
		actions_hbox.add_theme_constant_override("separation", 8)
		actions_hbox.alignment = BoxContainer.ALIGNMENT_END
		
		var btn_restock: Button = Button.new()
		btn_restock.text = "Restock"
		btn_restock.custom_minimum_size = Vector2(80, 32)
		btn_restock.pressed.connect(func() -> void:
			var success: bool = ShopManager.restock_rack(rack_idx)
			if success:
				lbl_stock.text = "Rak: %d/%d u" % [rack["current_stock"], rack["max_capacity"]]
				stock_bar.value = rack["current_stock"]
		)
		
		var btn_sell: Button = Button.new()
		btn_sell.text = "Jual 1"
		btn_sell.custom_minimum_size = Vector2(70, 32)
		btn_sell.pressed.connect(func() -> void:
			var success: bool = ShopManager.sell_unit(rack_idx)
			if success:
				lbl_stock.text = "Rak: %d/%d u" % [rack["current_stock"], rack["max_capacity"]]
				stock_bar.value = rack["current_stock"]
		)
		
		var btn_upgrade: Button = Button.new()
		var base_cap = 10 if rack["item_id"].begins_with("clothing") else 15
		if rack["max_capacity"] >= base_cap * 4:
			btn_upgrade.text = "Max Level"
			btn_upgrade.disabled = true
		else:
			var cost_up = 150 if rack["max_capacity"] < base_cap * 2 else 300
			btn_upgrade.text = "Upgrade ($%d)" % cost_up
			btn_upgrade.pressed.connect(func() -> void:
				ShopManager.upgrade_rack(rack_idx)
			)
		btn_upgrade.custom_minimum_size = Vector2(110, 32)
		
		var btn_destroy: Button = Button.new()
		btn_destroy.text = "Hancurkan (+$100)"
		btn_destroy.custom_minimum_size = Vector2(130, 32)
		btn_destroy.pressed.connect(func() -> void:
			ShopManager.destroy_rack(rack_idx)
		)
		
		actions_hbox.add_child(btn_restock)
		actions_hbox.add_child(btn_sell)
		actions_hbox.add_child(btn_upgrade)
		# Jangan biarkan pemain menghancurkan 3 rak awal jika itu satu-satunya rak, agar tidak softlock
		if ShopManager.racks.size() > 1:
			actions_hbox.add_child(btn_destroy)
			
		rack_box.add_child(actions_hbox)
		
		# Divider pembatas antar rak
		if rack_idx < ShopManager.racks.size() - 1 or ShopManager.racks.size() < 6:
			var separator: HSeparator = HSeparator.new()
			rack_box.add_child(separator)
			
		racks_container.add_child(rack_box)
		
	# 2. Tampilkan baris "Bangun Rak Baru" jika jumlah rak aktif kurang dari 6
	if ShopManager.racks.size() < 6:
		var build_box: VBoxContainer = VBoxContainer.new()
		build_box.add_theme_constant_override("separation", 8)
		
		var build_hbox: HBoxContainer = HBoxContainer.new()
		build_hbox.add_theme_constant_override("separation", 12)
		
		var lbl_build: Label = Label.new()
		lbl_build.text = "Slot Kosong (Slot %d/6)" % [ShopManager.racks.size() + 1]
		lbl_build.size_flags_horizontal = SIZE_EXPAND_FILL
		lbl_build.add_theme_font_size_override("font_size", 15)
		lbl_build.modulate = Color(0.5, 0.55, 0.6)
		
		# OptionButton untuk memilih produk dari database
		var opt_items: OptionButton = OptionButton.new()
		opt_items.custom_minimum_size = Vector2(200, 32)
		var db_items = DatabaseManager.get_all_items()
		for item in db_items:
			opt_items.add_item(item.name)
			
		var btn_build: Button = Button.new()
		btn_build.text = "Bangun Rak ($250)"
		btn_build.custom_minimum_size = Vector2(160, 32)
		btn_build.pressed.connect(func() -> void:
			if opt_items.selected != -1:
				var item_id = db_items[opt_items.selected].id
				ShopManager.build_rack(item_id)
		)
		
		build_hbox.add_child(lbl_build)
		build_hbox.add_child(opt_items)
		build_hbox.add_child(btn_build)
		build_box.add_child(build_hbox)
		racks_container.add_child(build_box)

## Memainkan animasi transisi pop-in elastis (overshoot) saat panel dibuka.
func play_open_animation() -> void:
	var panel_container: PanelContainer = get_node_or_null("CenterContainer/PanelContainer")
	if panel_container:
		# Tunggu satu frame agar engine Godot selesai mengkalkulasi properti size
		await get_tree().process_frame
		panel_container.pivot_offset = panel_container.size / 2
		panel_container.scale = Vector2(0.85, 0.85)
		panel_container.modulate.a = 0.0
		
		var tween: Tween = create_tween().set_parallel(true)
		tween.tween_property(panel_container, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(panel_container, "modulate:a", 1.0, 0.25)

