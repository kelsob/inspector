extends Node3D

var object_scene_1 : PackedScene = preload('res://Scenes/InspectionObjects/boombox.tscn')
var object_scene_2 : PackedScene = preload('res://Scenes/InspectionObjects/cashregister.tscn')
var object_scene_3 : PackedScene = preload('res://Scenes/InspectionObjects/securitycamera.tscn')

var objects : Array = [
	object_scene_1,
 	object_scene_2,
 	object_scene_3
]

var used_objects : Array = []

var current_object = null

func instantiate_next_object():
	if current_object != null:
		current_object.queue_free()
	
	var object = objects.pop_front().instantiate()
	used_objects.append(object)
	add_child(object)
	current_object = object
