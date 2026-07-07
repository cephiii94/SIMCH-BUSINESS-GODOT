extends Node

## Mengatur pembacaan dan penulisan berkas save game secara manual maupun otomatis (auto-save).

const SAVE_PATH: String = "user://save_game.json"

func _ready() -> void:
	# Hubungkan sinyal akhir hari untuk memicu auto-save tengah malam
	EventBus.daily_report_generated.connect(_on_daily_report_generated)

## Mengecek apakah file save game ada.
func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)

## Menyimpan status permainan aktif ke berkas JSON.
func save_game() -> bool:
	var save_data: Dictionary = {
		"time": {},
		"economy": {},
		"warehouse": {},
		"shop": {},
		"staff": {},
		"reputation": {}
	}
	
	# 1. Waktu
	var time_mgr: Node = get_node_or_null("/root/TimeManager")
	if time_mgr:
		save_data["time"] = {
			"day": time_mgr.day,
			"hour": time_mgr.hour,
			"minute": time_mgr.minute
		}
		
	# 2. Ekonomi
	var eco_mgr: Node = get_node_or_null("/root/EconomyManager")
	if eco_mgr:
		save_data["economy"] = {
			"cash": eco_mgr.cash,
			"daily_reports": eco_mgr.daily_reports
		}
		
	# 3. Gudang (Warehouse)
	var shop_mgr: Node = get_node_or_null("/root/ShopManager")
	if shop_mgr:
		var items_dict: Dictionary = {}
		if shop_mgr.warehouse_inventory:
			items_dict = shop_mgr.warehouse_inventory.items
			save_data["warehouse"] = {
				"capacity": shop_mgr.warehouse_inventory.max_capacity,
				"items": items_dict
			}
		
		# 4. Rak Toko (Shop)
		save_data["shop"] = {
			"racks": shop_mgr.racks,
			"prices": shop_mgr.prices
		}
		
	# 5. Staf / Karyawan (Staff)
	var staff_mgr: Node = get_node_or_null("/root/StaffManager")
	if staff_mgr:
		save_data["staff"] = {
			"hired_staff": staff_mgr.hired_staff,
			"applicants": staff_mgr.applicants
		}
		
	# 6. Reputasi & Ulasan
	var rep_mgr: Node = get_node_or_null("/root/ReputationManager")
	if rep_mgr:
		save_data["reputation"] = {
			"rating": rep_mgr.rating,
			"reviews": rep_mgr.reviews
		}
		
	# Tulis ke file
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if not file:
		print("[ERROR-SAVE] Gagal membuka file save game untuk penulisan!")
		return false
		
	var json_string: String = JSON.stringify(save_data, "\t")
	file.store_string(json_string)
	file.close()
	
	print("[SaveManager] Game berhasil disimpan ke: ", SAVE_PATH)
	return true

