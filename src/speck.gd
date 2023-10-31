extends Node2D
var story
var pos
var score

# Called when the node enters the scene tree for the first time.
func _ready():
	var path_to_story = "res://stansa/stansa.json"
	var data_file = FileAccess.open(path_to_story,FileAccess.READ)
	pos = 0
	score = 0
	if(data_file):
		story = JSON.parse_string(data_file.get_as_text())
		print(story["lines"])
	else:
		print("failed to find story at " + path_to_story)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
