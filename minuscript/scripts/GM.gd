#Game Manager
extends Node

signal puzzle_found(puzzle: Puzzle)

var word_dict: Dictionary = {}

func word_input(word: String) -> void:
	var lower_word = word.to_lower()
	print("Player inputted: " + lower_word)
	if (word_dict.get(lower_word)):
		print("Puzzle found!")
		puzzle_found.emit(word_dict.get(lower_word))
	
