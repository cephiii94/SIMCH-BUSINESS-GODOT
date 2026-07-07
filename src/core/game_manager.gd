class_name GameManager
extends Node

## Mengontrol alur state game utama (MainMenu, Playing, Paused).

enum GameState {
	MAIN_MENU,
	PLAYING,
	PAUSED
}

var current_state: GameState = GameState.MAIN_MENU
var _prev_time_scale: float = 1.0

@onready var world: Node2D = %World
@onready var ui: CanvasLayer = %UI
@onready var main_menu: Control = %MainMenu
@onready var settings_menu: Control = %SettingsMenu
@onready var hud: Control = %HUD
@onready var stats_panel: Control = %StatsPanel
@onready var warehouse_panel: Control = %WarehousePanel
@onready var shop_panel: Control = %ShopPanel
@onready var staff_panel: Control = %StaffPanel
@onready var reputation_panel: Control = %ReputationPanel
@onready var event_popup: Control = %EventPopup

func _ready() -> void:
	# Hubungkan sinyal dari MainMenu
	if main_menu:
		main_menu.new_game_pressed.connect(_on_new_game_pressed)
		main_menu.continue_pressed.connect(_on_continue_pressed)
		main_menu.settings_pressed.connect(_on_settings_pressed)
		main_menu.exit_pressed.connect(_on_exit_pressed)
	
	# Hubungkan sinyal dari HUD
	if hud:
		hud.settings_pressed.connect(_on_settings_pressed)
		hud.stats_pressed.connect(_on_stats_pressed)
		hud.warehouse_pressed.connect(_on_warehouse_pressed)
		hud.shop_pressed.connect(_on_shop_pressed)
		hud.staff_pressed.connect(_on_staff_pressed)
		hud.reviews_pressed.connect(_on_reviews_pressed)
	
	# Hubungkan sinyal dari SettingsMenu
	if settings_menu:
		settings_menu.back_pressed.connect(_on_settings_back_pressed)
		
	# Hubungkan sinyal dari StatsPanel
	if stats_panel:
		stats_panel.close_pressed.connect(_on_stats_close_pressed)
		
	# Hubungkan sinyal dari WarehousePanel
	if warehouse_panel:
		warehouse_panel.close_pressed.connect(_on_warehouse_close_pressed)
		
	# Hubungkan sinyal dari ShopPanel
	if shop_panel:
		shop_panel.close_pressed.connect(_on_shop_close_pressed)
		
	# Hubungkan sinyal dari StaffPanel
	if staff_panel:
		staff_panel.close_pressed.connect(_on_staff_close_pressed)
		
	# Hubungkan sinyal dari ReputationPanel
	if reputation_panel:
		reputation_panel.close_pressed.connect(_on_reviews_close_pressed)
		
	# Hubungkan sinyal dari EventPopup
	if event_popup:
		event_popup.close_pressed.connect(_on_event_close_pressed)
	
	# Mulai dengan Main Menu
	change_state(GameState.MAIN_MENU)

## Mengubah state game dan menyesuaikan visibilitas node terkait.
func change_state(new_state: GameState) -> void:
	current_state = new_state
	match current_state:
		GameState.MAIN_MENU:
			if world:
				world.hide()
			if main_menu:
				main_menu.show()
			if settings_menu:
				settings_menu.hide()
			if hud:
				hud.hide()
			if stats_panel:
				stats_panel.hide()
			if warehouse_panel:
				warehouse_panel.hide()
			if shop_panel:
				shop_panel.hide()
			if staff_panel:
				staff_panel.hide()
			if reputation_panel:
				reputation_panel.hide()
			if event_popup:
				event_popup.hide()
		GameState.PLAYING:
			if world:
				world.show()
			if main_menu:
				main_menu.hide()
			if settings_menu:
				settings_menu.hide()
			if hud:
				hud.show()
			if stats_panel:
				stats_panel.hide()
			if warehouse_panel:
				warehouse_panel.hide()
			if shop_panel:
				shop_panel.hide()
			if staff_panel:
				staff_panel.hide()
			if reputation_panel:
				reputation_panel.hide()
			if event_popup:
				event_popup.hide()
		GameState.PAUSED:
			pass

func _on_new_game_pressed() -> void:
	EventBus.game_started.emit()
	change_state(GameState.PLAYING)

