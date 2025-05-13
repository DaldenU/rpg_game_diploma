extends CharacterBody2D

# Player movement variables
@export var walk_speed = 150.0
@export var run_speed = 250.0

# Player stats
@export var max_health = 100.0
@export var health = 100.0
@export var max_xp = 100.0
@export var current_xp = 0.0
@export var level = 1

# Player attributes
@export var strength = 5
@export var defense = 5
@export var intelligence = 5

# Points available to spend on attributes
var attribute_points = 0

# Inventory system
var inventory = []
var max_inventory_size = 20

# Animation references
@onready var animator = $AnimationPlayer if has_node("AnimationPlayer") else null
@onready var sprite = $Sprite2D if has_node("Sprite2D") else null

# UI references
@onready var health_bar = $UI/HealthBar if has_node("UI/HealthBar") else null
@onready var xp_bar = $UI/XPBar if has_node("UI/XPBar") else null
var stats_menu = null  # Will be loaded and instanced dynamically

# Camera variables
@export var min_zoom = 0.5
@export var max_zoom = 2.0
@export var zoom_speed = 0.1
@export var default_zoom = 1.0
@onready var camera = $Camera2D if has_node("Camera2D") else null

# State tracking
var is_running = false
var facing_direction = "down"
var is_attacking = false
var is_stats_menu_open = false

func _ready():
	# Set initial zoom
	if camera:
		camera.zoom = Vector2(default_zoom, default_zoom)
	
	# Initialize UI elements
	update_ui()
	
	# Preload the stats menu scene
	preload_stats_menu()

func _physics_process(delta):
	# Skip processing if menu is open
	if is_stats_menu_open:
		return
	
	# Skip movement if attacking
	if is_attacking:
		return
	
	# Get input direction
	var input_direction = Vector2.ZERO
	input_direction.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
	input_direction.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	
	# Normalize to prevent faster diagonal movement
	input_direction = input_direction.normalized()
	
	# Check if running
	is_running = Input.is_action_pressed("sprint")
	
	# Set velocity based on input
	if input_direction != Vector2.ZERO:
		# Apply movement speed
		var current_speed = run_speed if is_running else walk_speed
		velocity = input_direction * current_speed
		
		# Update facing direction
		update_facing_direction(input_direction)
		
		# Play appropriate animation
		play_movement_animation()
	else:
		# Stop immediately when no input
		velocity = Vector2.ZERO
		play_idle_animation()
	
	# Apply movement
	move_and_slide()
	
	# Handle camera zoom
	handle_camera_zoom()
	
	# Handle attack input
	if Input.is_action_just_pressed("attack"):
		attack()
	
	# Toggle stats menu
	if Input.is_action_just_pressed("toggle_menu"):
		toggle_stats_menu()

# Update the player's facing direction based on input
func update_facing_direction(input_direction):
	# Determine direction priority (up/down takes precedence over left/right)
	if abs(input_direction.y) > abs(input_direction.x):
		facing_direction = "down" if input_direction.y > 0 else "up"
	else:
		facing_direction = "right" if input_direction.x > 0 else "left"

# Play the appropriate movement animation
func play_movement_animation():
	if animator:
		var anim_name = "run_" if is_running else ""
		anim_name += facing_direction
		animator.play(anim_name)

# Play idle animation based on facing direction
func play_idle_animation():
	if animator:
		animator.play("idle_" + facing_direction)

# Handle player attack
func attack():
	if is_attacking:
		return
		
	is_attacking = true
	
	if animator:
		animator.play("attack_" + facing_direction)
		# Wait for animation to finish
		await animator.animation_finished
		is_attacking = false
		play_idle_animation()

# Handle camera zoom with mouse wheel
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
		
		# Apply zoom
		camera.zoom = Vector2(new_zoom, new_zoom)

# Preload and setup the stats menu
func preload_stats_menu():
	# Load the stats menu scene
	var stats_menu_scene = load("res://ui/stats_menu.tscn")
	if stats_menu_scene:
		# Create an instance
		stats_menu = stats_menu_scene.instantiate()
		# Add to UI
		var ui = $UI if has_node("UI") else null
		if ui:
			ui.add_child(stats_menu)
			# Initialize with player reference
			stats_menu.initialize(self)
			# Hide initially
			stats_menu.hide()

# Toggle the stats menu visibility
func toggle_stats_menu():
	is_stats_menu_open = !is_stats_menu_open
	
	if stats_menu:
		if is_stats_menu_open:
			stats_menu.show()
			stats_menu.update_stats()
		else:
			stats_menu.hide()

# Update all UI elements
func update_ui():
	update_health_bar()
	update_xp_bar()

# Update health bar
func update_health_bar():
	if health_bar:
		health_bar.value = health
		health_bar.max_value = max_health

# Update XP bar
func update_xp_bar():
	if xp_bar:
		xp_bar.value = current_xp
		xp_bar.max_value = max_xp

# Apply damage to the player
func take_damage(amount):
	health -= max(0, amount - defense * 0.5)  # Defense reduces damage
	if health <= 0:
		health = 0
		die()
	update_health_bar()

# Handle player death
func die():
	if animator:
		animator.play("death_" + facing_direction)
		# You might want to handle game over here

# Add XP to the player
func add_xp(amount):
	current_xp += amount
	
	# Level up if enough XP
	if current_xp >= max_xp:
		level_up()
	
	update_xp_bar()
	
	# Update stats menu if open
	if is_stats_menu_open and stats_menu:
		stats_menu.update_stats()

# Handle player level up
func level_up():
	level += 1
	current_xp -= max_xp
	max_xp = level * 100  # XP requirement increases with level
	
	# Increase max health with level
	max_health = 100 + (level - 1) * 20
	health = max_health
	
	# Add attribute points
	attribute_points += 3
	
	update_ui()
	
	# Optional: Play level up effect

# Spend attribute points
func spend_attribute_point(attribute):
	if attribute_points <= 0:
		return false
		
	match attribute:
		"strength":
			strength += 1
		"defense":
			defense += 1
		"intelligence":
			intelligence += 1
		_:
			return false
			
	attribute_points -= 1
	update_stats()
	return true

# Add item to inventory
func add_to_inventory(item):
	if inventory.size() >= max_inventory_size:
		return false
		
	inventory.append(item)
	return true

# Remove item from inventory
func remove_from_inventory(item_index):
	if item_index < 0 or item_index >= inventory.size():
		return null
		
	var item = inventory[item_index]
	inventory.remove_at(item_index)
	return item
