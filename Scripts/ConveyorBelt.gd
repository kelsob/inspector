extends Node3D

@onready var roller = $Rollers
@onready var belt = $BeltSegments

func turn_on(displacement_param):
	belt.turn_on(displacement_param)
	roller.turn_on(belt.acceleration_time, belt.delta_turn_off)
