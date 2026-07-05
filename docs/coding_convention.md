# GDScript Naming & Coding Conventions

To keep the codebase of **SimCH Business** clean, readable, and highly modular, all contributors must follow these coding conventions.

---

## 1. Naming Conventions

We adhere to the official [GDScript style guide](https://docs.godotengine.org/en/stable/tutorials/scripting/gdscript/gdscript_styleguide.html).

### Files and Directories
* Use `snake_case` for all folder names and file names (e.g., `src/ui/main_menu.tscn`, `src/autoload/time_manager.gd`).

### Classes and Nodes
* Use `PascalCase` for class names and node names in the Scene Tree (e.g., `class_name GameManager`, `node_name MainMenu`).

### Variables and Functions
* Use `snake_case` for all variable and function names (e.g., `var current_gold: int = 0`, `func update_balance() -> void`).
* Prefix private or local-only variables/functions with a leading underscore (e.g., `var _local_cache: Dictionary`, `func _check_internal_status() -> void`).

### Constants
* Use `UPPER_SNAKE_CASE` (e.g., `const MAX_EMPLOYEES: int = 10`).

### Signals
* Use `snake_case` in the past tense or describing the action (e.g., `signal game_started`, `signal item_purchased(item_id: String)`).

---

## 2. Coding Standards

### Strict Static Typing
* Always use explicit type hints for variables, function parameters, and return values. This ensures safety, better autocompletion, and performance.
  ```gdscript
  # Good
  var total_price: float = 0.0
  func calculate_tax(amount: float) -> float:
      return amount * 0.1
      
  # Bad
  var total_price = 0.0
  func calculate_tax(amount):
      return amount * 0.1
  ```

### Onready Variables
* Use the `@onready` annotation for node references.
  ```gdscript
  @onready var label: Label = $Label
  ```

### Order of Script Content
Organize class members in this order:
1. `class_name`
2. `extends`
3. Docstring/Description
4. Signals
5. Enums
6. Constants
7. Export variables (`@export`)
8. Public/private variables
9. `@onready` variables
10. Optional `_init()` and `_ready()` functions
11. Built-in virtual functions (`_process()`, `_input()`, etc.)
12. Public functions
13. Private/internal functions

---

## 3. Comments and Documentation
* **Minimal and Meaningful**: Write comments explaining *why* something is done, not *what* is done. Do not write self-explanatory comments.
  ```gdscript
  # Good
  # Adjust tax rate based on active inflation modifier.
  var adjusted_rate: float = base_rate * inflation
  
  # Bad
  # Initialize integer variable current_level
  var current_level: int = 1
  ```
