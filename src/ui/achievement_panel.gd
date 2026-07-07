class_name AchievementPanel
extends Control

## Mengatur UI panel Pencapaian Toko (Achievements Panel).

signal close_pressed

@onready var close_button: Button = %CloseButton
@onready var achievements_container: VBoxContainer = %AchievementsContainer
@onready var subtitle_label: Label = %SubtitleLabel

func _ready() -> void:
	close_button.pressed.connect(func() -> void: close_pressed.emit())
	
	# Hubungkan sinyal dari EventBus jika ingin memicu refresh instan saat pencapaian terbuka
	EventBus.achievement_unlocked.connect(func(_id: String, _title: String, _reward: String) -> void:
		populate_achievements()
	)

func populate_achievements() -> void:
	# Bersihkan daftar UI lama
	for child in achievements_container.get_children():
		child.queue_free()
		
	var ach_mgr = get_node_or_null("/root/AchievementManager")
	if not ach_mgr:
		return
		
	# Tampilkan total pelanggan terlayani
	subtitle_label.text = "Pelanggan Terlayani: %d" % ach_mgr.total_served
	
	for id in ach_mgr.achievements:
		var ach: Dictionary = ach_mgr.achievements[id]
		var unlocked: bool = ach["unlocked"]
		
		# Buat PanelContainer untuk item pencapaian
		var item_panel: PanelContainer = PanelContainer.new()
		var style: StyleBoxFlat = StyleBoxFlat.new()
		style.bg_color = Color(0.16, 0.20, 0.25, 0.5) if not unlocked else Color(0.18, 0.23, 0.29, 0.8)
		style.border_width_left = 2
		style.border_width_top = 2
		style.border_width_right = 2
		style.border_width_bottom = 2
		style.border_color = Color(0.25, 0.30, 0.37) if not unlocked else Color(0.95, 0.78, 0.10, 0.7)
		style.corner_radius_top_left = 8
		style.corner_radius_top_right = 8
		style.corner_radius_bottom_right = 8
		style.corner_radius_bottom_left = 8
		item_panel.add_theme_stylebox_override("panel", style)
		
		# Margin didalam item
		var margin: MarginContainer = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 12)
		margin.add_theme_constant_override("margin_top", 10)
		margin.add_theme_constant_override("margin_right", 12)
		margin.add_theme_constant_override("margin_bottom", 10)
		item_panel.add_child(margin)
		
		# HBox layout utama item
		var hbox: HBoxContainer = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 16)
		margin.add_child(hbox)
		
		# 1. Kiri: Icon Piala
		var icon_label: Label = Label.new()
		icon_label.text = "🏆"
		icon_label.add_theme_font_size_override("font_size", 28)
		icon_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		if not unlocked:
			icon_label.modulate = Color(0.4, 0.4, 0.4, 0.6) # Abu-abu jika terkunci
		hbox.add_child(icon_label)
		
		# 2. Tengah: Info Teks (Judul & Deskripsi)
		var vbox_info: VBoxContainer = VBoxContainer.new()
		vbox_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox_info.add_theme_constant_override("separation", 2)
		hbox.add_child(vbox_info)

		
		var title_label: Label = Label.new()
		title_label.text = ach["title"]
		title_label.add_theme_font_size_override("font_size", 16)
		if unlocked:
			title_label.add_theme_color_override("font_color", Color(0.95, 0.78, 0.10)) # Emas
		else:
			title_label.add_theme_color_override("font_color", Color(0.9, 0.9, 0.9))
		vbox_info.add_child(title_label)
		
		var desc_label: Label = Label.new()
		desc_label.text = ach["desc"]
		desc_label.add_theme_font_size_override("font_size", 13)
		desc_label.add_theme_color_override("font_color", Color(0.65, 0.7, 0.75))
		desc_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		vbox_info.add_child(desc_label)
		
		# 3. Kanan: Progress & Reward
		var vbox_right: VBoxContainer = VBoxContainer.new()
		vbox_right.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox_right.add_theme_constant_override("separation", 2)
		hbox.add_child(vbox_right)
		
		# Hitung Progress
		var progress_str: String = ""
		if unlocked:
			progress_str = "SELESAI"
		else:
			# Hitung nilai progress dinamis
			var cur_val: float = 0.0
			var max_val: float = ach["target_val"]
			match ach["target_type"]:
				"cash":
					if EconomyManager: cur_val = EconomyManager.cash
				"served":
					cur_val = ach_mgr.total_served
				"staff":
					var staff_mgr = get_node_or_null("/root/StaffManager")
					if staff_mgr: cur_val = staff_mgr.hired_staff.size()
				"rating":
					if ReputationManager: cur_val = ReputationManager.rating
				"racks":
					if ShopManager: cur_val = ShopManager.racks.size()
			
			if ach["target_type"] == "cash" or ach["target_type"] == "rating":
				progress_str = "%.1f / %.1f" % [cur_val, max_val]
			else:
				progress_str = "%d / %d" % [int(cur_val), int(max_val)]
				
		var progress_label: Label = Label.new()
		progress_label.text = progress_str
		progress_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		progress_label.add_theme_font_size_override("font_size", 13)
		if unlocked:
			progress_label.add_theme_color_override("font_color", Color(0.24, 0.76, 0.45)) # Hijau
		else:
			progress_label.add_theme_color_override("font_color", Color(0.6, 0.6, 0.6))
		vbox_right.add_child(progress_label)
		
		var reward_label: Label = Label.new()
		reward_label.text = "Hadiah: " + ach["reward_desc"]
		reward_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		reward_label.add_theme_font_size_override("font_size", 12)
		reward_label.add_theme_color_override("font_color", Color(0.4, 0.7, 0.9)) # Biru muda
		vbox_right.add_child(reward_label)
		
		achievements_container.add_child(item_panel)

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

