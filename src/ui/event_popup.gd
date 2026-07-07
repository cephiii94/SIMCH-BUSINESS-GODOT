class_name EventPopup
extends Control

## Mengatur UI panel Koran Berita Pagi Peristiwa Acak (Event Popup).

signal close_pressed

@onready var date_label: Label = %DateLabel
@onready var headline_label: Label = %HeadlineLabel
@onready var desc_label: Label = %DescLabel
@onready var ok_button: Button = %OkButton

func _ready() -> void:
	ok_button.pressed.connect(func() -> void: close_pressed.emit())

## Memasukkan data peristiwa acak aktif dan menyusun teks berita koran.
func setup(event_data: Dictionary) -> void:
	headline_label.text = event_data.get("name", "Tidak Ada Peristiwa")
	desc_label.text = event_data.get("desc", "Kehidupan kota berjalan tenang seperti biasa hari ini.")
	
	var current_day: int = 1
	var time_mgr: Node = get_node_or_null("/root/TimeManager")
	if time_mgr:
		current_day = time_mgr.day
		
	date_label.text = "EDISI HARIAN - HARI KE-%d" % current_day
