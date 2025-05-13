extends Control

# UI for the player's stats and inventory
# This will be a separate scene

# Reference to the player
var player = null

# References to the UI elements
@onready var level_label = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/StatsTab/LevelLabel
@onready var xp_label = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/StatsTab/XPLabel
@onready var strength_value = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/StatsTab/GridContainer/StrengthHBox/StrengthValueLabel
@onready var defense_value = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/StatsTab/GridContainer/DefenseHBox/DefenseValueLabel
@onready var intelligence_value = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/StatsTab/GridContainer/IntelligenceHBox/IntelligenceValueLabel
@onready var points_label = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/StatsTab/GridContainer/PointsAvailableLabel
@onready var inventory_grid = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/InventoryTab/InventoryGrid
@onready var close_button = $PanelContainer/MarginContainer/VBoxContainer/HBoxContainer/CloseButton

# Called when the scene is loaded
func _ready():
	# Connect button signals
	var strength_button = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/StatsTab/GridContainer/StrengthHBox/StrengthButton
	if strength_button:
		strength_button.pressed.connect(_on_strength_button_pressed)
	
	var defense_button = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/StatsTab/GridContainer/DefenseHBox/DefenseButton
	if defense_button:
		defense_button.pressed.connect(_on_defense_button_pressed)
	
	var intelligence_button = $PanelContainer/MarginContainer/VBoxContainer/TabContainer/StatsTab/GridContainer/IntelligenceHBox/IntelligenceButton
	if intelligence_button:
		intelligence_button.pressed.connect(_on_intelligence_button_pressed)
	
	# Connect close button
	if close_button:
		close_button.pressed.connect(_on_close_button_pressed)
	
	# Hide menu initially
	hide()

# Initialize the menu with a reference to the player
func initialize(player_ref):
	player = player_ref
	update_stats()

# Update all the stats displays
func update_stats():
	if not player:
		return
		
	if level_label:
		level_label.text = "Level: " + str(player.level)
	
	if xp_label:
		xp_label.text = "XP: " + str(player.current_xp) + "/" + str(player.max_xp)
	
	if strength_value:
		strength_value.text = str(player.strength)
	
	if defense_value:
		defense_value.text = str(player.defense)
	
	if intelligence_value:
		intelligence_value.text = str(player.intelligence)
	
	if points_label:
		points_label.text = "Available Points: " + str(player.attribute_points)
	
	# Update button visibility
	update_buttons_state()
	
	# Update inventory
	update_inventory()

# Enable/disable stat buttons based on available points
func update_buttons_state():
	var buttons = [
		$PanelContainer/MarginContainer/VBoxContainer/TabContainer/StatsTab/GridContainer/StrengthHBox/StrengthButton,
		$PanelContainer/MarginContainer/VBoxContainer/TabContainer/StatsTab/GridContainer/DefenseHBox/DefenseButton,
		$PanelContainer/MarginContainer/VBoxContainer/TabContainer/StatsTab/GridContainer/IntelligenceHBox/IntelligenceButton
	]
	
	for button in buttons:
		if button:
			button.disabled = player.attribute_points <= 0

# Populate the inventory grid with items
func update_inventory():
	if not inventory_grid or not player:
		return
	
	# Clear existing inventory items
	for child in inventory_grid.get_children():
		child.queue_free()
	
	# Create empty slots for the total inventory capacity
	for i in range(player.max_inventory_size):
		var slot = Panel.new()
		slot.custom_minimum_size = Vector2(60, 60)
		inventory_grid.add_child(slot)
	
	# Populate inventory slots with items
	for i in range(player.inventory.size()):
		var item = player.inventory[i]
		if i < inventory_grid.get_child_count():
			var slot = inventory_grid.get_child(i)
			
			# Create item display
			var item_texture = TextureRect.new()
			item_texture.texture = item.texture if "texture" in item else null
			item_texture.expand = true
			item_texture.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			item_texture.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
			item_texture.size_flags_vertical = Control.SIZE_SHRINK_CENTER
			item_texture.tooltip_text = item.name if "name" in item else "Unknown Item"
			
			# Add to slot
			slot.add_child(item_texture)

# Increase strength when button is pressed
func _on_strength_button_pressed():
	if player and player.attribute_points > 0:
		player.spend_attribute_point("strength")
		update_stats()

# Increase defense when button is pressed
func _on_defense_button_pressed():
	if player and player.attribute_points > 0:
		player.spend_attribute_point("defense")
		update_stats()

# Increase intelligence when button is pressed
func _on_intelligence_button_pressed():
	if player and player.attribute_points > 0:
		player.spend_attribute_point("intelligence")
		update_stats()

# Close the menu
func _on_close_button_pressed():
	hide()
	if player:
		player.is_stats_menu_open = false
