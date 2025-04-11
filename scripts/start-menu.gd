extends Control

# Called when the node enters the scene tree for the first time
func _ready():
	# Connect button signals
	$VBoxContainer/StartButton.pressed.connect(_on_start_button_pressed)
	$VBoxContainer/ExitButton.pressed.connect(_on_exit_button_pressed)

func _on_start_button_pressed():
	# Change to the game level scene
	get_tree().change_scene_to_file("res://scenes/level.tscn")

func _on_exit_button_pressed():
	# Exit the game
	get_tree().quit()
