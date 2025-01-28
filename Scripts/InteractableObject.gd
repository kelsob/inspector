extends Node
class_name InteractableObject

signal interacted()

func player_interacted():
	interacted.emit()
