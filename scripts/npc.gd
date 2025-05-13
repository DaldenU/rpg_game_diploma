extends CharacterBody2D
# NPC properties
@export var npc_name: String = "Villager"
@export_multiline var dialogue: Array[String] = ["Hello there!", "How are you today?", "Nice weather, isn't it?"]
@export var interaction_distance: float = 50.0
# Reference to the player
var player = null
var can_interact = false
var interaction_label = null
var dialogue_active = false
var current_dialogue_instance = null

# Called when the node enters the scene tree for the first time
func _ready():
	# Find the player by group (make sure to add your player to a "Player" group)
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("Player")
	
	# Create an interaction label (E to talk)
	create_interaction_label()
	
	# Debug
	print("NPC initialized: ", npc_name)
	print("Dialogue lines: ", dialogue)
	
func create_interaction_label():
	interaction_label = Label.new()
	if interaction_label:
		interaction_label.text = "Press E to talk"
		interaction_label.visible = false
		interaction_label.position = Vector2(-50, -50)  # Position above the NPC
		
		# Style the label
		interaction_label.add_theme_color_override("font_color", Color(1, 1, 1))
		interaction_label.add_theme_color_override("font_outline_color", Color(0, 0, 0))
		interaction_label.add_theme_constant_override("outline_size", 2)
		
		add_child(interaction_label)

func _process(delta):
	# Only allow interaction if dialogue is not active
	if dialogue_active:
		return
		
	# Check if player is in range and interaction label exists
	if player and interaction_label:
		var distance = global_position.distance_to(player.global_position)
		can_interact = (distance <= interaction_distance)
		interaction_label.visible = can_interact
		
		# Handle interaction input
		if can_interact and Input.is_action_just_pressed("interact"):
			print("NPC: Interaction detected - starting dialogue")
			start_dialogue()

# Start dialogue system
func start_dialogue():
	if dialogue_active:
		print("NPC: Dialogue already active")
		return
		
	dialogue_active = true
	
	# Reference to the DialogueManager (should be a singleton or in the scene)
	var dialogue_manager = get_tree().get_first_node_in_group("DialogueManager")
	
	if dialogue_manager:
		# Check if the start_dialogue method exists
		if dialogue_manager.has_method("start_dialogue"):
			print("NPC: Using existing DialogueManager")
			dialogue_manager.start_dialogue(npc_name, dialogue)
		else:
			print("DialogueManager doesn't have start_dialogue method!")
			dialogue_active = false
	else:
		# Create a simple dialogue box if no manager exists
		create_simple_dialogue_box()

# Create a basic dialogue box (if no dedicated dialogue system exists)
func create_simple_dialogue_box():
	# Load the dialogue manager scene
	var dialogue_scene = load("res://scenes/ui/dialogue_box.tscn")
	
	if dialogue_scene:
		print("NPC: Creating dialogue box instance")
		var dialogue_instance = dialogue_scene.instantiate()
		get_tree().root.add_child(dialogue_instance)
		current_dialogue_instance = dialogue_instance
		
		# Connect to dialogue end signal if available
		if dialogue_instance.has_signal("dialogue_ended"):
			dialogue_instance.connect("dialogue_ended", _on_dialogue_ended)
		
		# Call start_dialogue method if it exists
		if dialogue_instance.has_method("start_dialogue"):
			dialogue_instance.start_dialogue(npc_name, dialogue)
		else:
			print("Dialogue instance doesn't have start_dialogue method!")
			dialogue_active = false
	else:
		print("Dialogue Box scene not found! Please check the path.")
		dialogue_active = false

# Handle dialogue ending
func _on_dialogue_ended():
	print("NPC: Dialogue ended")
	dialogue_active = false
	current_dialogue_instance = null
