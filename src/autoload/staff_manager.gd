extends Node

## Mengelola rekrutmen karyawan aktif dan daftar pelamar di bursa kerja.

signal staff_list_changed

var hired_staff: Array = []
var applicants: Array = []

func _ready() -> void:
	# Buat pelamar awal
	_generate_applicants()

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
			"energy": 100.0
		},
		{
			"id": "staff_siti",
			"name": "Siti Aminah",
			"role": "Cashier",
			"speed": 1.15,
			"daily_wage": 45.00,
			"hire_cost": 90.00,
			"energy": 100.0
		},
		{
			"id": "staff_agus",
			"name": "Agus Pratama",
			"role": "Stocker",
			"speed": 1.45,
			"daily_wage": 65.00,
			"hire_cost": 120.00,
			"energy": 100.0
		}
	]

## Mempekerjakan karyawan baru. Mengembalikan true jika saldo cukup.
func hire_employee(applicant_idx: int) -> bool:
	if applicant_idx < 0 or applicant_idx >= applicants.size():
		return false
		
	var applicant: Dictionary = applicants[applicant_idx]
	if EconomyManager and EconomyManager.cash >= applicant["hire_cost"]:
		EconomyManager.record_expense(applicant["hire_cost"], EconomyManager.ExpenseType.INVESTMENT)
		
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
