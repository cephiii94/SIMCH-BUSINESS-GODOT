class_name HUD
extends Control

## Mengatur antarmuka pengguna dasar (HUD) saat bermain.

signal settings_pressed
signal stats_pressed
signal warehouse_pressed
signal shop_pressed

@onready var time_label: Label = %TimeLabel
@onready var cash_label: Label = %CashLabel

@onready var pause_button: Button = %PauseButton
@onready var play_button: Button = %PlayButton
@onready var fast_forward_button: Button = %FastForwardButton
@onready var settings_button: Button = %SettingsButton

@onready var shop_button: Button = %ShopButton
@onready var warehouse_button: Button = %WarehouseButton
@onready var staff_button: Button = %StaffButton
@onready var stats_button: Button = %StatsButton

func _ready() -> void:
	# Hubungkan sinyal EventBus
	EventBus.time_tick.connect(_on_time_tick)
	EventBus.money_changed.connect(_on_money_changed)
	
	# Hubungkan kontrol waktu
	pause_button.pressed.connect(func() -> void:
		TimeManager.time_scale = 0.0
		_update_time_button_states()
	)
	play_button.pressed.connect(func() -> void:
		TimeManager.time_scale = 1.0
		_update_time_button_states()
	)
	fast_forward_button.pressed.connect(func() -> void:
		TimeManager.time_scale = 3.0
		_update_time_button_states()
	)
	
	# Hubungkan tombol pengaturan
	settings_button.pressed.connect(func() -> void: settings_pressed.emit())
	
	# Hubungkan tombol panel lainnya
	shop_button.pressed.connect(func() -> void: shop_pressed.emit())
	warehouse_button.pressed.connect(func() -> void: warehouse_pressed.emit())
	staff_button.pressed.connect(func() -> void: print("Buka Panel Staff (Sprint 13)"))
	stats_button.pressed.connect(func() -> void: stats_pressed.emit())
	
	# Inisialisasi visual tombol waktu
	_update_time_button_states()
	
	# Inisialisasi teks waktu dan uang
	if TimeManager:
		_on_time_tick(TimeManager.day, TimeManager.hour, TimeManager.minute)
	if EconomyManager:
		_on_money_changed(EconomyManager.cash)

func _on_time_tick(day: int, hour: int, minute: int) -> void:
	time_label.text = "Hari %d, %02d:%02d" % [day, hour, minute]

func _on_money_changed(new_balance: float) -> void:
	cash_label.text = "$%.2f" % new_balance

func _update_time_button_states() -> void:
	var scale: float = TimeManager.time_scale
	
	# Reset modulasi warna tombol
	pause_button.modulate = Color(1, 1, 1, 1)
	play_button.modulate = Color(1, 1, 1, 1)
	fast_forward_button.modulate = Color(1, 1, 1, 1)
	
	# Warnai tombol aktif dengan warna aksen biru-langit
	var active_color: Color = Color(0.121569, 0.529412, 0.901961, 1.0)
	if scale == 0.0:
		pause_button.modulate = active_color
	elif scale == 1.0:
		play_button.modulate = active_color
	elif scale == 3.0:
		fast_forward_button.modulate = active_color
