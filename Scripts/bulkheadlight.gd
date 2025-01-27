extends Node3D

@export var flicker_intensity: float = 0.5  # Maximum flicker intensity (0 to 1)
@export var flicker_speed: float = 5.0  # How fast the flicker happens
@export var flicker_randomness: float = 0.5  # How random the flicker effect is (0 = consistent, 1 = chaotic)

var is_on: bool = false

@onready var lights = $Lights

func _ready():
	is_on = visible

func turn_on():
	is_on = true
	lights.visible = true

func turn_off():
	is_on = false
	lights.visible = false

func _process(delta: float):
	if is_on:
		apply_flicker(delta)

func apply_flicker(delta: float):
	for light in lights.get_children():
		# Create a flickering effect by modulating the light energy
		var base_intensity = 1.0  # Set the base intensity for the light
		var flicker = randf() * flicker_randomness * flicker_intensity
		var flicker_value = base_intensity - flicker + sin(flicker_speed * delta) * flicker_intensity

		# Ensure the intensity doesn't go below 0
		light.light_energy = max(0, flicker_value)
