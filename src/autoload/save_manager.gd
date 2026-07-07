extends Node

const SAVE_PATH: String = "user://save_game.json"

## Mengecek apakah file save game ada.
func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_PATH)
