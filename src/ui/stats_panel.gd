class_name StatsPanel
extends Control

## Mengatur UI panel Laporan Keuangan & Kinerja (Statistics Panel).

signal close_pressed

@onready var title_label: Label = %Title
@onready var income_val: Label = %IncomeValue
@onready var cogs_val: Label = %CogsValue
@onready var wages_val: Label = %WagesValue
@onready var rent_val: Label = %RentValue
@onready var profit_val: Label = %ProfitValue

@onready var history_container: VBoxContainer = %HistoryContainer
@onready var employee_reports_container: VBoxContainer = %EmployeeReportsContainer
@onready var revenue_graph: Control = %RevenueGraph
@onready var close_button: Button = %CloseButton

func _ready() -> void:
	close_button.pressed.connect(func() -> void: close_pressed.emit())
	
	# Hubungkan sinyal dari EventBus untuk mengupdate laporan secara real-time
	EventBus.daily_report_generated.connect(_on_daily_report_generated)
	
	# Tampilan default jika belum ada laporan
	_show_empty_report()

func _show_empty_report() -> void:
	title_label.text = "Laporan Keuangan Hari Kemarin"
	income_val.text = "$0.00"
	cogs_val.text = "$0.00"
	wages_val.text = "$0.00"
	rent_val.text = "$0.00"
	profit_val.text = "$0.00"
	profit_val.add_theme_color_override("font_color", Color(1, 1, 1, 1))

func update_report(report: Dictionary) -> void:
	title_label.text = "Laporan Keuangan Hari ke-%d" % report["day"]
	income_val.text = "$%.2f" % report["income"]
	cogs_val.text = "$%.2f" % report["cogs"]
	wages_val.text = "$%.2f" % report["wages"]
	rent_val.text = "$%.2f" % report["rent_utilities"]
	profit_val.text = "$%.2f" % report["profit"]
	
	if report["profit"] >= 0.0:
		profit_val.add_theme_color_override("font_color", Color(0.239216, 0.760784, 0.447059, 1))
	else:
		profit_val.add_theme_color_override("font_color", Color(0.9, 0.3, 0.3, 1))

func populate_history() -> void:
	# 1. Bersihkan daftar riwayat lama
	for child in history_container.get_children():
		child.queue_free()
		
	# 2. Refresh grafik laba
	if revenue_graph and revenue_graph.has_method("refresh"):
		revenue_graph.refresh()
		
	# 3. Refresh laporan kinerja karyawan
	populate_employee_report()
		
	if not EconomyManager or EconomyManager.daily_reports.is_empty():
		var label: Label = Label.new()
		label.text = "Belum ada riwayat laporan keuangan."
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.modulate = Color(0.6, 0.6, 0.6)
		history_container.add_child(label)
		
		# Set ringkasan default ke kosong jika tidak ada laporan harian
		_show_empty_report()
		return
		
	# Update ringkasan ke hari terakhir laporan
	var last_report = EconomyManager.daily_reports[-1]
	update_report(last_report)
		
	# Tampilkan dari yang paling baru ke lama
	var reports: Array[Dictionary] = EconomyManager.daily_reports.duplicate()
	reports.reverse()
	
	for report in reports:
		var hbox: HBoxContainer = HBoxContainer.new()
		hbox.theme_override_constants.separation = 16
		
		# Kolom Hari
		var lbl_day: Label = Label.new()
		lbl_day.text = "Hari %d" % report["day"]
		lbl_day.custom_minimum_size = Vector2(80, 0)
		
		# Kolom Pendapatan
		var lbl_inc: Label = Label.new()
		lbl_inc.text = "+$%.2f" % report["income"]
		lbl_inc.custom_minimum_size = Vector2(100, 0)
		lbl_inc.modulate = Color(0.5, 0.85, 0.5, 1.0)
		
		# Kolom Pengeluaran
		var lbl_exp: Label = Label.new()
		lbl_exp.text = "-$%.2f" % report["expense"]
		lbl_exp.custom_minimum_size = Vector2(100, 0)
		lbl_exp.modulate = Color(0.9, 0.5, 0.5, 1.0)
		
		# Kolom Laba Bersih
		var lbl_prof: Label = Label.new()
		var prof: float = report["profit"]
		lbl_prof.text = ("+$%.2f" if prof >= 0.0 else "$%.2f") % prof
		lbl_prof.custom_minimum_size = Vector2(120, 0)
		if prof >= 0.0:
			lbl_prof.modulate = Color(0.239216, 0.760784, 0.447059, 1.0)
		else:
			lbl_prof.modulate = Color(0.9, 0.3, 0.3, 1.0)
			
		hbox.add_child(lbl_day)
		hbox.add_child(lbl_inc)
		hbox.add_child(lbl_exp)
		hbox.add_child(lbl_prof)
		history_container.add_child(hbox)

