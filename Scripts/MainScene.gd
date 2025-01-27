extends Node3D

@onready var control_panel: Node = $ControlPanel
@onready var conveyor_belt: Node = $ConveyorBelt
@onready var inspection_object : Node = $InspectionObject
@onready var light_g : Node = $Room/bulkheadlight2
@onready var light_r : Node = $Room/bulkheadlight1
@onready var player = $Player
@onready var inspection_room_camera = $SubViewport/InspectionRoomCamera

var joystick_mode: bool = false
enum State {
	WAITING_FOR_INPUT,
	CONVEYOR_ACTIVE,
	INSPECTION_MODE
}

var current_state: State = State.WAITING_FOR_INPUT
var current_object: Node = null

func _ready() -> void:
	connect_signals()
	inspection_object.instantiate_next_object()

func connect_signals() -> void:
	control_panel.connect("left_button_pressed", Callable(self, "_on_control_panel_left_button_pressed"))
	control_panel.connect("right_button_pressed", Callable(self, "_on_control_panel_right_button_pressed"))
	control_panel.connect("joystick_interacted", Callable(self, "_on_control_panel_joystick_interacted"))
	
func _on_control_panel_left_button_pressed() -> void:
	match current_state:
		State.WAITING_FOR_INPUT:
			start_conveyor_belt()
		State.INSPECTION_MODE:
			accept_object()

func _on_control_panel_right_button_pressed() -> void:
	if current_state == State.INSPECTION_MODE:
		reject_object()

func _on_control_panel_joystick_interacted():
	joystick_mode = not joystick_mode  # Toggle joystick mode
	if joystick_mode:
		enter_joystick_mode()
	else:
		exit_joystick_mode()

func enter_joystick_mode():
	print('joystick mode entered')
	player.enter_joystick_mode()
	joystick_mode = true

func exit_joystick_mode():
	print('joystick mode exited')
	player.exit_joystick_mode()
	joystick_mode = false


func _unhandled_input(event):
	if joystick_mode:
		if event is InputEventMouseMotion:
			inspection_room_camera.receive_joystick_input(event)
			control_panel.receive_joystick_input(event)
		elif event is InputEventMouseButton and event.pressed and event.button_index == MouseButton.MOUSE_BUTTON_RIGHT:
			exit_joystick_mode()


func start_conveyor_belt() -> void:
	current_state = State.CONVEYOR_ACTIVE
	light_g.turn_on()
	light_r.turn_off()
	conveyor_belt.turn_on(10.0)
	await conveyor_belt.location_arrived
	light_g.turn_off()
	light_r.turn_on()
	
	current_state = State.INSPECTION_MODE

func spawn_object() -> Node:
	var object_scene = load("res://path_to_your_object_scene.tscn")
	var new_object = object_scene.instantiate()
	$InspectionArea.add_child(new_object)  # Assuming you have an "InspectionArea" node
	return new_object

func accept_object() -> void:
	if current_object:
		current_object.queue_free()  # Or implement logic to move it forward
		current_object = null
	current_state = State.WAITING_FOR_INPUT

func reject_object() -> void:
	if current_object:
		$Incinerator.call("incinerate", current_object)  # Ensure the incinerator has an `incinerate` method
		current_object = null
	current_state = State.WAITING_FOR_INPUT
