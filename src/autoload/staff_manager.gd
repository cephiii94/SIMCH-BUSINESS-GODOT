extends Node

## Mengelola rekrutmen karyawan aktif dan daftar pelamar di bursa kerja.

signal staff_list_changed

var hired_staff: Array = []
var applicants: Array = []

func _ready() -> void:
	# Buat pelamar awal
	_generate_applicants()
	EventBus.day_started.connect(reset_daily_stats)

## Menghasilkan daftar pelamar baru secara acak
func _generate_applicants() -> void:
	applicants = [
		{
			"id": "staff_budy",
			"name": "Budi Setiawan",
			"role": "Stocker",
			"speed": 1.30,
			"daily_wage": 55.00,
			"hire_cost": 100.00,
			"energy": 100.0,
			"productivity": 0
		},
		{
			"id": "staff_siti",
			"name": "Siti Aminah",
			"role": "Cashier",
			"speed": 1.15,
			"daily_wage": 45.00,
			"hire_cost": 90.00,
			"energy": 100.0,
			"productivity": 0
		},
		{
			"id": "staff_agus",
			"name": "Agus Pratama",
			"role": "Stocker",
			"speed": 1.45,
			"daily_wage": 65.00,
			"hire_cost": 120.00,
			"energy": 100.0,
			"productivity": 0
		}
	]

## Mempekerjakan karyawan baru. Mengembalikan true jika saldo cukup.
func hire_employee(applicant_idx: int) -> bool:
	if applicant_idx < 0 or applicant_idx >= applicants.size():
		return false
		
	var applicant: Dictionary = applicants[applicant_idx]
	if EconomyManager and EconomyManager.cash >= applicant["hire_cost"]:
		EconomyManager.record_expense(applicant["hire_cost"], EconomyManager.ExpenseType.INVESTMENT)
		
		# Pastikan default nilai produktivitas ada
		if not applicant.has("productivity"):
			applicant["productivity"] = 0
		
		# Pindahkan dari pelamar ke karyawan aktif
		hired_staff.append(applicant)
		applicants.remove_at(applicant_idx)
		
		staff_list_changed.emit()
		return true
		
	return false

## Memecat karyawan aktif.
func fire_employee(staff_idx: int) -> void:
	if staff_idx < 0 or staff_idx >= hired_staff.size():
		return
		
	hired_staff.remove_at(staff_idx)
	staff_list_changed.emit()

## Mencatat kontribusi kerja dan mengurangi sisa energi karyawan aktif secara aman.
func record_staff_work(staff_id: String, work_done: int = 1, energy_lost: float = 2.0) -> void:
	for staff in hired_staff:
		if staff["id"] == staff_id:
			staff["energy"] = clamp(staff.get("energy", 100.0) - energy_lost, 0.0, 100.0)
			staff["productivity"] = staff.get("productivity", 0) + work_done
			staff_list_changed.emit()
			break

## Memulihkan sisa energi seluruh karyawan ke 100.0% dan mereset produktivitas harian saat pergantian hari.
func reset_daily_stats() -> void:
	for staff in hired_staff:
		staff["energy"] = 100.0
		staff["productivity"] = 0
		
	# Isi ulang pelamar jika kosong atau kurang dari 3
	if applicants.size() < 3:
		generate_random_applicants(3 - applicants.size())
		
	staff_list_changed.emit()

## Menghasilkan pelamar acak secara dinamis
func generate_random_applicants(count: int) -> void:
	var first_names = ["Joko", "Siti", "Budi", "Agus", "Dewi", "Eko", "Rian", "Sari", "Andi", "Mega", "Hadi", "Yuni", "Tono", "Rina"]
	var last_names = ["Setiawan", "Aminah", "Pratama", "Lestari", "Nugroho", "Saputra", "Wahyuni", "Hidayat", "Putri", "Kurniawan", "Sari", "Wijaya"]
	var roles = ["Cashier", "Stocker"]
	
	for i in range(count):
		var fname = first_names[randi() % first_names.size()]
		var lname = last_names[randi() % last_names.size()]
		var fullname = fname + " " + lname
		
		var role = roles[randi() % roles.size()]
		var speed = 0.0
		if role == "Cashier":
			speed = snapped(randf_range(1.0, 1.5), 0.05)
		else:
			speed = snapped(randf_range(1.0, 1.6), 0.05)
			
		var daily_wage = snapped(speed * 40.0 + randf_range(-5.0, 5.0), 0.05)
		var hire_cost = snapped(daily_wage * 1.8 + randf_range(-10.0, 10.0), 0.05)
		var staff_id = "staff_" + str(fullname.to_lower().replace(" ", "_")) + "_" + str(randi() % 1000)
		
		var applicant = {
			"id": staff_id,
			"name": fullname,
			"role": role,
			"speed": speed,
			"daily_wage": daily_wage,
			"hire_cost": hire_cost,
			"energy": 100.0,
			"productivity": 0
		}
		applicants.append(applicant)
