class_name HUD
extends Control

## Mengatur antarmuka pengguna dasar (HUD) saat bermain.

signal settings_pressed
signal stats_pressed
signal warehouse_pressed
signal shop_pressed
signal staff_pressed
signal reviews_pressed
signal achievements_pressed


@onready var time_label: Label = %TimeLabel
@onready var cash_label: Label = %CashLabel
@onready var rating_label: Label = %RatingLabel

@onready var pause_button: Button = %PauseButton
@onready var play_button: Button = %PlayButton
@onready var fast_forward_button: Button = %FastForwardButton
@onready var settings_button: Button = %SettingsButton

@onready var shop_button: Button = %ShopButton
@onready var warehouse_button: Button = %WarehouseButton
@onready var staff_button: Button = %StaffButton
@onready var reviews_button: Button = %ReviewsButton
@onready var stats_button: Button = %StatsButton
@onready var achievements_button: Button = %AchievementsButton


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
	
	# Hubungkan tombol-tombol panel
	shop_button.pressed.connect(func() -> void: shop_pressed.emit())
	warehouse_button.pressed.connect(func() -> void: warehouse_pressed.emit())
	staff_button.pressed.connect(func() -> void: staff_pressed.emit())
	reviews_button.pressed.connect(func() -> void: reviews_pressed.emit())
	stats_button.pressed.connect(func() -> void: stats_pressed.emit())
	achievements_button.pressed.connect(func() -> void: achievements_pressed.emit())

	
	# Hubungkan ReputationManager secara dinamis
	var rep_mgr: Node = get_node_or_null("/root/ReputationManager")
	if rep_mgr:
		rep_mgr.rating_changed.connect(_on_rating_changed)
		_on_rating_changed(rep_mgr.rating)
	
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

func _on_rating_changed(new_rating: float) -> void:
	if rating_label:
		rating_label.text = "⭐ %.1f" % new_rating

func _update_time_button_states() -> void:
	if not TimeManager:
		return
		
	var normal_style: StyleBox = preload("res://src/ui/hud.tscn").get_state().get_node_stylebox(Vector2(0,0)) if false else null
	
	# Bersihkan penanda aktif dari tombol
	pause_button.release_focus()
	play_button.release_focus()
	fast_forward_button.release_focus()
	achievements_button.release_focus()

	
	# Modulasi visual sederhana untuk menandakan tombol mana yang sedang aktif
	pause_button.modulate = Color(1.5, 1.5, 1.5) if TimeManager.time_scale == 0.0 else Color(1, 1, 1)
	play_button.modulate = Color(1.5, 1.5, 1.5) if TimeManager.time_scale == 1.0 else Color(1, 1, 1)
	fast_forward_button.modulate = Color(1.5, 1.5, 1.5) if TimeManager.time_scale > 1.0 else Color(1, 1, 1)
