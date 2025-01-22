extends Node3D

@onready var control_panel: Node = $ControlPanel
@onready var conveyor_belt: Node = $ConveyorBelt
@onready var inspection_object : Node = $InspectionObject

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

func _on_control_panel_left_button_pressed() -> void:
	match current_state:
		State.WAITING_FOR_INPUT:
			start_conveyor_belt()
		State.INSPECTION_MODE:
			accept_object()

func _on_control_panel_right_button_pressed() -> void:
	if current_state == State.INSPECTION_MODE:
		reject_object()

func start_conveyor_belt() -> void:
	current_state = State.CONVEYOR_ACTIVE
	conveyor_belt.turn_on(31.0)
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