## Memuat status permainan dari berkas JSON dan memulihkan objek game.
func load_game() -> bool:
	if not has_save_file():
		return false
		
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if not file:
		print("[ERROR-SAVE] Gagal membuka file save game untuk pembacaan!")
		return false
		
	var json_string: String = file.get_as_text()
	file.close()
	
	var json: JSON = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		print("[ERROR-SAVE] Gagal melakukan parse JSON berkas save game!")
		return false
		
	var save_data: Dictionary = json.data
	
	# 1. Muat Waktu
	if save_data.has("time") and save_data["time"] is Dictionary:
		var time_mgr: Node = get_node_or_null("/root/TimeManager")
		if time_mgr:
			var t: Dictionary = save_data["time"]
			time_mgr.day = t.get("day", 1)
			time_mgr.hour = t.get("hour", 8)
			time_mgr.minute = t.get("minute", 0)
			time_mgr.time_scale = 1.0 # Jalankan normal kembali
			
	# 2. Muat Ekonomi
	if save_data.has("economy") and save_data["economy"] is Dictionary:
		var eco_mgr: Node = get_node_or_null("/root/EconomyManager")
		if eco_mgr:
			var eco: Dictionary = save_data["economy"]
			eco_mgr.cash = eco.get("cash", 1000.0)
			eco_mgr.daily_reports.clear()
			var reports_loaded = eco.get("daily_reports", [])
			for report in reports_loaded:
				if report is Dictionary:
					eco_mgr.daily_reports.append(report)
			EventBus.money_changed.emit(eco_mgr.cash)
			
	# 3. Muat Gudang & Logistik
	var shop_mgr: Node = get_node_or_null("/root/ShopManager")
	if shop_mgr and shop_mgr.warehouse_inventory:
		if save_data.has("warehouse") and save_data["warehouse"] is Dictionary:
			var wh: Dictionary = save_data["warehouse"]
			shop_mgr.warehouse_inventory.max_capacity = wh.get("capacity", 100)
			
			# Konversi kunci item_id
			var items_loaded: Dictionary = wh.get("items", {})
			shop_mgr.warehouse_inventory.items.clear()
			for item_id in items_loaded:
				shop_mgr.warehouse_inventory.items[item_id] = int(items_loaded[item_id])
				
			# Refresh visual UI kapasitas gudang
			shop_mgr.warehouse_inventory.capacity_updated.emit(
				shop_mgr.warehouse_inventory.get_current_volume(),
				shop_mgr.warehouse_inventory.max_capacity
			)
			shop_mgr.warehouse_inventory.stock_changed.emit("", 0)
			
	# 4. Muat Rak Toko
	if shop_mgr:
		if save_data.has("shop") and save_data["shop"] is Dictionary:
			var sh: Dictionary = save_data["shop"]
			
			# Muat data rak
			shop_mgr.racks.clear()
			var racks_loaded: Array = sh.get("racks", [])
			for rack in racks_loaded:
				if rack is Dictionary:
					shop_mgr.racks.append(rack)
			
			# Muat database harga
			var prices_loaded: Dictionary = sh.get("prices", {})
			shop_mgr.prices = prices_loaded
			
	# 5. Muat Staf
	if save_data.has("staff") and save_data["staff"] is Dictionary:
		var staff_mgr: Node = get_node_or_null("/root/StaffManager")
		if staff_mgr:
			var st: Dictionary = save_data["staff"]
			staff_mgr.hired_staff = st.get("hired_staff", [])
			staff_mgr.applicants = st.get("applicants", [])
			staff_mgr.staff_list_changed.emit()
			
	# 6. Muat Reputasi
	if save_data.has("reputation") and save_data["reputation"] is Dictionary:
		var rep_mgr: Node = get_node_or_null("/root/ReputationManager")
		if rep_mgr:
			var rep: Dictionary = save_data["reputation"]
			rep_mgr.rating = rep.get("rating", 4.0)
			rep_mgr.reviews = rep.get("reviews", [])
			rep_mgr.rating_changed.emit(rep_mgr.rating)
			
	# 7. Muat entitas fisik di peta secara asinkron
	var scene_root: Node = get_tree().current_scene
	if scene_root:
		var world_node: Node2D = scene_root.get_node_or_null("World") as Node2D
		if world_node:
			# Bersihkan pelanggan yang sedang berbelanja
			var entities_node: Node2D = world_node.get_node_or_null("Entities") as Node2D
			if entities_node:
				for child in entities_node.get_children():
					# Bersihkan hanya customer (tidak ada properti staff_id)
					if not "staff_id" in child:
						child.queue_free()
						
			# Sinkronisasi box fisik gudang
			if world_node.has_method("load_warehouse_boxes"):
				world_node.load_warehouse_boxes()
				
			# Sinkronisasi karyawan fisik
			if world_node.has_method("sync_employees"):
				world_node.sync_employees()
				
	print("[SaveManager] Game berhasil dimuat dari save file.")
	return true

func _on_daily_report_generated(_report: Dictionary) -> void:
	# Pemicu penyimpanan otomatis (auto-save) tengah malam
	save_game()
	print("[SaveManager] Auto-save tengah malam berhasil diselesaikan.")
