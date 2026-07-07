extends Node

## Mengelola pemicuan peristiwa acak harian (Random Events) dan penyimpanan modifikator aktif.

signal event_triggered(event_data: Dictionary)

var active_event: Dictionary = {}
var event_pool: Array = []
var event_shown_today: bool = false

var _last_tracked_day: int = 1

func _ready() -> void:
	# Inisialisasi pool peristiwa acak
	_initialize_event_pool()
	
	# Hubungkan sinyal waktu dari EventBus
	EventBus.time_tick.connect(_on_time_tick)
	
	var time_mgr: Node = get_node_or_null("/root/TimeManager")
	if time_mgr:
		_last_tracked_day = time_mgr.day

func _initialize_event_pool() -> void:
	event_pool = [
		{
			"id": "hari_pasar",
			"name": "Hari Pasar Meriah",
			"desc": "Festival lingkungan membuat warga antusias berbelanja! Jumlah pelanggan yang masuk toko meningkat 2 kali lipat hari ini.",
			"customer_spawn_mult": 0.5
		},
		{
			"id": "hari_hujan",
			"name": "Hujan Badai Besar",
			"desc": "Hujan lebat disertai angin kencang melanda wilayah sekitar. Kebanyakan warga memilih menetap di rumah, mengurangi pengunjung toko hingga 50%.",
			"customer_spawn_mult": 2.0
		},
		{
			"id": "inflasi_susu",
			"name": "Kelangkaan Susu Sapi",
			"desc": "Distribusi susu terganggu akibat kendala peternakan lokal. Harga beli grosir Susu Kotak naik 50% hari ini.",
			"grocery_milk_wholesale_mult": 1.5
		},
		{
			"id": "subsidi_roti",
			"name": "Subsidi Terigu Pemerintah",
			"desc": "Kabar gembira! Subsidi komoditas terigu nasional membuat harga beli grosir Roti Tawar di distributor turun 30% hari ini.",
			"grocery_bread_wholesale_mult": 0.7
		},
		{
			"id": "semangat_staf",
			"name": "Hari Apresiasi Pekerja",
			"desc": "Motivasi kerja melambung tinggi! Kecepatan gerak jalan dan pelayanan seluruh karyawan bertambah 30% hari ini.",
			"staff_speed_mult": 1.3
		},
		{
			"id": "sidak_pajak",
			"name": "Audit Kantor Pajak",
			"desc": "Pemeriksaan administrasi rutin pajak daerah telah selesai. Toko Anda dikenakan denda pelanggaran kecil tata ruang sebesar $200.",
			"immediate_cash_deduct": 200.0
		}
	]

func _on_time_tick(day: int, _hour: int, _minute: int) -> void:
	if day > _last_tracked_day:
		_last_tracked_day = day
		event_shown_today = false
		trigger_daily_event()

## Melakukan kocokan acak untuk memicu event baru (peluang 40%).
func trigger_daily_event() -> void:
	active_event.clear()
	
	# Peluang 40% terpicu
	if randf() <= 0.40:
		var idx: int = randi() % event_pool.size()
		# Duplikat kamus agar tidak memengaruhi data asli pool
		active_event = event_pool[idx].duplicate()
		
		# Proses modifikator instan (seperti pemotongan kas denda pajak)
		if active_event.has("immediate_cash_deduct"):
			var amount: float = active_event["immediate_cash_deduct"]
			if EconomyManager:
				EconomyManager.record_expense(amount, EconomyManager.ExpenseType.RENT_UTILITY)
				
		event_triggered.emit(active_event)
		print("[EventManager] Event hari ini terpicu: ", active_event["name"])
	else:
		event_triggered.emit({})
		print("[EventManager] Tidak ada event khusus hari ini.")
