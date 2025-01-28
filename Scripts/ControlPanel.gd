extends Node3D

@onready var button_left = $controlpanel/ControlPanel/ButtonLeft/Cube3
@onready var button_right = $controlpanel/ControlPanel/ButtonRight/Cube2
@onready var joystick = $Joystick
@onready var joystick_interactable = $Joystick/joystick/Joystick/Cube7
@onready var button_rect_left_interactable = $buttonrectangular/buttonrectangular/Button/Cube8
@onready var button_rect_right_interactable = $buttonrectangular2/buttonrectangular/Button/Cube8
@onready var button_rect_left = $buttonrectangular
@onready var button_rect_right = $buttonrectangular2
@onready var anim = $controlpanel/AnimationPlayer

# Path to the script you want to attach to the buttons
const INTERACTABLE_SCRIPT_PATH = "res://Scripts/InteractableObject.gd"

var joystick_default_rotation_deg : Vector3 = Vector3(25,0,0)

signal left_button_pressed()
signal right_button_pressed()
signal left_rect_button_pressed()
signal right_right_button_pressed()
signal joystick_interacted()

func _ready():
	# Load the Interactable script
	var interactable_script = load(INTERACTABLE_SCRIPT_PATH)
	if not interactable_script:
		print("Failed to load Interactable script!")
		return

	# Add the script to both buttons
	button_left.set_script(interactable_script)
	button_right.set_script(interactable_script)
	joystick_interactable.set_script(interactable_script)
	button_rect_left_interactable.set_script(interactable_script)
	button_rect_right_interactable.set_script(interactable_script)

	# Connect their signals to specific functions
	button_left.interacted.connect(Callable(self, '_on_button_left_interacted'))
	button_right.interacted.connect(Callable(self, '_on_button_right_interacted'))
	joystick_interactable.interacted.connect(Callable(self, '_on_joystick_interacted'))
	button_rect_left_interactable.interacted.connect(Callable(self, '_on_button_rect_left_interacted'))
	button_rect_right_interactable.interacted.connect(Callable(self, '_on_button_rect_right_interacted'))
	
	# Add buttons to interactables group, allows for player to check for object interaction simply.
	button_left.add_to_group('interactables')
	button_right.add_to_group('interactables')
	joystick_interactable.add_to_group('interactables')
	button_rect_left_interactable.add_to_group('interactables')
	button_rect_right_interactable.add_to_group('interactables')

# Define the interaction functions
func _on_button_left_interacted():
	anim.play('ButtonMobileAction')
	left_button_pressed.emit()

func _on_button_right_interacted():
	anim.play('ButtonMobileAction_002')
	right_button_pressed.emit()

func _on_joystick_interacted():
	joystick_interacted.emit()

func receive_joystick_input(event):
	joystick.receive_joystick_input(event)

func _on_button_rect_left_interacted():
	button_rect_left.pressed()

func _on_button_rect_right_interacted():
	button_rect_right.pressed()
