extends Button


@export var target_scene: String = "res://SCENE1.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	connect("pressed", Callable(self, "_on_button_pressed"))

func _on_button_pressed() -> void:
	var err = get_tree().change_scene_to_file(target_scene)
	if err != OK:
		push_error("Failed to change scene to '%s' (error code: %s)" % [target_scene, str(err)])
