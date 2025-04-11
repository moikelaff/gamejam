extends CanvasLayer

var time_left = 300  # 5 minutes in seconds
@onready var timer = $Timer
@onready var label = $Label

func _ready():
	# Set timer properties
	timer.wait_time = 1.0
	timer.autostart = true
	
	# Connect the timer's timeout signal
	timer.timeout.connect(_on_timer_timeout)
	
	# Position the label in the top right corner
	label.text = format_time(time_left)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	label.vertical_alignment = VERTICAL_ALIGNMENT_TOP
	label.anchors_preset = Control.PRESET_TOP_RIGHT
	label.offset_right = -10  # 10px from right edge
	label.offset_top = 10     # 10px from top edge
	
	# End game when timer reaches zero
	if time_left <= 0:
		timer.stop()
		game_over()

func format_time(seconds):
	var minutes = int(seconds / 60)
	var remaining_seconds = seconds % 60
	return "%02d:%02d" % [minutes, remaining_seconds]

func game_over():
	print("Time's up! Game over!")
	get_tree().change_scene_to_file("res://scenes/game-over.tscn")


func _on_timer_timeout() -> void:
	time_left -= 1
	label.text = format_time(time_left)
	
	# End game when timer reaches zero
	if time_left <= 0:
		timer.stop()
		game_over()