## Merender laporan performa karyawan (produktivitas & sisa energi harian).
func populate_employee_report() -> void:
	for child in employee_reports_container.get_children():
		child.queue_free()
		
	var staff_mgr = get_node_or_null("/root/StaffManager")
	if not staff_mgr or staff_mgr.hired_staff.is_empty():
		var label: Label = Label.new()
		label.text = "Belum mempekerjakan karyawan aktif."
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.modulate = Color(0.6, 0.6, 0.6)
		employee_reports_container.add_child(label)
		return
		
	for staff in staff_mgr.hired_staff:
		# Buat PanelContainer untuk baris info karyawan
		var panel: PanelContainer = PanelContainer.new()
		var style: StyleBoxFlat = StyleBoxFlat.new()
		style.bg_color = Color(0.16, 0.20, 0.25, 0.6)
		style.border_width_left = 1
		style.border_width_top = 1
		style.border_width_right = 1
		style.border_width_bottom = 1
		style.border_color = Color(0.25, 0.30, 0.37)
		style.corner_radius_top_left = 6
		style.corner_radius_top_right = 6
		style.corner_radius_bottom_right = 6
		style.corner_radius_bottom_left = 6
		panel.add_theme_stylebox_override("panel", style)
		
		var margin: MarginContainer = MarginContainer.new()
		margin.add_theme_constant_override("margin_left", 12)
		margin.add_theme_constant_override("margin_top", 8)
		margin.add_theme_constant_override("margin_right", 12)
		margin.add_theme_constant_override("margin_bottom", 8)
		panel.add_child(margin)
		
		var hbox: HBoxContainer = HBoxContainer.new()
		hbox.add_theme_constant_override("separation", 16)
		margin.add_child(hbox)
		
		# 1. Kiri: Nama & Peran
		var vbox_info: VBoxContainer = VBoxContainer.new()
		vbox_info.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		vbox_info.add_theme_constant_override("separation", 2)
		hbox.add_child(vbox_info)
		
		var lbl_name: Label = Label.new()
		lbl_name.text = staff["name"]
		lbl_name.add_theme_font_size_override("font_size", 15)
		lbl_name.add_theme_color_override("font_color", Color(0.9, 0.95, 1))
		vbox_info.add_child(lbl_name)
		
		var lbl_role: Label = Label.new()
		lbl_role.text = "Peran: %s (Gaji: $%.0f/hari)" % [staff["role"], staff["daily_wage"]]
		lbl_role.add_theme_font_size_override("font_size", 12)
		lbl_role.add_theme_color_override("font_color", Color(0.5, 0.6, 0.7))
		vbox_info.add_child(lbl_role)
		
		# 2. Tengah: Sisa Energi
		var vbox_energy: VBoxContainer = VBoxContainer.new()
		vbox_energy.custom_minimum_size = Vector2(140, 0)
		vbox_energy.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox_energy.add_theme_constant_override("separation", 2)
		hbox.add_child(vbox_energy)
		
		var energy_val = staff.get("energy", 100.0)
		var lbl_energy_title: Label = Label.new()
		lbl_energy_title.text = "Sisa Energi: %.1f%%" % energy_val
		lbl_energy_title.add_theme_font_size_override("font_size", 12)
		
		# Tentukan warna teks energi berdasarkan kelelahan
		if energy_val >= 70.0:
			lbl_energy_title.add_theme_color_override("font_color", Color(0.24, 0.76, 0.45)) # Hijau
		elif energy_val >= 30.0:
			lbl_energy_title.add_theme_color_override("font_color", Color(0.95, 0.78, 0.10)) # Kuning
		else:
			lbl_energy_title.add_theme_color_override("font_color", Color(0.85, 0.35, 0.35)) # Merah
		vbox_energy.add_child(lbl_energy_title)
		
		# Progress Bar Mini sederhana untuk energi
		var progress: ProgressBar = ProgressBar.new()
		progress.custom_minimum_size = Vector2(0, 10)
		progress.show_percentage = false
		progress.value = energy_val
		vbox_energy.add_child(progress)
		
		# 3. Kanan: Kontribusi Produktivitas Harian
		var vbox_prod: VBoxContainer = VBoxContainer.new()
		vbox_prod.custom_minimum_size = Vector2(160, 0)
		vbox_prod.alignment = BoxContainer.ALIGNMENT_CENTER
		vbox_prod.add_theme_constant_override("separation", 2)
		hbox.add_child(vbox_prod)
		
		var prod_count = staff.get("productivity", 0)
		var lbl_prod_title: Label = Label.new()
		lbl_prod_title.text = "Produktivitas Hari Ini"
		lbl_prod_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		lbl_prod_title.add_theme_font_size_override("font_size", 12)
		lbl_prod_title.add_theme_color_override("font_color", Color(0.6, 0.65, 0.7))
		vbox_prod.add_child(lbl_prod_title)
		
		var lbl_prod_val: Label = Label.new()
		if staff["role"] == "Cashier":
			lbl_prod_val.text = "%d pelanggan dilayani" % prod_count
		else:
			lbl_prod_val.text = "%d kali restock rak" % prod_count
		lbl_prod_val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		lbl_prod_val.add_theme_font_size_override("font_size", 14)
		lbl_prod_val.add_theme_color_override("font_color", Color(0.25, 0.65, 0.9)) # Biru cerah
		vbox_prod.add_child(lbl_prod_val)
		
		employee_reports_container.add_child(panel)

func _on_daily_report_generated(report: Dictionary) -> void:
	update_report(report)
	# Memicu menggambar ulang grafik
	if revenue_graph and revenue_graph.has_method("refresh"):
		revenue_graph.refresh()
