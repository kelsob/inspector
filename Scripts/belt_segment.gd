extends StaticBody3D

@export var belt_speed: float = 0.1  # Speed of the conveyor belt
@export var movement_axis: Vector3 = Vector3(1, 0, 0)  # Movement direction of the belt (X-axis)

@onready var area = $Area3D

func get_connected_bodies():
	return area.get_overlapping_bodies()
	
