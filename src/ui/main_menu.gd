class_name MainMenu
extends Control

## Mengatur UI dan input dari Menu Utama game.

signal new_game_pressed
signal continue_pressed
signal settings_pressed
signal exit_pressed

@onready var new_game_button: Button = %NewGameButton
@onready var continue_button: Button = %ContinueButton
@onready var settings_button: Button = %SettingsButton
@onready var exit_button: Button = %ExitButton

func _ready() -> void:
	new_game_button.pressed.connect(func() -> void:
		if AudioManager: AudioManager.play_sfx("click")
		new_game_pressed.emit()
	)
	continue_button.pressed.connect(func() -> void:
		if AudioManager: AudioManager.play_sfx("click")
		continue_pressed.emit()
	)
	settings_button.pressed.connect(func() -> void:
		if AudioManager: AudioManager.play_sfx("click")
		settings_pressed.emit()
	)
	exit_button.pressed.connect(func() -> void:
		if AudioManager: AudioManager.play_sfx("click")
		exit_pressed.emit()
	)

	
	# Nonaktifkan tombol Continue jika tidak ada save file
	if SaveManager:
		continue_button.disabled = not SaveManager.has_save_file()
	else:
		continue_button.disabled = true
