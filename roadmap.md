# 🎮 SimCH Business Roadmap
> Engine: Godot 4.x
> Language: GDScript
> Goal: Build a playable MVP first, then expand gradually.

---

# Phase 0 — Project Foundation

## Sprint 1 — Project Setup

### Objective
Membangun pondasi proyek agar rapi, scalable, dan mudah dikembangkan.

### Tasks
- [x] Membuat repository Git
- [x] Membuat project Godot 4
- [x] Menyiapkan struktur folder
- [x] Membuat README.md
- [x] Membuat LICENSE
- [x] Membuat .gitignore
- [x] Menyiapkan folder docs
- [x] Menentukan coding convention
- [x] Menentukan naming convention
- [x] Commit pertama

### Deliverables
- Project dapat dibuka di Godot
- Struktur folder selesai
- Git siap digunakan

---

## Sprint 2 — Game Design Document

### Objective
Menentukan seluruh konsep game sebelum mulai coding.

### Tasks
- [x] Vision.md
- [x] Gameplay.md
- [x] Core Loop.md
- [x] Economy.md
- [x] Buildings.md
- [x] Items.md
- [x] Employees.md
- [x] UI Flow.md

### Deliverables
Semua gameplay utama sudah terdokumentasi.

---

## Sprint 3 — Architecture

### Objective
Merancang struktur teknis game.

### Tasks
- [x] Menentukan Scene Tree
- [x] Menentukan Folder Script
- [x] Menentukan Singleton (Autoload)
- [x] Menentukan Data Structure
- [x] Menentukan Resource Structure
- [x] Menentukan Save Structure

### Deliverables
Blueprint arsitektur proyek selesai.

---

# Phase 1 — Prototype

## Sprint 4 — Main Menu

### Tasks
- [x] Main Menu
- [x] New Game
- [x] Continue
- [x] Settings
- [x] Exit

---

## Sprint 5 — Game World

### Tasks
- [x] World Scene
- [x] Camera
- [x] Player Spawn
- [x] UI dasar

---

## Sprint 6 — Camera System

### Tasks
- [x] Zoom
- [x] Drag
- [x] Camera Limits
- [x] Smooth Movement

---

## Sprint 7 — Time System

### Tasks
- [x] Hari
- [x] Jam
- [x] Menit
- [x] Pause
- [x] Fast Forward

---

# Phase 2 — Core Systems (MVP)

## Sprint 8 — Economy System

### Tasks
- [x] Money
- [x] Income
- [x] Expense
- [x] Profit

---

## Sprint 9 — Inventory System

### Tasks
- [x] Item Database
- [x] Inventory
- [x] Stock
- [x] Capacity

---

## Sprint 10 — Warehouse

### Tasks
- [x] Warehouse Scene
- [x] Item Storage
- [x] Receive Goods
- [x] Dispatch Goods

---

## Sprint 11 — Shop System

### Tasks
- [x] Membeli Barang
- [x] Menjual Barang
- [x] Harga
- [x] Keuntungan

---

## Sprint 12 — Customer System

### Tasks
- [x] Customer Spawning
- [x] Customer AI
- [x] Shopping Behavior
- [x] Payment

---

## Sprint 13 — Employee System

### Tasks
- [x] Hire Employee
- [x] Salary
- [x] Productivity

---

## Sprint 14 — Save & Load

### Tasks
- [x] Save
- [x] Load
- [x] Auto Save

---

# Phase 3 — Gameplay Expansion

## Sprint 15 — Building System

- [x] Bangun Gedung
- [x] Upgrade Gedung
- [x] Destroy

---

## Sprint 16 — Business Expansion

- [x] Skipped (Dilewati untuk fokus 1 toko tunggal)

---

## Sprint 17 — Logistics

- [x] Skipped (Dilewati untuk fokus 1 toko tunggal)

---

## Sprint 18 — Random Events

- [x] Event System
- [x] Bonus
- [x] Disaster
- [x] Economy Changes

---

## Sprint 19 — Achievement

- [x] Achievement
- [x] Unlock Reward


---

## Sprint 20 — Statistics

- [x] Revenue Graph
- [x] Business Report
- [x] Employee Report


---

# Phase 4 — Polish

## Sprint 21

Audio
- [x] Music
- [x] SFX
- [x] Ambient


---

## Sprint 22

Animation
- [ ] UI Animation
- [ ] Building Animation
- [ ] Customer Animation

---

## Sprint 23

Optimization
- [ ] Performance
- [ ] Memory
- [ ] Loading

---

## Sprint 24

Balancing
- [ ] Economy
- [ ] Progression
- [ ] Difficulty

---

# Phase 5 — Release

## Sprint 25

Testing
- [ ] Bug Fix
- [ ] Playtest
- [ ] Feedback

---

## Sprint 26

Release Candidate
- [ ] Export Windows
- [ ] Export Android
- [ ] Export Web (HTML5)
- [ ] Versioning

---

## Sprint 27

Release

- [ ] MVP v1.0
- [ ] Changelog
- [ ] Publish

---

# Future Roadmap

Setelah MVP selesai, proyek dapat dikembangkan dengan fitur-fitur berikut:

- Multiplayer
- AI NPC
- Dynamic Economy
- Online Market
- Mod Support
- Steam Workshop
- Procedural City
- Story Mode
- Co-op Mode
- Dedicated Server
- DLC System

---

# Development Rules

- Selesaikan satu sprint sebelum pindah ke sprint berikutnya.
- Jangan mengembangkan fitur di luar sprint aktif.
- Semua sistem harus modular.
- Semua kode harus mudah dibaca.
- Hindari overengineering.
- Dokumentasikan perubahan penting.
- Commit Git secara berkala dengan pesan yang jelas.
- Prioritaskan gameplay yang dapat dimainkan daripada fitur yang terlalu kompleks.

---

# MVP Target

Pada akhir Sprint 27, pemain sudah dapat:

✅ Memulai permainan baru  
✅ Mengelola uang  
✅ Mengelola gudang  
✅ Membeli dan menjual barang  
✅ Mempekerjakan karyawan  
✅ Menyimpan dan memuat progres permainan  
✅ Menjalankan bisnis sederhana dari awal hingga menghasilkan keuntungan