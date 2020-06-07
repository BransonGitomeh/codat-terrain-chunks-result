extends Control


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
onready var fps_label = get_node('stats/fps_label')

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	fps_label.set_text("Fps: " + str(Engine.get_frames_per_second()))
	pass

func _on_close_pressed():
	get_tree().quit()