extends CharacterBody2D

var player
@export var game_started = false
@export var speed = 700
var has_moved = false
var should_reset = false
var original_position = Vector2.ZERO
var is_paused = false
var computer_playing = false
var ball

func _ready():
	var t = Timer.new()
	t.set_wait_time(randf_range(0.3, 1.5))
	t.set_one_shot(true)
	self.add_child(t)
	t.start()
	$auto_move_timer.start()
	original_position = position
	ball = get_tree().get_root().get_node("arena/ball")

func _physics_process(delta):
	if !is_paused:
		if game_started:
			velocity = Vector2.ZERO
			if (computer_playing):
				var direction = ball.position.y - position.y
				velocity = Vector2(0.0, direction).normalized() * speed
			else:
				if (player == "Left"):
					if Input.is_action_pressed("P1-Up"):
						velocity = Vector2.UP * speed
					if Input.is_action_pressed("P1-Down"):
						velocity = Vector2.DOWN * speed
				elif (player == "Right"):
					if Input.is_action_pressed("P2-Up"):
						velocity = Vector2.UP * speed
					if Input.is_action_pressed("P2-Down"):
						velocity = Vector2.DOWN * speed
		# "Autopilot" mode when the game hasn't started yet
		else:
			if should_reset:
				var difference = Vector2(position.x, 450) - position
				velocity = difference.normalized() * speed
				# threshold to move to mid
				if abs(difference.y) > 0.0 && abs(difference.y) < 10.0:
					game_started = true
					should_reset = false
			else:
				if !has_moved:
					var rand_input = randi() % 3
					if rand_input == 0:
						velocity = Vector2.UP * speed
					elif rand_input == 1:
						velocity = Vector2.DOWN * speed
					else:
						velocity = Vector2.ZERO
					has_moved = true
		move_and_slide()
	
func set_color(color):
	$Polygon2D.color = color

func set_player(set_to_player):
	player = set_to_player

func return_to_mid():
	should_reset = true
	
func reset():
	should_reset = false
	game_started = false
	
func set_paused(set_paused_value):
	is_paused = set_paused_value

func _on_auto_move_timer_timeout():
	has_moved = false
	
func set_computer_playing(set_computer_playing):
	computer_playing = set_computer_playing