func _on_continue_pressed() -> void:
	EventBus.game_started.emit()
	change_state(GameState.PLAYING)
	
	# Tunggu satu frame agar dunia game ter-inisialisasi
	await get_tree().process_frame
	var save_mgr: Node = get_node_or_null("/root/SaveManager")
	if save_mgr:
		save_mgr.load_game()

func _on_settings_pressed() -> void:
	if settings_menu:
		# Tampilkan tombol Save Game hanya saat sedang dalam permainan
		var save_btn: Button = settings_menu.get_node_or_null("%SaveButton") as Button
		if save_btn:
			save_btn.visible = (current_state == GameState.PLAYING)
		settings_menu.show()
	if main_menu:
		main_menu.hide()
	if hud:
		hud.hide()
	if stats_panel:
		stats_panel.hide()
	if warehouse_panel:
		warehouse_panel.hide()
	if shop_panel:
		shop_panel.hide()
	if staff_panel:
		staff_panel.hide()
	if reputation_panel:
		reputation_panel.hide()
	if event_popup:
		event_popup.hide()

func _on_exit_pressed() -> void:
	EventBus.game_exited.emit()
	get_tree().quit()

func _on_settings_back_pressed() -> void:
	if settings_menu:
		settings_menu.hide()
	
	if current_state == GameState.MAIN_MENU:
		if main_menu:
			main_menu.show()
	elif current_state == GameState.PLAYING:
		if hud:
			hud.show()

func _on_stats_pressed() -> void:
	if stats_panel:
		if TimeManager:
			_prev_time_scale = TimeManager.time_scale
			TimeManager.time_scale = 0.0
		stats_panel.populate_history()
		stats_panel.show()
	if hud:
		hud.hide()

func _on_stats_close_pressed() -> void:
	if stats_panel:
		stats_panel.hide()
	if hud:
		hud.show()
	if TimeManager:
		TimeManager.time_scale = _prev_time_scale

func _on_warehouse_pressed() -> void:
	if warehouse_panel:
		if TimeManager:
			_prev_time_scale = TimeManager.time_scale
			TimeManager.time_scale = 0.0
		warehouse_panel.show()
	if hud:
		hud.hide()

func _on_warehouse_close_pressed() -> void:
	if warehouse_panel:
		warehouse_panel.hide()
	if hud:
		hud.show()
	if TimeManager:
		TimeManager.time_scale = _prev_time_scale

func _on_shop_pressed() -> void:
	if shop_panel:
		if TimeManager:
			_prev_time_scale = TimeManager.time_scale
			TimeManager.time_scale = 0.0
		# Refresh data rak sebelum ditampilkan
		if shop_panel.has_method("_populate_racks_list"):
			shop_panel._populate_racks_list()
		shop_panel.show()
	if hud:
		hud.hide()

func _on_shop_close_pressed() -> void:
	if shop_panel:
		shop_panel.hide()
	if hud:
		hud.show()
	if TimeManager:
		TimeManager.time_scale = _prev_time_scale

func _on_staff_pressed() -> void:
	if staff_panel:
		if TimeManager:
			_prev_time_scale = TimeManager.time_scale
			TimeManager.time_scale = 0.0
		if staff_panel.has_method("_refresh_views"):
			staff_panel._refresh_views()
		staff_panel.show()
	if hud:
		hud.hide()

func _on_staff_close_pressed() -> void:
	if staff_panel:
		staff_panel.hide()
	if hud:
		hud.show()
	if TimeManager:
		TimeManager.time_scale = _prev_time_scale

func _on_reviews_pressed() -> void:
	if reputation_panel:
		if TimeManager:
			_prev_time_scale = TimeManager.time_scale
			TimeManager.time_scale = 0.0
		if reputation_panel.has_method("_populate_reviews_list"):
			reputation_panel._populate_reviews_list()
		reputation_panel.show()
	if hud:
		hud.hide()

func _on_reviews_close_pressed() -> void:
	if reputation_panel:
		reputation_panel.hide()
	if hud:
		hud.show()
	if TimeManager:
		TimeManager.time_scale = _prev_time_scale

func _show_daily_event_popup(event_data: Dictionary) -> void:
	if event_popup:
		if TimeManager:
			_prev_time_scale = TimeManager.time_scale
			TimeManager.time_scale = 0.0
		event_popup.setup(event_data)
		event_popup.show()
	if hud:
		hud.hide()

func _on_event_close_pressed() -> void:
	if event_popup:
		event_popup.hide()
	if hud:
		hud.show()
	if TimeManager:
		TimeManager.time_scale = _prev_time_scale
