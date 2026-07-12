class_name GameCamera
extends Camera2D

## Kamera 2D dengan dukungan pergerakan keyboard, mouse drag, dan smooth zoom.

const MIN_ZOOM: float = 0.5
const MAX_ZOOM: float = 2.5
const ZOOM_STEP: float = 0.15
const ZOOM_SPEED: float = 12.0
const MAP_LIMIT: float = 1000.0

@export var speed: float = 500.0

var _target_zoom: Vector2 = Vector2.ONE
var _is_dragging: bool = false

func _ready() -> void:
	# Atur batas kamera agar tidak bisa keluar dari peta isometrik 2.5D
	limit_left = -2200
	limit_right = 2200
	limit_top = -1100
	limit_bottom = 1100
	
	# Aktifkan pergerakan posisi halus bawaan Godot
	position_smoothing_enabled = true
	position_smoothing_speed = 8.0
	
	_target_zoom = zoom

func _process(delta: float) -> void:
	# Interpolasi nilai zoom secara halus
	if zoom != _target_zoom:
		zoom = zoom.lerp(_target_zoom, ZOOM_SPEED * delta)
		
	# Pergerakan keyboard (WASD atau Arah Panah)
	var input_dir: Vector2 = Vector2.ZERO
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		input_dir.x += 1.0
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		input_dir.x -= 1.0
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		input_dir.y += 1.0
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		input_dir.y -= 1.0
		
	if input_dir != Vector2.ZERO:
		# Kecepatan gerak menyesuaikan tingkat zoom
		global_position += input_dir.normalized() * speed * delta / zoom.x

func _unhandled_input(event: InputEvent) -> void:
	# Klik kanan drag untuk menggeser kamera
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			if event.pressed:
				_is_dragging = true
			else:
				_is_dragging = false
				
		# Scroll wheel mouse untuk memperbesar/memperkecil
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			_zoom_camera(ZOOM_STEP)
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			_zoom_camera(-ZOOM_STEP)
			
	# Pergeseran posisi kamera ketika men-drag mouse
	if event is InputEventMouseMotion and _is_dragging:
		# Kecepatan seret diimbangi oleh zoom agar sinkron dengan gerakan kursor
		global_position -= event.relative / zoom
		# Matikan perataan posisi sesaat agar seretan terasa instan dan responsif
		force_update_scroll()

func _zoom_camera(amount: float) -> void:
	var new_zoom_val: float = clampf(_target_zoom.x + amount, MIN_ZOOM, MAX_ZOOM)
	_target_zoom = Vector2(new_zoom_val, new_zoom_val)
