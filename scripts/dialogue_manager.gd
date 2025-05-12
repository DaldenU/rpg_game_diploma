extends CanvasLayer
# UI nodes
var dialogue_box
var speaker_name
var dialogue_text
var next_indicator
# Dialogue variables
var current_dialogue = []
var dialogue_index = 0
var is_dialogue_active = false
var is_text_revealing = false
# Text reveal settings
@export var text_speed = 0.03  # Time between characters
var text_timer = 0

# Signal for when dialogue ends
signal dialogue_ended

func _ready():
	# Get references to UI nodes using the correct node names
	dialogue_box = $DialogueBox
	speaker_name = $DialogueBox/Label
	dialogue_text = $DialogueBox/RichTextLabel
	next_indicator = $DialogueBox/NextIndicator
	
	# Make sure all nodes exist
	if not dialogue_box or not speaker_name or not dialogue_text or not next_indicator:
		push_error("Dialogue UI nodes not found! Check the scene structure.")
		return
	
	# Hide dialogue box initially
	dialogue_box.visible = false
	next_indicator.visible = false
	
	print("Dialogue Manager initialized successfully")

func _unhandled_input(event):
	# Use unhandled_input instead of _process for better input handling
	if is_dialogue_active and event.is_action_pressed("interact"):
		print("Dialogue: Interact key pressed")
		get_viewport().set_input_as_handled()  # Mark input as handled
		
		if is_text_revealing:
			# If text is still being revealed, show it all immediately
			print("Dialogue: Showing full text")
			dialogue_text.visible_characters = -1
			is_text_revealing = false
			next_indicator.visible = true
		else:
			# Move to next dialogue line
			print("Dialogue: Moving to next line")
			next_dialogue_line()

func _process(delta):
	# Make sure nodes exist
	if not dialogue_text or not next_indicator:
		return
		
	# Handle text reveal effect
	if is_text_revealing:
		text_timer += delta
		if text_timer >= text_speed:
			text_timer = 0
			reveal_next_character()

# Start a new dialogue
func start_dialogue(npc_name: String, dialogue_lines: Array):
	print("Dialogue: Starting dialogue with: ", npc_name)
	print("Dialogue: Lines: ", dialogue_lines)
	
	# Make sure all required nodes exist
	if not dialogue_box or not speaker_name or not dialogue_text:
		push_error("Dialogue UI nodes not found! Cannot start dialogue.")
		return
		
	is_dialogue_active = true
	current_dialogue = dialogue_lines
	dialogue_index = 0
	
	# Show dialogue box
	dialogue_box.visible = true
	
	# Set NPC name
	speaker_name.text = npc_name
	
	# Display first line of dialogue
	if current_dialogue.size() > 0:
		display_dialogue_line(current_dialogue[0])
	else:
		push_error("No dialogue lines provided!")
		end_dialogue()

# Display a single line of dialogue with typewriter effect
func display_dialogue_line(line: String):
	if not dialogue_text or not next_indicator:
		return
	
	print("Dialogue: Displaying line: ", line)
	dialogue_text.text = line
	dialogue_text.visible_characters = 0
	is_text_revealing = true
	next_indicator.visible = false

# Reveal next character in the text
func reveal_next_character():
	if not dialogue_text:
		return
		
	if dialogue_text.visible_characters < dialogue_text.text.length():
		dialogue_text.visible_characters += 1
	else:
		is_text_revealing = false
		if next_indicator:
			next_indicator.visible = true
			print("Dialogue: Text fully revealed, showing indicator")

# Move to next dialogue line
func next_dialogue_line():
	dialogue_index += 1
	print("Dialogue: Moving to dialogue index: ", dialogue_index)
	
	if dialogue_index < current_dialogue.size():
		# Show next line
		display_dialogue_line(current_dialogue[dialogue_index])
	else:
		# End dialogue
		print("Dialogue: End of dialogue reached")
		end_dialogue()

# End the dialogue
func end_dialogue():
	print("Dialogue: Ending dialogue")
	is_dialogue_active = false
	if dialogue_box:
		dialogue_box.visible = false
	
	# Emit signal that dialogue has ended
	emit_signal("dialogue_ended")
	
	# Don't queue_free immediately, give a slight delay
	await get_tree().create_timer(0.1).timeout
	queue_free()  # Remove dialogue box
