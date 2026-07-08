extends Node

## Mengelola sistem waktu dalam game.

const MINUTE_DURATION: float = 1.0 # 1 detik riil = 1 menit game pada scale 1.0

var time_scale: float = 1.0:
	set(value):
		time_scale = value
		if value == 0.0:
			# Saat pause, biarkan Engine.time_scale = 1.0 agar UI Tween tetap berjalan lancar,
			# tetapi pergerakan fisik karakter dihentikan via cek time_scale == 0.0 di script mereka.
			Engine.time_scale = 1.0
		else:
			Engine.time_scale = value

var day: int = 1
var hour: int = 7
var minute: int = 0
var is_shop_open: bool = false
var is_day_ending: bool = false

var _time_accumulator: float = 0.0

func _process(delta: float) -> void:
	if time_scale <= 0.0:
		return
		
	# delta sudah otomatis dikalikan oleh Engine.time_scale saat dipercepat
	_time_accumulator += delta
	if _time_accumulator >= MINUTE_DURATION:
		_time_accumulator -= MINUTE_DURATION
		_advance_time()

func _advance_time() -> void:
	if hour >= 21:
		# Kunci jam di 21:00 malam selama sisa pelanggan belanja, matikan status buka
		is_shop_open = false
		return
		
	minute += 1
	if minute >= 60:
		minute = 0
		hour += 1
		
	if hour >= 8 and hour < 21:
		is_shop_open = true
	else:
		is_shop_open = false
			
	EventBus.time_tick.emit(day, hour, minute)

func skip_to_opening() -> void:
	hour = 8
	minute = 0
	is_shop_open = true
	_time_accumulator = 0.0
	EventBus.time_tick.emit(day, hour, minute)

func next_day() -> void:
	day += 1
	hour = 7
	minute = 0
	is_shop_open = false
	is_day_ending = false
	_time_accumulator = 0.0
	time_scale = 1.0 # Jalankan waktu kembali
	EventBus.time_tick.emit(day, hour, minute)


