extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const SENSITIVITY = 0.005

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var camera_control_enabled: bool = true
var joystick_mode_active: bool = false
var panning_to_joystick: bool = false
var target_joystick_rotation: Vector3 = Vector3(0, 0, 0)  # Desired rotation for the camera
@export var pan_speed: float = 2.0  # Speed of the camera panning

@onready var head = $Head
@onready var camera = $Head/Camera3D

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _unhandled_input(event):
	if !camera_control_enabled: return
	if event is InputEventMouseMotion:
		rotate_y(-event.relative.x * SENSITIVITY)
		camera.rotate_x(-event.relative.y * SENSITIVITY)
		camera.rotation.x = clamp(camera.rotation.x, deg_to_rad(-50), deg_to_rad(50))
	elif event is InputEventMouseButton and event.pressed and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		interact_with_object()

func interact_with_object():
	var space_state = get_world_3d().direct_space_state
	var params = PhysicsRayQueryParameters3D.new()
	params.from = camera.global_transform.origin
	params.to = camera.global_transform.origin + camera.global_transform.basis.z * -10
	params.exclude = []
	params.collision_mask = 1
	var result = space_state.intersect_ray(params)
	if result:
		if get_tree().get_nodes_in_group("interactables").has(result.collider):
			result.collider.player_interacted()

func _physics_process(delta):
	# Add the gravity.
	if not is_on_floor():
		velocity.y -= gravity * delta

	if panning_to_joystick:
		pan_camera_to_joystick(delta)
	
	if !camera_control_enabled: return

	# Handle Jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	var input_dir = Input.get_vector("move_a", "move_d", "move_w", "move_s")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = 0.0
		velocity.z = 0.0

	move_and_slide()


func enter_joystick_mode():
	camera_control_enabled = false
	joystick_mode_active = true
	panning_to_joystick = true  # Begin panning to joystick view
	# Set your target rotation for the joystick angle (adjust as needed)
	target_joystick_rotation = Vector3(deg_to_rad(-20), deg_to_rad(-5), 0)  # Example: tilt down and look right

func exit_joystick_mode():
	camera_control_enabled = true
	joystick_mode_active = false
	panning_to_joystick = false  # Stop panning if exiting prematurely

func pan_camera_to_joystick(delta):
	# Smoothly interpolate the camera rotation to the target rotatio
	rotation.y = lerp(rotation.y, target_joystick_rotation.y, pan_speed * delta)
	camera.rotation.x = lerp(camera.rotation.x, target_joystick_rotation.x, pan_speed * delta)

	# Check if the camera is close enough to the target rotation to stop panning
	if camera.rotation.distance_to(target_joystick_rotation) < 0.01:
		panning_to_joystick = false  # Stop panning when close enough
