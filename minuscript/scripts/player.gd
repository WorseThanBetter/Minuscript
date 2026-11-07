extends CharacterBody3D

const PUSH_FORCE = 1
const SPEED = 6.0
const JUMP_VELOCITY = 4.5
const MOUSE_SENSITIVITY = 0.15
const MOUSE_INVERT = 1 # -1 for inverted y

enum States {MOVING,WRITING,MENU}
var current_state = States.MOVING


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
		if current_state == States.MENU:
			switch_state(States.MOVING)
		elif current_state == States.WRITING:
			switch_state(States.MOVING)
		else:
			switch_state(States.MENU)
	if Input.is_action_just_pressed("write") && current_state == States.MOVING:
		switch_state(States.WRITING)

	# Add the gravity. Holding jump decreases gravity while travelling upwards.
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
			velocity.x = move_toward(velocity.x, 0, SPEED/4)
			velocity.z = move_toward(velocity.z, 0, SPEED/4)

	velocity.x = move_toward(velocity.x, 0, SPEED/32)
	velocity.z = move_toward(velocity.z, 0, SPEED/32)
	
	move_and_slide()



func _input(event):
	if !movement_frozen:
		if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
			neck_vertical.rotate_x(deg_to_rad(-event.relative.y * MOUSE_SENSITIVITY * MOUSE_INVERT))
			neck_horizontal.rotate_y(deg_to_rad(-event.relative.x * MOUSE_SENSITIVITY))
			neck_vertical.rotation.x = clamp(neck_vertical.rotation.x, deg_to_rad(-60), deg_to_rad(60))
			var rotation_angles = Vector3(neck_vertical.rotation.x, neck_horizontal.rotation.y, 0)
			camera_direction = Basis.from_euler(rotation_angles) * Vector3.FORWARD


func _on_line_edit_text_submitted(new_text: String) -> void:
	GM.word_input(new_text)
	line_edit.clear()
	switch_state(States.MOVING)

# Called from GM when the player submits a valid word.
# @param found_puzzle: the puzzle that was just solved.
func found_puzzle(found_puzzle: Puzzle) -> void:
	print("Player registered that puzzle was found.")
	found_puzzle.destroy(self)
	GM.word_dict.erase(found_puzzle.solution.to_lower())

# Function to safely switch between states, ensuring correct behavior.
# @param new_state: the state to switch to.
func switch_state(new_state: States):
	
	# Behaviors that happen when exiting the current state.
	match current_state:
		States.MOVING:
			movement_frozen = true
		States.WRITING:
			line_edit.release_focus()
			line_edit.visible = false
		States.MENU:
			movement_frozen = true
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		_:
			pass
	
	# Behaviors that happen when switching to this state.
	match new_state:
		States.MOVING:
			movement_frozen = false
			line_edit.release_focus()
		States.WRITING:
			line_edit.grab_focus()
			line_edit.visible = true
		States.MENU:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		_:
			pass
	current_state = new_state
