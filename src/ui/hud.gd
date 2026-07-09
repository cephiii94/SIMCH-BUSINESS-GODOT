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

# Node dinamis untuk status toko dan aksi
var status_label: Label = null
var action_button: Button = null

func _ready() -> void:
	# Instansiasi label status toko secara programatis di sebelah jam
	status_label = Label.new()
	status_label.name = "ShopStatusLabel"
	if time_label:
		time_label.get_parent().add_child(status_label)
		time_label.get_parent().move_child(status_label, time_label.get_index() + 1)
		
	# Instansiasi tombol aksi kerja (Buka Toko / Hari Berikutnya) di parent kontrol waktu
	action_button = Button.new()
	action_button.name = "ShopActionButton"
	action_button.text = "Buka Toko"
	action_button.custom_minimum_size = Vector2(120, 30)
	if play_button:
		play_button.get_parent().add_child(action_button)
		action_button.pressed.connect(func() -> void:
			if AudioManager: AudioManager.play_sfx("click")
			if TimeManager:
				if TimeManager.hour == 7:
					TimeManager.skip_to_opening()
				elif TimeManager.is_day_ending:
					var scene_root = get_tree().current_scene
					if scene_root and scene_root.has_method("transition_to_next_day"):
						scene_root.transition_to_next_day()
			_update_action_button_state()
		)

	# Hubungkan sinyal EventBus
	EventBus.time_tick.connect(_on_time_tick)
	EventBus.money_changed.connect(_on_money_changed)
	EventBus.end_of_shift.connect(_update_action_button_state)
	
	visibility_changed.connect(func() -> void:
		if visible:
			_update_action_button_state()
	)

	
	# Hubungkan kontrol waktu
	pause_button.pressed.connect(func() -> void:
		if AudioManager: AudioManager.play_sfx("click")
		TimeManager.time_scale = 0.0
		_update_time_button_states()
	)
	play_button.pressed.connect(func() -> void:
		if AudioManager: AudioManager.play_sfx("click")
		TimeManager.time_scale = 1.0
		_update_time_button_states()
	)
	fast_forward_button.pressed.connect(func() -> void:
		if AudioManager: AudioManager.play_sfx("click")
		TimeManager.time_scale = 3.0
		_update_time_button_states()
	)
	
	# Hubungkan tombol pengaturan
	settings_button.pressed.connect(func() -> void:
		if AudioManager: AudioManager.play_sfx("click")
		settings_pressed.emit()
	)
	
	# Hubungkan tombol-tombol panel
	shop_button.pressed.connect(func() -> void:
		if AudioManager: AudioManager.play_sfx("click")
		shop_pressed.emit()
	)
	warehouse_button.pressed.connect(func() -> void:
		if AudioManager: AudioManager.play_sfx("click")
		warehouse_pressed.emit()
	)
	staff_button.pressed.connect(func() -> void:
		if AudioManager: AudioManager.play_sfx("click")
		staff_pressed.emit()
	)
	reviews_button.pressed.connect(func() -> void:
		if AudioManager: AudioManager.play_sfx("click")
		reviews_pressed.emit()
	)
	stats_button.pressed.connect(func() -> void:
		if AudioManager: AudioManager.play_sfx("click")
		stats_pressed.emit()
	)
	achievements_button.pressed.connect(func() -> void:
		if AudioManager: AudioManager.play_sfx("click")
		achievements_pressed.emit()
	)


	
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
	
	# Update Label Status Toko
	if status_label and TimeManager:
		if TimeManager.is_shop_open:
			status_label.text = " [BUKA]"
			status_label.add_theme_color_override("font_color", Color(0.2, 0.9, 0.2)) # Hijau
		else:
			status_label.text = " [TUTUP]"
			status_label.add_theme_color_override("font_color", Color(0.9, 0.2, 0.2)) # Merah
			
	# Update Visibilitas Tombol Aksi Kerja & Kontrol Waktu
	_update_action_button_state()

func _update_action_button_state() -> void:
	if not TimeManager or not action_button:
		return
		
	if TimeManager.hour == 7:
		# Fase Persiapan Pagi
		action_button.show()
		action_button.text = "Buka Toko"
		pause_button.hide()
		play_button.hide()
		fast_forward_button.hide()
	elif TimeManager.is_day_ending:
		# Akhir Hari (EOS) - Menunggu tombol Next Day
		action_button.show()
		action_button.text = "Hari Berikutnya"
		pause_button.hide()
		play_button.hide()
		fast_forward_button.hide()
	else:
		# Jam Operasional Aktif (08:00 - 21:00)
		action_button.hide()
		pause_button.show()
		play_button.show()
		fast_forward_button.show()


func _on_money_changed(new_balance: float) -> void:
	cash_label.text = "$%.2f" % new_balance

func _on_rating_changed(new_rating: float) -> void:
	if rating_label:
		rating_label.text = "⭐ %.1f" % new_rating

func _update_time_button_states() -> void:
	if not TimeManager:
		return
		
	var normal_style: StyleBox = null
	
	# Bersihkan penanda aktif dari tombol
	pause_button.release_focus()
	play_button.release_focus()
	fast_forward_button.release_focus()
	achievements_button.release_focus()

	
	# Modulasi visual sederhana untuk menandakan tombol mana yang sedang aktif
	pause_button.modulate = Color(1.5, 1.5, 1.5) if TimeManager.time_scale == 0.0 else Color(1, 1, 1)
	play_button.modulate = Color(1.5, 1.5, 1.5) if TimeManager.time_scale == 1.0 else Color(1, 1, 1)
	fast_forward_button.modulate = Color(1.5, 1.5, 1.5) if TimeManager.time_scale > 1.0 else Color(1, 1, 1)
