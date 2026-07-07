extends Node

# Sinyal Siklus Waktu
signal time_tick(day: int, hour: int, minute: int)

# Sinyal Ekonomi
signal money_changed(new_balance: float)

# Sinyal Inventaris / Stok
signal stock_updated(item_id: String, new_count: int)

# Sinyal Pelayanan Pelanggan
signal customer_served(revenue: float)

# Sinyal Alur Game (Sprint 4)
signal game_started
signal game_exited

# Sinyal Laporan Keuangan (Sprint 8)
signal daily_report_generated(report: Dictionary)

# Sinyal Pencapaian / Achievement (Sprint 19)
signal achievement_unlocked(achievement_id: String, title: String, reward_desc: String)
