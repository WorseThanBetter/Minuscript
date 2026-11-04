#Game Manager
extends Node

signal puzzle_found(puzzle)

var word_dict: Dictionary = {"test": "test"}

func word_input(word: String) -> Node3D:
	print("Player inputted: " + word)
	if (word_dict.get(word)):
		print("Puzzle found!")
	puzzle_found.emit(word_dict.get(word))
	return null
	
