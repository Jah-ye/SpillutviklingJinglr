extends CharacterBody2D

class_name	pickup

@export var node_types : Array[pickup]
@export var starting_resources : int = 0
@export var pickup_type : PackedScene

var current_resources : int:
	set(value):
		if(value <= 0):
			queue_free()
			
func _ready():
	current_resources = starting_resources
	
func pickup(amount : int): 
	print("picked up gift!")
	current_resources += amount
