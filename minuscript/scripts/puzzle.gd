class_name Puzzle
extends Node

@export var solution: String

func _ready() -> void:
	GM.word_dict[solution.to_lower()] = self
	
func destroy(Node):
	queue_free()
	
