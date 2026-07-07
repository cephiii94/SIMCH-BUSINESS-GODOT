class_name StatsPanel
extends Control

## Mengatur UI panel Laporan Keuangan (Statistics Panel).

signal close_pressed

@onready var title_label: Label = %Title
@onready var income_val: Label = %IncomeValue
@onready var cogs_val: Label = %CogsValue
@onready var wages_val: Label = %WagesValue
@onready var rent_val: Label = %RentValue
@onready var profit_val: Label = %ProfitValue

@onready var history_container: VBoxContainer = %HistoryContainer
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
	# Bersihkan daftar riwayat lama
	for child in history_container.get_children():
		child.queue_free()
		
	if not EconomyManager or EconomyManager.daily_reports.is_empty():
		var label: Label = Label.new()
		label.text = "Belum ada riwayat laporan keuangan."
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		history_container.add_child(label)
		return
		
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

func _on_daily_report_generated(report: Dictionary) -> void:
	update_report(report)
