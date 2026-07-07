extends Node

## Mengelola daftar pencapaian (Achievement), progres kumulatif, dan pemberian hadiah (Unlock Reward).

# Daftar definisi pencapaian
var achievements: Dictionary = {
	"cash_15k": {
		"title": "Pengusaha Pemula",
		"desc": "Miliki saldo kas sebesar $15,000.",
		"target_type": "cash",
		"target_val": 15000.0,
		"reward_type": "reputation",
		"reward_val": 0.2,
		"reward_desc": "+0.2 Bintang ⭐",
		"unlocked": false
	},
	"cash_50k": {
		"title": "Konglomerat Lokal",
		"desc": "Miliki saldo kas sebesar $50,000.",
		"target_type": "cash",
		"target_val": 50000.0,
		"reward_type": "reputation",
		"reward_val": 0.5,
		"reward_desc": "+0.5 Bintang ⭐",
		"unlocked": false
	},
	"served_50": {
		"title": "Pelayanan Prima",
		"desc": "Layani 50 pelanggan di tokomu.",
		"target_type": "served",
		"target_val": 50,
		"reward_type": "cash",
		"reward_val": 500.0,
		"reward_desc": "+$500 Cash 💵",
		"unlocked": false
	},
	"served_200": {
		"title": "Legenda Ritel",
		"desc": "Layani 200 pelanggan di tokomu.",
		"target_type": "served",
		"target_val": 200,
		"reward_type": "cash",
		"reward_val": 2500.0,
		"reward_desc": "+$2,500 Cash 💵",
		"unlocked": false
	},
	"staff_3": {
		"title": "Bos Besar",
		"desc": "Pekerjakan 3 karyawan aktif secara bersamaan.",
		"target_type": "staff",
		"target_val": 3,
		"reward_type": "cash",
		"reward_val": 1000.0,
		"reward_desc": "+$1,000 Cash 💵",
		"unlocked": false
	},
	"rating_4_8": {
		"title": "Bintang Lima",
		"desc": "Mencapai reputasi toko minimal ⭐ 4.8.",
		"target_type": "rating",
		"target_val": 4.8,
		"reward_type": "cash",
		"reward_val": 1500.0,
		"reward_desc": "+$1,500 Cash 💵",
		"unlocked": false
	},
	"racks_5": {
		"title": "Ekspansi Toko",
		"desc": "Miliki minimal 5 rak pajangan barang di toko.",
		"target_type": "racks",
		"target_val": 5,
		"reward_type": "cash",
		"reward_val": 800.0,
		"reward_desc": "+$800 Cash 💵",
		"unlocked": false
	}
}

# State kumulatif yang disimpan
var total_served: int = 0

func _ready() -> void:
	# Tunggu agar autoload lain selesai inisialisasi
	await get_tree().process_frame
	
	# Hubungkan sinyal dari EventBus dan manager lainnya
	EventBus.money_changed.connect(_on_money_changed)
	EventBus.customer_served.connect(_on_customer_served)
	
	var staff_mgr = get_node_or_null("/root/StaffManager")
	if staff_mgr:
		staff_mgr.staff_list_changed.connect(_on_staff_changed)
		
	var rep_mgr = get_node_or_null("/root/ReputationManager")
	if rep_mgr:
		rep_mgr.rating_changed.connect(_on_rating_changed)
		
	var shop_mgr = get_node_or_null("/root/ShopManager")
	if shop_mgr:
		shop_mgr.racks_changed.connect(_on_racks_changed)

## Fungsi untuk memeriksa kelayakan seluruh pencapaian secara manual (biasanya dipanggil setelah load game).
func check_all_achievements() -> void:
	_check_cash()
	_check_served()
	_check_staff()
	_check_rating()
	_check_racks()

## Membuka pencapaian tertentu dan memberikan hadiahnya.
func unlock_achievement(id: String) -> void:
	if not achievements.has(id) or achievements[id]["unlocked"]:
		return
		
	var ach = achievements[id]
	ach["unlocked"] = true
	
	# Berikan Hadiah/Reward
	_apply_reward(ach["reward_type"], ach["reward_val"])
	
	# Pancarkan sinyal global agar UI dapat menampilkan notifikasi
	EventBus.achievement_unlocked.emit(id, ach["title"], ach["reward_desc"])
	print("[AchievementManager] Pencapaian terbuka: ", ach["title"], " (", ach["reward_desc"], ")")

func _apply_reward(type: String, val: float) -> void:
	match type:
		"cash":
			if EconomyManager:
				# Gunakan record_income agar tercatat di laba kotor hari itu
				EconomyManager.record_income(val)
		"reputation":
			if ReputationManager:
				ReputationManager.add_reputation_bonus(val)

# --- Event Listeners & Checkers ---

func _on_money_changed(_new_balance: float) -> void:
	_check_cash()

func _check_cash() -> void:
	if not EconomyManager:
		return
	var cash_val: float = EconomyManager.cash
	if cash_val >= 15000.0:
		unlock_achievement("cash_15k")
	if cash_val >= 50000.0:
		unlock_achievement("cash_50k")

func _on_customer_served(_revenue: float) -> void:
	total_served += 1
	_check_served()

func _check_served() -> void:
	if total_served >= 50:
		unlock_achievement("served_50")
	if total_served >= 200:
		unlock_achievement("served_200")

func _on_staff_changed() -> void:
	_check_staff()

func _check_staff() -> void:
	var staff_mgr = get_node_or_null("/root/StaffManager")
	if not staff_mgr:
		return
	if staff_mgr.hired_staff.size() >= 3:
		unlock_achievement("staff_3")

func _on_rating_changed(_new_rating: float) -> void:
	_check_rating()

func _check_rating() -> void:
	if not ReputationManager:
		return
	if ReputationManager.rating >= 4.8:
		unlock_achievement("rating_4_8")

func _on_racks_changed() -> void:
	_check_racks()

func _check_racks() -> void:
	if not ShopManager:
		return
	if ShopManager.racks.size() >= 5:
		unlock_achievement("racks_5")
