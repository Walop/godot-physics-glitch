extends CharacterBody3D

const MAX_SPEED = 5.0
const ACCELERATION = 40.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.005
const CROUCH_DURATION = 0.2

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")

@onready var Camera = $Camera3D
@onready var CameraOriginalY: float = $Camera3D.position.y

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)

func _physics_process(delta):
	apply_gravity(delta)
	move(delta)

	move_and_slide()

func apply_gravity(delta):
	if is_on_floor() and not Input.is_action_just_pressed("jump"):
		velocity.y = 0
		return
	
	velocity.y -= gravity * delta

func move(delta):
	var input_dir := Input.get_vector("left", "right", "forward", "back")
	var direction := (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = move_toward(velocity.x, direction.x * MAX_SPEED, ACCELERATION * delta)
		velocity.z = move_toward(velocity.z, direction.z * MAX_SPEED, ACCELERATION * delta)
	else:
		velocity.x = move_toward(velocity.x, 0, ACCELERATION * 1.5 * delta)
		velocity.z = move_toward(velocity.z, 0, ACCELERATION * 1.5 * delta)

func _input(event):
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		rotate_y(-event.relative.x * MOUSE_SENSITIVITY)
		Camera.rotate_x(-event.relative.y * MOUSE_SENSITIVITY)
		Camera.rotation.x = clampf(Camera.rotation.x, -PI/2.0, PI/2.0)
		
	if event.is_action_pressed("ui_cancel"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			get_tree().quit()
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		
	if event.is_action_pressed("click"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	if event.is_action_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
