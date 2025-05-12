extends Control

func _ready():
	$VBoxContainer/StartButton.pressed.connect(_on_start_pressed)
	$VBoxContainer/LoadButton.pressed.connect(_on_load_pressed)
	$VBoxContainer/SettingsButton.pressed.connect(_on_settings_pressed)
	$VBoxContainer/QuitButton.pressed.connect(_on_quit_pressed)

func _on_start_pressed():
	get_tree().change_scene_to_file("res://scenes/maps/Village.tscn")

func _on_load_pressed():
	print("Load Game clicked")

func _on_settings_pressed():
	print("Settings clicked")

func _on_quit_pressed():
	get_tree().quit()
