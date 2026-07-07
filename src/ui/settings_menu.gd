class_name SettingsMenu
extends Control

## Mengatur UI dan logika panel Pengaturan (Settings).

signal back_pressed

@onready var screen_mode_button: OptionButton = %ScreenModeButton
@onready var master_slider: HSlider = %MasterSlider
@onready var music_slider: HSlider = %MusicSlider
@onready var sfx_slider: HSlider = %SfxSlider
@onready var back_button: Button = %BackButton

func _ready() -> void:
	# Inisialisasi Pilihan Layar
	screen_mode_button.clear()
	screen_mode_button.add_item("Windowed")
	screen_mode_button.add_item("Fullscreen")
	
	# Set mode layar aktif saat ini
	var current_mode: DisplayServer.WindowMode = DisplayServer.window_get_mode()
	if current_mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
		screen_mode_button.selected = 1
	else:
		screen_mode_button.selected = 0
		
	# Hubungkan sinyal pilihan layar
	screen_mode_button.item_selected.connect(_on_screen_mode_selected)
	
	# Inisialisasi nilai volume audio
	master_slider.value = _get_bus_volume_pct("Master")
	music_slider.value = _get_bus_volume_pct("Music")
	sfx_slider.value = _get_bus_volume_pct("SFX")
	
	# Hubungkan sinyal slider audio
	master_slider.value_changed.connect(func(val: float) -> void: _set_bus_volume("Master", val))
	music_slider.value_changed.connect(func(val: float) -> void: _set_bus_volume("Music", val))
	sfx_slider.value_changed.connect(func(val: float) -> void: _set_bus_volume("SFX", val))
	
	# Hubungkan tombol kembali
	back_button.pressed.connect(func() -> void: back_pressed.emit())

func _on_screen_mode_selected(index: int) -> void:
	if index == 0:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	elif index == 1:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _get_bus_volume_pct(bus_name: String) -> float:
	var bus_idx: int = AudioServer.get_bus_index(bus_name)
	if bus_idx != -1:
		if AudioServer.is_bus_mute(bus_idx):
			return 0.0
		var db: float = AudioServer.get_bus_volume_db(bus_idx)
		return db_to_linear(db) * 100.0
	return 80.0 # Default value

func _set_bus_volume(bus_name: String, value_pct: float) -> void:
	var bus_idx: int = AudioServer.get_bus_index(bus_name)
	if bus_idx != -1:
		if value_pct == 0.0:
			AudioServer.set_bus_mute(bus_idx, true)
		else:
			AudioServer.set_bus_mute(bus_idx, false)
			var db: float = linear_to_db(value_pct / 100.0)
			AudioServer.set_bus_volume_db(bus_idx, db)
