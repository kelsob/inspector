extends Node3D

@onready var camera = $Camera3D

var SENSITIVITY : float = 0.005

func receive_joystick_input(event):
	rotate_y(-event.relative.x * SENSITIVITY)
	camera.rotate_x(-event.relative.y * SENSITIVITY)
	camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-50), deg_to_rad(50))
