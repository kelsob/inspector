extends Node

signal interacted()

func player_interacted():
	interacted.emit()
