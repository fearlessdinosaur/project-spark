extends Label
var story 
var current_pos
var parent
var buttons
var reply_button
var complete
var hero_says
var replies
var intents
var printing_hero_text = false

# Called when the node enters the scene tree for the first time.
func _ready():
	current_pos = -1
	parent = get_parent()
	reply_button = get_node("reply")
	buttons = []
	complete = false
	var callable = Callable(self,"_reply_to_villain")
	intents = {"Nihilistic": 0, "Stoic": 0, "Absurdist": 0}
	reply_button.pressed.connect(callable)
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	story = parent.story
	if not complete:
		if(current_pos != parent.pos and parent.pos < len(story["lines"])):
			reply_button.visible = false
			self.get_node("Hero_rebuttle").visible = false
			current_pos+= 1
			var villain_reply = ""
			for letter in story["lines"][current_pos]["villain"]:
				villain_reply += letter
				self.set_text(villain_reply)
				await get_tree().create_timer(0.09).timeout
			var counter = 0
			replies = story["lines"][current_pos]["replies"]
			for button in buttons:
				button.queue_free()
			buttons = []	
			for x in story["lines"][current_pos]["replies"]:
				var button = Button.new()
				button.text = x["key_word"]
				var button_x = (self.position.x - len(button.text)) - 100
				var button_y = (self.position.y - (len(replies) * 25))  + counter 
				print(self.position.y)
				
				if(len(buttons) % 2 != 0):
					button_x = (self.position.x + len(button.text)) + 500
					counter += 80
				var button_pos = Vector2(button_x,button_y)
				button.set_position(button_pos)
				button.pressed.connect(self._button_pressed.bind(button))
				buttons.append(button)
				self.add_child(button)
		if(parent.pos >= len(story["lines"])):
			complete = true		
	else:
		for button in buttons:
			button.queue_free()
			
			var disposition = "undecided"
			var score = 0
			for intent in intents:
				if(intents[intent] > score):
					score = intents[intent]
					disposition = intent
			self.set_text("You are of a %s disposition" % disposition)
			self.get_node("Hero_rebuttle").queue_free()
		buttons = []
			
func _button_pressed(button):
	var replies = story["lines"][current_pos]["replies"]
	hero_says = _get_appropriate_response(button.text)
	if not printing_hero_text:
		printing_hero_text = true
		stylish_output(hero_says, "Hero_rebuttle")
	else:
		printing_hero_text = false
		await get_tree().create_timer(0.1).timeout
		printing_hero_text = true
		stylish_output(hero_says, "Hero_rebuttle")

func stylish_output(txt, nodename):
		self.get_node(nodename).visible = true
		var output = ""
		for letter in hero_says:
			if not printing_hero_text:
				break
			output += letter
			self.get_node(nodename).text =  output
			await get_tree().create_timer(0.1).timeout
		printing_hero_text = false

func _get_appropriate_response(key):
		reply_button.visible = true
		for reply in replies:
			if(reply["key_word"] == key):
				return reply["reply"]
				
func _get_score(key):
		reply_button.visible = false
		for reply in replies:
			if(reply["reply"] == key):
				intents[reply["type"]] += 1				

func _reply_to_villain():
	parent.pos += 1
	_get_score(hero_says)
