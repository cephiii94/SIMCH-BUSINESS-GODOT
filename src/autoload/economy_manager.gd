extends Node

## Mengelola keuangan kas pemain, pencatatan transaksi, dan laporan harian.

enum ExpenseType {
	COGS,          # Harga pokok pembelian barang grosir
	WAGES,         # Gaji karyawan
	RENT_UTILITY,  # Sewa gedung & listrik/air
	INVESTMENT     # Biaya modal satu kali (rak/upgrade)
}

const DAILY_RENT_COST: float = 100.0
const DAILY_UTILITY_COST: float = 50.0

var cash: float = 10000.00

# Buku kas harian saat ini
var current_income: float = 0.0
var current_cogs: float = 0.0
var current_wages: float = 0.0
var current_rent_maintenance: float = 0.0
var current_expense: float = 0.0

# Riwayat Laporan Keuangan Harian
var daily_reports: Array[Dictionary] = []

var _last_tracked_day: int = 1

func _ready() -> void:
	# Tunggu satu frame agar UI ter-inisialisasi
	await get_tree().process_frame
	EventBus.money_changed.emit(cash)
	
	# Hubungkan sinyal perubahan waktu untuk mendeteksi akhir hari
	EventBus.time_tick.connect(_on_time_tick)
	
	if TimeManager:
		_last_tracked_day = TimeManager.day

func _unhandled_input(event: InputEvent) -> void:
	# Shortcut keyboard untuk mensimulasikan transaksi (debugging/verifikasi)
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_I:
			record_income(150.0)
		elif event.keycode == KEY_O:
			record_expense(75.0, ExpenseType.COGS)

## Mencatat pendapatan masuk (penjualan ritel).
func record_income(amount: float) -> void:
	cash += amount
	current_income += amount
	EventBus.money_changed.emit(cash)

## Mencatat pengeluaran keluar (distributor, gaji, sewa).
func record_expense(amount: float, type: ExpenseType) -> void:
	cash -= amount
	current_expense += amount
	
	match type:
		ExpenseType.COGS:
			current_cogs += amount
		ExpenseType.WAGES:
			current_wages += amount
		ExpenseType.RENT_UTILITY:
			current_rent_maintenance += amount
			
	EventBus.money_changed.emit(cash)

func _on_time_tick(day: int, _hour: int, _minute: int) -> void:
	# Jika hari bertambah
	if day > _last_tracked_day:
		_on_day_ended(_last_tracked_day)
		_last_tracked_day = day

func _on_day_ended(day_index: int) -> void:
	# 1. Hitung dan catat gaji karyawan aktif
	var total_wages: float = 0.0
	var staff_mgr: Node = get_node_or_null("/root/StaffManager")
	if staff_mgr:
		for staff in staff_mgr.hired_staff:
			total_wages += staff["daily_wage"]
	if total_wages > 0.0:
		record_expense(total_wages, ExpenseType.WAGES)

	# 2. Catat biaya tetap sewa dan utilitas di akhir hari
	record_expense(DAILY_RENT_COST, ExpenseType.RENT_UTILITY)
	record_expense(DAILY_UTILITY_COST, ExpenseType.RENT_UTILITY)
	
	# 2. Hitung Laba Bersih
	var net_profit: float = current_income - current_expense
	
	# 3. Bentuk data laporan keuangan harian
	var report: Dictionary = {
		"day": day_index,
		"income": current_income,
		"cogs": current_cogs,
		"wages": current_wages,
		"rent_utilities": current_rent_maintenance,
		"expense": current_expense,
		"profit": net_profit
	}
	
	# 4. Simpan ke riwayat dan pancarkan sinyal global
	daily_reports.append(report)
	EventBus.daily_report_generated.emit(report)
	
	# 5. Reset pembukuan harian untuk hari berikutnya
	current_income = 0.0
	current_cogs = 0.0
	current_wages = 0.0
	current_rent_maintenance = 0.0
	current_expense = 0.0
	
	# 6. Reset energi dan produktivitas harian karyawan
	var staff_mgr: Node = get_node_or_null("/root/StaffManager")
	if staff_mgr:
		staff_mgr.reset_daily_stats()

