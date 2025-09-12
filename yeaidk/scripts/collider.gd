extends Area2D

func _ready() -> void:
	add_to_group("groundTop")
	get_child(0).add_to_group("groundTop")
