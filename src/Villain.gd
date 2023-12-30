extends Label
var story 
var current_pos
var parent
var buttons
var reply_button
var score
var complete
var hero_says
var replies

# Called when the node enters the scene tree for the first time.
func _ready():
	current_pos = -1
	parent = get_parent()
	reply_button = get_node("reply")
	buttons = []
	score = 0
	complete = false
	var callable = Callable(self,"_reply_to_villain")
	reply_button.pressed.connect(callable)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	story = parent.story
	if not complete:
		if(current_pos != parent.pos and parent.pos < len(story["lines"])):
			reply_button.visible = false
			current_pos+= 1
			self.set_text(story["lines"][current_pos]["villain"])
			var counter = 0
			replies = story["lines"][current_pos]["replies"]
			for button in buttons:
				button.queue_free()
			buttons = []	
			for x in story["lines"][current_pos]["replies"]:
				var button = Button.new()
				button.text = x["key_word"]
				var button_x = (self.position.x - len(button.text)) - 100
				var button_y = self.position.y - ( 60 * len(replies)) + counter
				
				if(len(buttons) % 2 != 0):
					button_x = (self.position.x + len(button.text)) + 500
					counter += 80
				var button_pos = Vector2(button_x,button_y)
				button.set_position(button_pos)
				button.pressed.connect(self._button_pressed.bind(button))
				buttons.append(button)
				self.add_child(button)
		if(parent.pos >= len(story["lines"])):
			print("score:" + str(score))
			complete = true		
	else:
		for button in buttons:
			button.queue_free()
			self.set_text("You scored " + str(score))
			self.get_node("Hero_rebuttle").queue_free()
		buttons = []
			
func _button_pressed(button):
	var replies = story["lines"][current_pos]["replies"]
	hero_says = _get_appropriate_response(button.text)
	self.get_node("Hero_rebuttle").text =  hero_says
	

func _get_appropriate_response(key):
		reply_button.visible = true
		for reply in replies:
			if(reply["key_word"] == key):
				return reply["reply"]
				
func _get_score(key):
		reply_button.visible = false
		for reply in replies:
			if(reply["reply"] == key):
				score += reply["score"]				

func _reply_to_villain():
	parent.pos += 1
	print(replies, hero_says)
	_get_score(hero_says)
