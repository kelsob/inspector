extends Node3D

@onready var button_left = $controlpanel/ControlPanel/ButtonLeft/Cube3
@onready var button_right = $controlpanel/ControlPanel/ButtonRight/Cube2
@onready var anim = $controlpanel/AnimationPlayer

# Path to the script you want to attach to the buttons
const INTERACTABLE_SCRIPT_PATH = "res://scripts/Interactable.gd"

signal left_button_pressed()
signal right_button_pressed()

func _ready():
	# Load the Interactable script
	var interactable_script = load(INTERACTABLE_SCRIPT_PATH)
	if not interactable_script:
		print("Failed to load Interactable script!")
		return

	# Add the script to both buttons
	button_left.set_script(interactable_script)
	button_right.set_script(interactable_script)

	# Connect their signals to specific functions
	button_left.interacted.connect(Callable(self, '_on_button_left_interacted'))
	button_right.interacted.connect(Callable(self, '_on_button_right_interacted'))
	
	# Add buttons to interactables group, allows for player to check for object interaction simply.
	button_left.add_to_group('interactables')
	button_right.add_to_group('interactables')

# Define the interaction functions
func _on_button_left_interacted():
	anim.play('ButtonMobileAction')
	left_button_pressed.emit()

func _on_button_right_interacted():
	anim.play('ButtonMobileAction_002')
	right_button_pressed.emit()
