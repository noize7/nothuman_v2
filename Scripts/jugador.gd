extends CharacterBody3D

@export var walk_speed := 4.0
@export var sprint_speed := 10.0
@export var acceleration := 8.0
@export var deceleration := 10.0
@export var jump_velocity := 4.5
@export var mouse_sensitivity := 0.12

var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var camera_pivot = $PivoteCamara
@onready var camera = $PivoteCamara/CamaraJugador

var current_speed = 0.0
var bob_time = 0.0

func _ready():
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event):

	if event is InputEventMouseMotion:
		rotation_degrees.y -= event.relative.x * mouse_sensitivity

		camera_pivot.rotation_degrees.x -= event.relative.y * mouse_sensitivity
		camera_pivot.rotation_degrees.x = clamp(
			camera_pivot.rotation_degrees.x,
			-80,
			80
		)

	if event.is_action_pressed("ui_cancel"):
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func _physics_process(delta):

	# Gravedad
	if not is_on_floor():
		velocity.y -= gravity * delta


	# Movimiento
	var input_dir := Input.get_vector(
		"move_left",
		"move_right",
		"move_forward",
		"move_back"
	)

	var direction := (
		transform.basis *
		Vector3(input_dir.x, 0, input_dir.y)
	).normalized()

	var target_speed = walk_speed

	if Input.is_action_pressed("sprint"):
		target_speed = sprint_speed
		
	if direction:

		var target_velocity = direction * target_speed

		velocity.x = move_toward(
			velocity.x,
			target_velocity.x,
			acceleration * delta
		)

		velocity.z = move_toward(
			velocity.z,
			target_velocity.z,
			acceleration * delta
		)

	else:

		velocity.x = move_toward(
			velocity.x,
			0.0,
			deceleration * delta
		)

		velocity.z = move_toward(
			velocity.z,
			0.0,
			deceleration * delta
		)

	move_and_slide()

	_head_bob(delta)


func _head_bob(delta):

	var horizontal_velocity = Vector2(
		velocity.x,
		velocity.z
	).length()

	if is_on_floor() and horizontal_velocity > 0.1:

		bob_time += delta * 8.0

		camera.position.y = lerp(
			camera.position.y,
			0.05 + sin(bob_time * 2.0) * 0.03,
			delta * 10.0
		)

		camera.rotation.z = lerp(
			camera.rotation.z,
			sin(bob_time) * 0.015,
			delta * 10.0
		)

	else:

		camera.position.y = lerp(
			camera.position.y,
			0.0,
			delta * 8.0
		)

		camera.rotation.z = lerp(
			camera.rotation.z,
			0.0,
			delta * 8.0
		)
