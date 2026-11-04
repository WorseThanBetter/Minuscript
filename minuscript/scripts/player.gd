extends CharacterBody3D

const PUSH_FORCE = 1
const SPEED = 5.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.15
const MOUSE_INVERT = 1 # -1 for inverted y



@export var neck_vertical: Node3D
@export var neck_horizontal: Node3D

@onready var camera: Camera3D = $neck_horizontal/neck_vertical/camera
@onready var line_edit: LineEdit = $Control/LineEdit
#@onready var raycast: RayCast3D = $neck_horizontal/neck_vertical/raycast

var camera_direction: Vector3 = Vector3.ZERO
var movement_frozen: bool = false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	GM.puzzle_found.connect(found_puzzle)
	

func _physics_process(delta: float) -> void:

	if Input.is_action_just_pressed("escape"):
		if Input.get_mouse_mode() == Input.MOUSE_MODE_VISIBLE:
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		else:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	if Input.is_action_just_pressed("write"):
		movement_frozen = !movement_frozen
		line_edit.grab_focus()

	# Add the gravity.

	if not is_on_floor():
		if velocity.y > 0 and Input.is_action_pressed("jump"):
				velocity += get_gravity() * delta
		else:
			velocity += get_gravity() * delta * 1.3
			
	#player input
	if (!movement_frozen):
		# Handle jump.
		if Input.is_action_just_pressed("jump") and is_on_floor():
			velocity.y = JUMP_VELOCITY
			

		# Get the input direction and handle the movement/deceleration.
		var input_dir := Input.get_vector("left", "right", "forward", "backward")
		var direction = (neck_horizontal.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
		if direction:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED/2)
			velocity.z = move_toward(velocity.z, 0, SPEED/2)

	move_and_slide()
			

	for i in get_slide_collision_count():
		var collision = get_slide_collision(i)
		var collider = collision.get_collider()
		#Box Pushing
		if collider is RigidBody3D and collider.is_in_group("Pushed"):
			# Apply an impulse at the collision point in the opposite direction of the normal
			var push_dir = -collision.get_normal()
			collider.apply_impulse(push_dir * PUSH_FORCE, collision.get_position() - collider.global_position)


func _input(event):
	if !movement_frozen:
		if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			neck_vertical.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENSITIVITY * MOUSE_INVERT))
			neck_horizontal.rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY))
			neck_vertical.rotation.x = clamp(neck_vertical.rotation.x, deg_to_rad(-60), deg_to_rad(60))
			var rotation_angles = Vector3(neck_vertical.rotation.x, neck_horizontal.rotation.y, 0)
			camera_direction = Basis.from_euler(rotation_angles) * Vector3.FORWARD


func _on_line_edit_text_submitted(new_text: String) -> void:
	print("User typed: ", new_text)
	GM.word_input(new_text)
	line_edit.clear() 
	line_edit.release_focus()
	movement_frozen = false
	
func found_puzzle(puzzle) -> void:
	print("Player registered that puzzle was found.")
	
