extends Control


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_start_pressed() -> void:
	print("Start pressed")


func _on_Options_2_pressed() -> void:
	print("Options pressed")


func _on_Exit_3_pressed() -> void:
	get_tree().quit() 
