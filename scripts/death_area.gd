# Attach this script to your death-area Area2D node
extends Area2D

# Specify the path to your game over scene
@export var game_over_scene: String = "res://scenes/game_over.tscn"

func _ready():
	# Connect the body_entered signal
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if body.is_in_group("character"):
		get_tree().change_scene_to_file(game_over_scene)
