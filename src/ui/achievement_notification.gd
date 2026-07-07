extends Control

## Mengatur notifikasi melayang (pop-up) ketika pencapaian baru terbuka.

@onready var title_label: Label = %TitleLabel
@onready var reward_label: Label = %RewardLabel

func setup(title: String, reward_desc: String) -> void:
	title_label.text = title
	reward_label.text = "Hadiah: " + reward_desc
	
	# Transisi pudar masuk (fade-in), tampil, lalu pudar keluar (fade-out)
	modulate.a = 0.0
	var tween: Tween = create_tween()
	# Fade-in dalam 0.4 detik
	tween.tween_property(self, "modulate:a", 1.0, 0.4)
	# Tahan visual selama 3.0 detik
	tween.tween_interval(3.0)
	# Fade-out dalam 0.4 detik
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	# Bersihkan node notifikasi setelah selesai
	tween.tween_callback(queue_free)
