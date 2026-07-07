extends Node

## Mengelola sistem waktu dalam game.

const MINUTE_DURATION: float = 1.0 # 1 detik riil = 1 menit game pada scale 1.0

var time_scale: float = 1.0
var day: int = 1
var hour: int = 8
var minute: int = 0

var _time_accumulator: float = 0.0

func _process(delta: float) -> void:
	if time_scale <= 0.0:
		return
		
	_time_accumulator += delta * time_scale
	if _time_accumulator >= MINUTE_DURATION:
		_time_accumulator -= MINUTE_DURATION
		_advance_time()

func _advance_time() -> void:
	minute += 1
	if minute >= 60:
		minute = 0
		hour += 1
		if hour >= 24:
			hour = 0
			day += 1
			
	EventBus.time_tick.emit(day, hour, minute)
