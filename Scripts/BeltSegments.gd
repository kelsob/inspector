extends Node3D


@export var belt_segment_scene: PackedScene  = preload("res://Scenes/BeltSegment.tscn")# The Roller scene to instantiate
@export var num_segments: int = 32  # Number of rollers to create
@export var segment_spacing: float = 2  # Spacing between each roller
@export var max_speed : float = 0.05
@export var acceleration : float = 0.1
@export var deceleration : float = 0.1

var starting_position : Vector3 = Vector3(0, -0.38, -2)
var current_speed : float = 0.0

var desired_displacement = 0.0
var acceleration_time = max_speed / acceleration
var acceleration_displacement = 0.5 * acceleration * 60 * pow(acceleration_time, 2)
var delta_turn_off = 0.0

var delta_running_at_max_speed = 0.0
var delta_accelerating = 0.0
var belt_displacement = 0.0

enum State {
	ON,
	OFF
}

var current_state: State = State.OFF

signal location_arrived()

func _ready():
	establish_starting_position()
	create_belt_segments()

func establish_starting_position():
	starting_position.x = -num_segments + 1

func create_belt_segments():
	# Clear any existing children (optional, for safety)
	for child in get_children():
		child.queue_free()
	
	# Loop to instantiate and position rollers
	for i in range(num_segments):
		var belt_segment_instance = belt_segment_scene.instantiate()  # Create an instance of the roller scene
		add_child(belt_segment_instance)  # Add it as a child of this node
		# Calculate position based on spacing
		belt_segment_instance.position.x = i * segment_spacing  # Set the roller's position
		belt_segment_instance.position += starting_position

func turn_on(displacement_param):
	desired_displacement = displacement_param
	recalculate_delta_turn_off()
	current_state = State.ON

func turn_off():
	current_state = State.OFF
	delta_running_at_max_speed = 0.0
	delta_accelerating = 0.0
	
func _process(delta):
	match current_state:
		State.OFF:
			if current_speed > 0:
				decelerate_belt(delta)
				move_belt()
				delta_accelerating += delta
				if current_speed == 0.0:
					belt_location_arrived()

		State.ON:
			if current_speed < max_speed:
				accelerate_belt(delta)
				delta_accelerating += delta
				if current_speed >= max_speed:
					recalculate_delta_turn_off()
			else:
				delta_running_at_max_speed += delta
				if delta_running_at_max_speed >= delta_turn_off:
					turn_off()
			move_belt()

func accelerate_belt(delta):
	current_speed = clamp(current_speed + delta * acceleration, 0.0, max_speed)

func decelerate_belt(delta):
	current_speed = clamp(current_speed - delta * deceleration, 0.0, max_speed)

func move_belt():
	var displacement_actual = belt_displacement
	belt_displacement = clamp(current_speed + belt_displacement, 0, desired_displacement)
	displacement_actual = belt_displacement - displacement_actual
	
	var objects_on_belt = []
	for belt in get_children():
		objects_on_belt.append_array(belt.get_connected_bodies())
		belt.position.x += displacement_actual
		if belt.position.x >= num_segments:
			belt.position.x -= num_segments * 2
	var unique_objects_on_belt = []
	for object in objects_on_belt:
		if not unique_objects_on_belt.has(object):
			unique_objects_on_belt.append(object)
	for object in unique_objects_on_belt:
		if object is RigidBody3D:
			object.position.x += displacement_actual

func belt_location_arrived():
	belt_displacement = 0.0
	location_arrived.emit()

func recalculate_delta_turn_off():
	delta_turn_off = (desired_displacement - (2 * acceleration_displacement)) / (max_speed * 60)
