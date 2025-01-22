extends Node3D

@export var roller_scene: PackedScene  = preload("res://Assets/BlenderFiles/roller.glb")# The Roller scene to instantiate
@export var num_rollers: int = 64  # Number of rollers to create
@export var roller_spacing: float = 0.31746031746  # Spacing between each roller

@export var roller_max_speed : float = 20
@export var roller_acceleration : float = 40.0
@export var roller_deceleration : float = 40.0

const starting_roller_position : Vector3 = Vector3(10,-0.5,-2)
var current_speed : float = 0.0
var rng = RandomNumberGenerator.new()
var delta_accelerating : float = 0.0
var delta_running_at_max_speed : float = 0.0
var delta_turn_off : float = 0.0

enum State {
	ON,
	OFF
}

var current_state: State = State.OFF

func _ready():
	create_rollers()

func create_rollers():
	# Clear any existing children (optional, for safety)
	for child in get_children():
		child.queue_free()

	# Loop to instantiate and position rollers
	for i in range(num_rollers):
		var roller_instance = roller_scene.instantiate()  # Create an instance of the roller scene
		add_child(roller_instance)  # Add it as a child of this node

		# Calculate position based on spacing
		var new_position = Vector3(-i * roller_spacing, 0, 0) + starting_roller_position # Spread out along the X-axis
		roller_instance.position = new_position  # Set the roller's position
		roller_instance.rotation.z = rng.randf_range(0, 2*PI)

func turn_on(acceleration_time, time_at_max_speed):
	current_state = State.ON
	delta_turn_off = time_at_max_speed

func turn_off():
	current_state = State.OFF

func _process(delta):
	match current_state:
		State.OFF:
			if current_speed > 0:
				decelerate_rollers(delta)
				rotate_rollers()
				delta_accelerating += delta
				if current_speed == 0:
					location_arrived()

		State.ON:
			if current_speed < roller_max_speed:
				accelerate_rollers(delta)
				delta_accelerating += delta
			else:
				delta_running_at_max_speed += delta
				if delta_running_at_max_speed >= delta_turn_off:
					turn_off()
			rotate_rollers()

func location_arrived():
	delta_accelerating = 0.0
	delta_running_at_max_speed = 0.0
	delta_turn_off = 0.0

func accelerate_rollers(delta):
	current_speed = clamp(current_speed + delta * roller_acceleration, 0.0, roller_max_speed)

func decelerate_rollers(delta):
	current_speed = clamp(current_speed - delta * roller_deceleration, 0.0, roller_max_speed)

func rotate_rollers():
	for roller in get_children():
		roller.rotation.z += deg_to_rad(-current_speed)
