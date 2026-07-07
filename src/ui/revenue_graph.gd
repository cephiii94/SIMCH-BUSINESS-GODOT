extends Control

## Menggambar grafik garis (line chart) laba bersih harian secara grafis di UI.

var padding_left: float = 60.0
var padding_right: float = 30.0
var padding_top: float = 30.0
var padding_bottom: float = 40.0

func _draw() -> void:
	# Gambar background panel dalam transparan gelap
	draw_rect(Rect2(Vector2.ZERO, size), Color(0.117, 0.149, 0.188, 0.5), true)
	
	if not EconomyManager or EconomyManager.daily_reports.is_empty():
		_draw_empty_message()
		return
		
	var reports = EconomyManager.daily_reports
	var count = reports.size()
	
	# Ambil data laba (profit) harian
	var profits: Array[float] = []
	for report in reports:
		profits.append(report["profit"])
		
	# Tentukan batas Y
	var max_profit: float = -999999.0
	var min_profit: float = 999999.0
	for p in profits:
		if p > max_profit: max_profit = p
		if p < min_profit: min_profit = p
		
	# Tambahkan toleransi margin minimal agar tidak mepet
	if max_profit == min_profit:
		max_profit += 100.0
		min_profit -= 100.0
	else:
		var diff = max_profit - min_profit
		max_profit += diff * 0.15
		min_profit -= diff * 0.15
		
	# Gambar sumbu X dan Y
	var chart_width = size.x - padding_left - padding_right
	var chart_height = size.y - padding_top - padding_bottom
	
	var origin_x = padding_left
	var origin_y = size.y - padding_bottom
	
	# Gambar Grid Horizontal (3 garis)
	for i in range(4):
		var ratio = float(i) / 3.0
		var y_pos = origin_y - ratio * chart_height
		var val = min_profit + ratio * (max_profit - min_profit)
		
		# Garis bantu horizontal
		draw_line(Vector2(origin_x, y_pos), Vector2(size.x - padding_right, y_pos), Color(0.2, 0.25, 0.3, 0.4), 1.0)
		# Teks nilai Y
		draw_string(ThemeDB.fallback_font, Vector2(10, y_pos + 4), "$%.0f" % val, HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.6, 0.65, 0.7))

	# Gambar Garis Laba $0 (Break-Even Line) jika berada dalam rentang
	if min_profit < 0.0 and max_profit > 0.0:
		var zero_ratio = (0.0 - min_profit) / (max_profit - min_profit)
		var zero_y = origin_y - zero_ratio * chart_height
		draw_line(Vector2(origin_x, zero_y), Vector2(size.x - padding_right, zero_y), Color(0.85, 0.35, 0.35, 0.8), 1.5)
		draw_string(ThemeDB.fallback_font, Vector2(size.x - padding_right + 4, zero_y + 4), "Nol", HORIZONTAL_ALIGNMENT_LEFT, -1, 10, Color(0.85, 0.35, 0.35))

	# Dapatkan koordinat poin-poin data
	var points: Array[Vector2] = []
	for i in range(count):
		var x_ratio = 0.5
		if count > 1:
			x_ratio = float(i) / float(count - 1)
		
		var x_pos = origin_x + x_ratio * chart_width
		
		var y_ratio = (profits[i] - min_profit) / (max_profit - min_profit)
		var y_pos = origin_y - y_ratio * chart_height
		
		points.append(Vector2(x_pos, y_pos))
		
	# Gambar Garis Penghubung Grafik
	if count > 1:
		for i in range(count - 1):
			var color_line = Color(0.12, 0.53, 0.90) # Biru premium
			# Gambar garis tebal 3px
			draw_line(points[i], points[i+1], color_line, 3.0, true)
			
	# Gambar Titik Poin, Nilai Angka, dan Label Hari
	for i in range(count):
		var pt = points[i]
		var val = profits[i]
		
		# Gambar lingkaran poin luar
		draw_circle(pt, 5.0, Color(0.95, 0.78, 0.10)) # Emas
		draw_circle(pt, 2.5, Color(0.117, 0.149, 0.188)) # Lubang tengah agar terlihat modern hollow
		
		# Tulis teks angka laba di atas/bawah lingkaran
		var txt_val = ("+$%.0f" if val >= 0.0 else "$%.0f") % val
		var txt_color = Color(0.24, 0.76, 0.45) if val >= 0.0 else Color(0.85, 0.35, 0.35)
		var text_offset_y = -10.0 if val >= 0.0 else 18.0
		draw_string(ThemeDB.fallback_font, Vector2(pt.x - 20, pt.y + text_offset_y), txt_val, HORIZONTAL_ALIGNMENT_CENTER, 40, 10, txt_color)
		
		# Tulis label Hari di bagian bawah
		var txt_day = "H%d" % reports[i]["day"]
		draw_string(ThemeDB.fallback_font, Vector2(pt.x - 15, size.y - 12), txt_day, HORIZONTAL_ALIGNMENT_CENTER, 30, 11, Color(0.6, 0.65, 0.7))

func _draw_empty_message() -> void:
	var msg = "Belum ada riwayat laporan keuangan\n(Jalankan minimal 1 hari permainan untuk memperbarui grafik)"
	draw_string(ThemeDB.fallback_font, Vector2(0, size.y / 2 - 8), msg, HORIZONTAL_ALIGNMENT_CENTER, size.x, 14, Color(0.5, 0.55, 0.6))

## Pemicu menggambar ulang grafik
func refresh() -> void:
	queue_redraw()
