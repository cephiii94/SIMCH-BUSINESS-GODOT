extends Node

## Mengelola rating reputasi bintang toko dan daftar ulasan pelanggan otonom.

signal rating_changed(new_rating: float)
signal review_added(review: Dictionary)

var rating: float = 4.0 # Default rating bintang awal
var reviews: Array = []

## Menambahkan ulasan baru ke riwayat dan menghitung rating bintang rata-rata berjalan.
func add_review(stars: int, comment: String) -> void:
	var current_day: int = 1
	var time_mgr: Node = get_node_or_null("/root/TimeManager")
	if time_mgr:
		current_day = time_mgr.day
		
	var review: Dictionary = {
		"stars": stars,
		"comment": comment,
		"day": current_day
	}
	
	# Masukkan di awal agar ulasan terbaru selalu berada di paling atas
	reviews.insert(0, review)
	
	# Batasi riwayat ulasan maksimal 15 item
	if reviews.size() > 15:
		reviews.resize(15)
		
	# Hitung rata-rata berjalan dengan faktor kehalusan 0.08
	rating = clamp(rating + (stars - rating) * 0.08, 1.0, 5.0)
	
	rating_changed.emit(rating)
	review_added.emit(review)

## Menghasilkan ulasan ulasan berdasarkan hasil belanja, kasir, dan harga secara otonom.
func generate_customer_review(basket_size: int, shopping_list_size: int, has_cashier: bool, overprice_complaints: int = 0) -> void:
	if shopping_list_size == 0:
		return
		
	var ratio: float = float(basket_size) / float(shopping_list_size)
	var stars: int = 3
	var comments: Array = []
	
	if overprice_complaints > 0:
		# Ulasan buruk tentang harga kemahalan
		if overprice_complaints >= 2:
			stars = 1
			comments = [
				"Harga barang di toko ini sangat gila! Benar-benar perampokan!",
				"Harga-harga sangat tidak masuk akal, saya pulang karena kemahalan.",
				"Semua barang dinaikkan harganya terlalu tinggi. Sangat kecewa!"
			]
		else:
			stars = 2
			comments = [
				"Sebagian barang terlalu mahal dibandingkan toko lain.",
				"Toko ini mematok harga di atas standar. Kurang recommended.",
				"Barang bagus tapi harganya kemahalan, saya terpaksa batal membeli."
			]
	else:
		if ratio >= 1.0:
			if has_cashier:
				stars = 5
				comments = [
					"Sangat puas! Barangnya lengkap dan kasirnya cepat melayani.",
					"Toko yang sangat rapi! Semua daftar belanja saya terpenuhi.",
					"Pelayanan kasir luar biasa cepat dan produk lengkap."
				]
			else:
				stars = 4
				comments = [
					"Barang-barang lengkap, tapi sayang harus mengantre lama di kasir.",
					"Semua belanjaan ada, tapi tidak ada kasir yang bertugas."
				]
		elif ratio >= 0.5:
			stars = 3
			comments = [
				"Sebagian barang ada, tapi beberapa rak kosong.",
				"Belanjaan lumayan terpenuhi meskipun ada produk yang habis."
			]
		elif ratio > 0.0:
			stars = 2
			comments = [
				"Banyak barang yang habis. Tolong di-restock raknya!",
				"Mengecewakan, saya hanya dapat satu barang dari daftar saya."
			]
		else:
			stars = 1
			comments = [
				"Toko terburuk! Semua rak kosong melompong.",
				"Saya pulang dengan tangan kosong, tidak ada produk sama sekali."
			]
		
	var comment: String = comments[randi() % comments.size()]
	add_review(stars, comment)

	
## Menambahkan bonus rating reputasi secara instan (misal untuk reward pencapaian).
func add_reputation_bonus(amount: float) -> void:
	rating = clamp(rating + amount, 1.0, 5.0)
	rating_changed.emit(rating)

