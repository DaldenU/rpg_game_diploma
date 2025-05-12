extends CharacterBody2D

# Player movement variables
@export var speed = 400.0
@export var sprint_multiplier = 5
@export var acceleration = 25.0
@export var friction = 10.0
@export var sprint_stamina_max = 100.0
@export var sprint_stamina_drain = 15.0
@export var sprint_stamina_regen = 10.0

# Current stamina value
var stamina = sprint_stamina_max
var can_sprint = true

# Camera zoom variables
@export var min_zoom = 0.5
@export var max_zoom = 2.0
@export var zoom_speed = 0.1
@export var zoom_margin = 0.1
@export var default_zoom = 1.0

# Reference to the camera
@onready var camera = $Camera2D if has_node("Camera2D") else null

func _ready():
	# Set initial zoom
	if camera:
		camera.zoom = Vector2(default_zoom, default_zoom)

func _physics_process(delta):
	# Get input direction
	var input_direction = Vector2.ZERO
	input_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	# Normalize to prevent faster diagonal movement
	input_direction = input_direction.normalized()
	
	# Handle sprinting
	var is_sprinting = false
	if Input.is_action_pressed("sprint") and can_sprint and input_direction != Vector2.ZERO:
		is_sprinting = true
		stamina -= sprint_stamina_drain * delta
		
		if stamina <= 0:
			stamina = 0
			can_sprint = false
	else:
		# Regenerate stamina when not sprinting
		stamina += sprint_stamina_regen * delta
		if stamina >= sprint_stamina_max:
			stamina = sprint_stamina_max
			can_sprint = true
	
	# Apply current movement speed
	var current_speed = speed * (sprint_multiplier if is_sprinting else 1.0)
	
	if input_direction != Vector2.ZERO:
		# Gradually increase velocity for smoother acceleration
		velocity = velocity.move_toward(input_direction * current_speed, acceleration)
	else:
		# Gradually decrease velocity when no input for smoother deceleration
		velocity = velocity.move_toward(Vector2.ZERO, friction)
	
	# Apply movement
	move_and_slide()
	
	# Handle camera zoom
	handle_camera_zoom()

# Handle camera zoom with mouse wheel or custom inputs
func handle_camera_zoom():
	if not camera:
		return
		
	var zoom_change = 0
	
	# Check for mouse wheel input
	if Input.is_action_just_released("zoom_in"):
		zoom_change = zoom_speed
	elif Input.is_action_just_released("zoom_out"):
		zoom_change = -zoom_speed
		
	if zoom_change != 0:
		# Calculate new zoom level
		var new_zoom = clamp(camera.zoom.x + zoom_change, min_zoom, max_zoom)
		
		# Apply smooth zoom
		camera.zoom = Vector2(new_zoom, new_zoom)
