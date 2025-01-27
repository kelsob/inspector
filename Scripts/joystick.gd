extends Node3D

var default_rotation_deg: Vector3  # Stores the default rotation of the joystick
@export var max_rotation_deg: float = 10.0  # Maximum allowed rotation in degrees
@export var return_speed: float = 2.0  # Speed at which the joystick returns to the center

func _ready():
	# Save the default rotation of the joystick
	default_rotation_deg = rotation_degrees

func _process(delta):
	# Gradually return to the default rotation
	return_to_default(delta)

func receive_joystick_input(event: InputEventMouseMotion):
	# Translate mouse motion to joystick rotation
	var rotation_change_x = event.relative.y * 0.1  # Mouse Y affects X rotation
	var rotation_change_y = event.relative.x * 0.1  # Mouse X affects Y rotation

	# Update joystick rotation, clamping within the allowed range
	rotation_degrees.x = clamp(
		rotation_degrees.x + rotation_change_x,
		default_rotation_deg.x - max_rotation_deg,
		default_rotation_deg.x + max_rotation_deg
	)

	rotation_degrees.y = clamp(
		rotation_degrees.y + rotation_change_y,
		default_rotation_deg.y - max_rotation_deg,
		default_rotation_deg.y + max_rotation_deg
	)

func return_to_default(delta):
	# Gradually return X and Y rotations to their default values
	rotation_degrees.x = lerp(rotation_degrees.x, default_rotation_deg.x, return_speed * delta)
	rotation_degrees.y = lerp(rotation_degrees.y, default_rotation_deg.y, return_speed * delta)
