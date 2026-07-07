class_name ReputationPanel
extends Control

## Mengatur UI panel Ulasan Pelanggan (Reputation/Review Panel).

signal close_pressed

@onready var close_button: Button = %CloseButton
@onready var reviews_container: VBoxContainer = %ReviewsContainer
@onready var rating_label: Label = %OverallRatingLabel

func _ready() -> void:
	close_button.pressed.connect(func() -> void: close_pressed.emit())
	
	if ReputationManager:
		ReputationManager.review_added.connect(func(_r: Dictionary) -> void:
			_populate_reviews_list()
		)
		
	_populate_reviews_list()

func _populate_reviews_list() -> void:
	# Bersihkan daftar UI lama
	for child in reviews_container.get_children():
		child.queue_free()
		
	if not ReputationManager:
		return
		
	# Tampilkan nilai rating besar
	rating_label.text = "%.1f / 5.0" % ReputationManager.rating
	
	if ReputationManager.reviews.size() == 0:
		var lbl: Label = Label.new()
		lbl.text = "Belum ada ulasan dari pelanggan."
		lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		lbl.modulate = Color(0.6, 0.6, 0.6)
		reviews_container.add_child(lbl)
		return
		
	for i in range(ReputationManager.reviews.size()):
		var rev: Dictionary = ReputationManager.reviews[i]
		
		# VBox untuk menampung satu baris review
		var vbox: VBoxContainer = VBoxContainer.new()
		vbox.add_theme_constant_override("separation", 4)
		
		var hbox_header: HBoxContainer = HBoxContainer.new()
		hbox_header.add_theme_constant_override("separation", 12)
		
		# Tampilkan bintang
		var stars_str: String = ""
		for j in range(rev["stars"]):
			stars_str += "⭐"
		var lbl_stars: Label = Label.new()
		lbl_stars.text = stars_str
		
		var lbl_day: Label = Label.new()
		lbl_day.text = "[Hari %d]" % rev["day"]
		lbl_day.add_theme_font_size_override("font_size", 12)
		lbl_day.modulate = Color(0.5, 0.55, 0.6, 1.0)
		
		hbox_header.add_child(lbl_stars)
		hbox_header.add_child(lbl_day)
		vbox.add_child(hbox_header)
		
		# Komentar ulasan
		var lbl_comment: Label = Label.new()
		lbl_comment.text = rev["comment"]
		lbl_comment.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		lbl_comment.add_theme_font_size_override("font_size", 14)
		
		# Modulasi warna berdasarkan kepuasan (1-2 bintang merah, 4-5 bintang hijau)
		if rev["stars"] >= 4:
			lbl_comment.modulate = Color(0.75, 0.9, 0.8, 1.0) # Hijau muda
		elif rev["stars"] <= 2:
			lbl_comment.modulate = Color(0.9, 0.75, 0.75, 1.0) # Merah muda
			
		vbox.add_child(lbl_comment)
		reviews_container.add_child(vbox)
		
		# Divider
		if i < ReputationManager.reviews.size() - 1:
			var separator: HSeparator = HSeparator.new()
			reviews_container.add_child(separator)
