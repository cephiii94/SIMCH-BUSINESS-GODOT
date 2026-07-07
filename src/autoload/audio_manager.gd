extends Node

## Mengelola pemutaran musik latar (BGM), ambient, dan efek suara (SFX) dengan fallback sintesis gelombang suara retro.

var bgm_player: AudioStreamPlayer = null

func _ready() -> void:
	# Tunggu inisialisasi engine selesai
	await get_tree().process_frame
	
	# Hubungkan sinyal dari EventBus secara otomatis
	EventBus.customer_served.connect(_on_customer_served)
	EventBus.achievement_unlocked.connect(_on_achievement_unlocked)
	
	# Mulai mainkan musik latar
	play_music()

## Memutar musik latar utama secara melingkar (loop).
func play_music() -> void:
	var path_music: String = "res://assets/audio/music.ogg"
	if not FileAccess.file_exists(path_music):
		path_music = "res://assets/audio/music.mp3"
		
	if FileAccess.file_exists(path_music):
		bgm_player = AudioStreamPlayer.new()
		add_child(bgm_player)
		bgm_player.stream = load(path_music)
		bgm_player.bus = "Music"
		bgm_player.autoplay = true
		
		# Set loop jika stream mendukung properti tersebut
		if bgm_player.stream.has_method("set_loop"):
			bgm_player.stream.set_loop(true)
		elif "loop" in bgm_player.stream:
			bgm_player.stream.loop = true
			
		bgm_player.play()
		print("[AudioManager] Musik latar berhasil diputar dari berkas: ", path_music)
	else:
		print("[AudioManager] Musik latar tidak ditemukan di disk. Menunggu berkas 'music.ogg' dimasukkan ke assets/audio/.")

## Memutar efek suara (SFX) tertentu. Jika file aset tidak ada, gunakan synthesizer retro programatis.
func play_sfx(sfx_name: String) -> void:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.bus = "SFX"
	add_child(player)
	
	# Hubungkan sinyal agar node player otomatis terhapus saat selesai memutar
	player.finished.connect(func() -> void:
		player.queue_free()
	)
	
	# Coba cari file eksternal terlebih dahulu
	var file_found: bool = false
	var ext_list: Array = [".wav", ".ogg", ".mp3"]
	for ext in ext_list:
		var path_sfx: String = "res://assets/audio/" + sfx_name + ext
		if FileAccess.file_exists(path_sfx):
			player.stream = load(path_sfx)
			file_found = true
			break
			
	if file_found:
		player.play()
	else:
		# FALLBACK: Hasilkan gelombang suara bip retro dalam memori
		var stream: AudioStreamWAV = generate_beep_wave(sfx_name)
		if stream:
			player.stream = stream
			player.play()
		else:
			player.queue_free()

## Mensintesis data gelombang audio sinus biner (PCM 16-bit) untuk SFX retro 8-bit.
func generate_beep_wave(type: String) -> AudioStreamWAV:
	var sample_rate: int = 44100
	var data: PackedByteArray = PackedByteArray()
	
	match type:
		"click":
			# Bip pendek frekuensi tinggi (1000Hz, durasi 0.04 detik)
			var duration: float = 0.04
			var num_samples: int = int(duration * sample_rate)
			data.resize(num_samples * 2)
			
			for i in range(num_samples):
				var t: float = float(i) / float(sample_rate)
				var val: float = sin(2.0 * PI * 1000.0 * t)
				
				# Fade out di ujung agar suara tidak terpotong kasar
				if i > num_samples * 0.7:
					var fade: float = 1.0 - float(i - num_samples * 0.7) / float(num_samples * 0.3)
					val *= fade
					
				var int_val: int = int(val * 0.3 * 32767.0)
				data.encode_s16(i * 2, int_val)
				
		"cash":
			# Arpeggio koin naik (650Hz -> 1300Hz, durasi total 0.2 detik)
			var duration: float = 0.2
			var num_samples: int = int(duration * sample_rate)
			data.resize(num_samples * 2)
			
			for i in range(num_samples):
				var ratio: float = float(i) / float(num_samples)
				var freq: float = 650.0
				if ratio >= 0.4:
					freq = 1300.0
					
				var t: float = float(i) / float(sample_rate)
				var val: float = sin(2.0 * PI * freq * t)
				
				# Fade out di ujung
				if i > num_samples * 0.8:
					var fade: float = 1.0 - float(i - num_samples * 0.8) / float(num_samples * 0.2)
					val *= fade
					
				var int_val: int = int(val * 0.4 * 32767.0)
				data.encode_s16(i * 2, int_val)
				
		"unlock":
			# Melodi kemenangan 3-nada (C5 523Hz -> E5 659Hz -> G5 784Hz, total 0.3 detik)
			var duration: float = 0.3
			var num_samples: int = int(duration * sample_rate)
			data.resize(num_samples * 2)
			
			for i in range(num_samples):
				var ratio: float = float(i) / float(num_samples)
				var freq: float = 523.25
				if ratio >= 0.66:
					freq = 783.99
				elif ratio >= 0.33:
					freq = 659.25
					
				var t: float = float(i) / float(sample_rate)
				var val: float = sin(2.0 * PI * freq * t)
				
				# Fade out di ujung
				if i > num_samples * 0.9:
					var fade: float = 1.0 - float(i - num_samples * 0.9) / float(num_samples * 0.1)
					val *= fade
					
				var int_val: int = int(val * 0.4 * 32767.0)
				data.encode_s16(i * 2, int_val)
				
		"alert":
			# Bunyi alarm ganda (440Hz, durasi 0.35 detik dengan hening di tengah)
			var duration: float = 0.35
			var num_samples: int = int(duration * sample_rate)
			data.resize(num_samples * 2)
			
			for i in range(num_samples):
				var ratio: float = float(i) / float(num_samples)
				var val: float = 0.0
				var t: float = float(i) / float(sample_rate)
				
				# Bip pertama (0.0 s s/d 0.12 s), Hening (0.12 s s/d 0.20 s), Bip kedua (0.20 s s/d 0.32 s)
				if ratio < 0.34:
					val = sin(2.0 * PI * 440.0 * t)
				elif ratio >= 0.57 and ratio < 0.91:
					val = sin(2.0 * PI * 440.0 * t)
					
				# Fade out ujung bip kedua
				if ratio >= 0.8:
					var fade: float = 1.0 - float(i - num_samples * 0.8) / float(num_samples * 0.2)
					val *= fade
					
				var int_val: int = int(val * 0.35 * 32767.0)
				data.encode_s16(i * 2, int_val)
		_:
			return null
			
	var stream: AudioStreamWAV = AudioStreamWAV.new()
	stream.format = AudioStreamWAV.FORMAT_16_BITS
	stream.mix_rate = sample_rate
	stream.stereo = false
	stream.data = data
	stream.loop_mode = AudioStreamWAV.LOOP_DISABLED
	return stream

# --- Event Listeners ---

func _on_customer_served(_revenue: float) -> void:
	play_sfx("cash")

func _on_achievement_unlocked(_id: String, _title: String, _reward_desc: String) -> void:
	play_sfx("unlock")

