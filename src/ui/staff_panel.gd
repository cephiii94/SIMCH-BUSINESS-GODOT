class_name StaffPanel
extends Control

## Mengatur UI panel Manajemen Karyawan (Staff Panel) rekrutmen dan pecat.

signal close_pressed

@onready var close_button: Button = %CloseButton
@onready var hired_list: VBoxContainer = %HiredList
@onready var applicant_list: VBoxContainer = %ApplicantList

func _ready() -> void:
	close_button.pressed.connect(func() -> void: close_pressed.emit())
	
	if StaffManager:
		StaffManager.staff_list_changed.connect(_refresh_views)
		
	_refresh_views()

func _refresh_views() -> void:
	_populate_hired_list()
	_populate_applicant_list()

func _populate_hired_list() -> void:
	for child in hired_list.get_children():
		child.queue_free()
		
	if not StaffManager:
		return
		
	if StaffManager.hired_staff.size() == 0:
		var lbl: Label = Label.new()
		lbl.text = "Belum ada staf yang dipekerjakan."
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.modulate = Color(0.6, 0.6, 0.6)
		hired_list.add_child(lbl)
		return
		
	for i in range(StaffManager.hired_staff.size()):
		var staff_idx: int = i
		var staff: Dictionary = StaffManager.hired_staff[staff_idx]
		
		var hbox: HBoxContainer = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 12)
		
		# Kolom Info Staf
		var vbox_info: VBoxContainer = VBoxContainer.new()
		vbox_info.size_flags_horizontal = SIZE_EXPAND_FILL
		
		var lbl_name: Label = Label.new()
		lbl_name.text = staff["name"] + " - " + staff["role"]
		lbl_name.add_theme_font_size_override("font_size", 15)
		
		var lbl_stats: Label = Label.new()
		lbl_stats.text = "Kecepatan: %.2fx | Gaji Harian: $%.2f" % [staff["speed"], staff["daily_wage"]]
		lbl_stats.add_theme_font_size_override("font_size", 12)
		lbl_stats.modulate = Color(0.5, 0.55, 0.6)
		
		vbox_info.add_child(lbl_name)
		vbox_info.add_child(lbl_stats)
		
		# Tombol Pecat
		var btn_fire: Button = Button.new()
		btn_fire.text = "Pecat"
		btn_fire.custom_minimum_size = Vector2(80, 32)
		btn_fire.pressed.connect(func() -> void:
			StaffManager.fire_employee(staff_idx)
		)
		
		hbox.add_child(vbox_info)
		hbox.add_child(btn_fire)
		hired_list.add_child(hbox)
		
		# Divider
		if staff_idx < StaffManager.hired_staff.size() - 1:
			var separator: HSeparator = HSeparator.new()
			hired_list.add_child(separator)

func _populate_applicant_list() -> void:
	for child in applicant_list.get_children():
		child.queue_free()
		
	if not StaffManager:
		return
		
	if StaffManager.applicants.size() == 0:
		var lbl: Label = Label.new()
		lbl.text = "Tidak ada lamaran pekerjaan masuk saat ini."
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.modulate = Color(0.6, 0.6, 0.6)
		applicant_list.add_child(lbl)
		return
		
	for i in range(StaffManager.applicants.size()):
		var app_idx: int = i
		var applicant: Dictionary = StaffManager.applicants[app_idx]
		
		var hbox: HBoxContainer = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 12)
		
		# Kolom Info Pelamar
		var vbox_info: VBoxContainer = VBoxContainer.new()
		vbox_info.size_flags_horizontal = SIZE_EXPAND_FILL
		
		var lbl_name: Label = Label.new()
		lbl_name.text = applicant["name"] + " - " + applicant["role"]
		lbl_name.add_theme_font_size_override("font_size", 15)
		
		var lbl_stats: Label = Label.new()
		lbl_stats.text = "Kecepatan: %.2fx | Gaji: $%.2f/hari | Biaya Rekrut: $%.2f" % [applicant["speed"], applicant["daily_wage"], applicant["hire_cost"]]
		lbl_stats.add_theme_font_size_override("font_size", 12)
		lbl_stats.modulate = Color(0.5, 0.55, 0.6)
		
		vbox_info.add_child(lbl_name)
		vbox_info.add_child(lbl_stats)
		
		# Tombol Rekrut
		var btn_hire: Button = Button.new()
		btn_hire.text = "Rekrut"
		btn_hire.custom_minimum_size = Vector2(80, 32)
		btn_hire.pressed.connect(func() -> void:
			var success: bool = StaffManager.hire_employee(app_idx)
			if not success:
				print("[WARNING-STAFF] Kas tidak cukup untuk rekrutmen!")
		)
		
		hbox.add_child(vbox_info)
		hbox.add_child(btn_hire)
		applicant_list.add_child(hbox)
		
		# Divider
		if app_idx < StaffManager.applicants.size() - 1:
			var separator: HSeparator = HSeparator.new()
			applicant_list.add_child(separator)

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

