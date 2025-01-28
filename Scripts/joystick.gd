extends Node3D

@export var max_rotation_deg: float = 16.0  # Maximum allowed displacement from center
@export var return_speed: float = 2.0  # Speed at which the joystick returns to center
@onready var joystick_rot = $joystick


func _process(delta):
	# Gradually return to the default rotation
	pass
	#return_to_default(delta)

func receive_joystick_input(event: InputEventMouseMotion):
	# Translate mouse motion to joystick rotation
	var rotation_change_x = event.relative.y * 0.1  # Mouse Y affects X rotation
	var rotation_change_z = event.relative.x * 0.1  # Mouse X affects Y rotation
	# Calculate the new rotation offset from the default
	var offset_x = joystick_rot.rotation_degrees.x + rotation_change_x
	var offset_z = joystick_rot.rotation_degrees.z - rotation_change_z

	var magnitude = sqrt(offset_x * offset_x + offset_z * offset_z)
	# If the magnitude exceeds the maximum radius, clamp it
	if magnitude > max_rotation_deg:
		var new_scale = max_rotation_deg / magnitude
		offset_x *= new_scale
		offset_z *= new_scale

	# Apply the clamped offsets back to rotation
	joystick_rot.rotation_degrees.x = offset_x
	joystick_rot.rotation_degrees.z = offset_z


func return_to_default(delta):
	# Calculate the difference between current and default rotation
	var offset_x = rotation_degrees.x
	var offset_z = rotation_degrees.z

	# Gradually reduce the offset back to zero
	var return_factor = exp(-return_speed * delta)  # Exponential decay for smoothness
	offset_x *= return_factor
	offset_z *= return_factor

	# Apply the offsets back to the rotation
	rotation_degrees.x = offset_x
	rotation_degrees.z =  offset_z
