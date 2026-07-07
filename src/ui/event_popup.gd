class_name EventPopup
extends Control

## Mengatur UI panel Koran Berita Pagi Peristiwa Acak (Event Popup).

signal close_pressed

@onready var date_label: Label = %DateLabel
@onready var headline_label: Label = %HeadlineLabel
@onready var desc_label: Label = %DescLabel
@onready var ok_button: Button = %OkButton

func _ready() -> void:
	ok_button.pressed.connect(func() -> void:
		if AudioManager: AudioManager.play_sfx("click")
		close_pressed.emit()
	)

## Memasukkan data peristiwa acak aktif dan menyusun teks berita koran.
func setup(event_data: Dictionary) -> void:
	# Putar suara alarm peringatan koran pagi
	if AudioManager:
		AudioManager.play_sfx("alert")
		
	headline_label.text = event_data.get("name", "Tidak Ada Peristiwa")
	desc_label.text = event_data.get("desc", "Kehidupan kota berjalan tenang seperti biasa hari ini.")

	
	var current_day: int = 1
	var time_mgr: Node = get_node_or_null("/root/TimeManager")
	if time_mgr:
		current_day = time_mgr.day
		
	date_label.text = "EDISI HARIAN - HARI KE-%d" % current_day

## Memainkan animasi transisi pop-in elastis (overshoot) saat panel dibuka.
func play_open_animation() -> void:
	var panel_container: PanelContainer = get_node_or_null("CenterContainer/PanelContainer")
	if panel_container:
		# Tunggu satu frame agar engine Godot selesai mengkalkulasi properti size
		await get_tree().process_frame
		panel_container.pivot_offset = panel_container.size / 2
		panel_container.scale = Vector2(0.85, 0.85)
		panel_container.modulate.a = 0.0
		
		var tween: Tween = create_tween().set_parallel(true)
		tween.tween_property(panel_container, "scale", Vector2.ONE, 0.35).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(panel_container, "modulate:a", 1.0, 0.25)

