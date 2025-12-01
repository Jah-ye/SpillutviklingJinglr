extends TextureRect

@onready var main_menu = load("res://main_menu.tscn")

func _on_button_button_up() -> void:
	get_tree().change_scene_to_packed(main_menu)
