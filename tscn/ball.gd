extends Area2D

const LIGHTBLUE = "#6A6AFF"
const LIGHTYELLOW = "#FFFF6A"
const LIGHTPURPLE = "#D07AFF"
const LIGHTORANGE = "#FFB852"
const LIGHTBROWN = "#C0A080"
const LIGHTGRAY = "#A0A0A0"
const DARKGRAY = "#606060"
const COLORS = [LIGHTBLUE, LIGHTYELLOW, LIGHTPURPLE, LIGHTORANGE, LIGHTBROWN, LIGHTGRAY, DARKGRAY]

var original_ball_position = Vector2.ZERO
var velocity = Vector2.ZERO
var speed = 600
var speed_multiplier = 1.2

var game_started = false
var game_paused = false
var ball_pushed = false

const steepest_degree = deg_to_rad(10.0)
var upper_angle_left = Vector2.UP.rotated(steepest_degree).normalized()
var lower_angle_left = Vector2.DOWN.rotated(-steepest_degree).normalized()
var lower_angle_right = Vector2.DOWN.rotated(steepest_degree).normalized()
var upper_angle_right = Vector2.UP.rotated(-steepest_degree).normalized()

var old_color
var new_color

# Called when the node enters the scene tree for the first time.
func _ready():
	original_ball_position = position
	$change_color_timer.start()
	old_color = COLORS[randi() % COLORS.size()]
	new_color = COLORS[randi() % COLORS.size()]

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# gradually change color in title
	var max_time = $change_color_timer.wait_time
	var current_time = $change_color_timer.wait_time - $change_color_timer.time_left
	var mid_color = gradient_color_change(old_color, new_color, current_time, max_time)
	$Sprite2D.modulate = Color(mid_color)

func gradient_color_change(old_color, new_color, time_current, time_max):
	old_color = Color(old_color)
	new_color = Color(new_color)
	var time_factor = time_current / time_max
	return old_color.lerp(new_color, time_factor).to_html()

func _physics_process(delta):
	if game_started:
		if !game_paused:
			if !ball_pushed:
				velocity = Vector2(randf_range(-1.0, 1.0), randf_range(-0.6, 0.6)).normalized() * delta * speed
				ball_pushed = true
			position += velocity
	pass

func set_game_started(set_game_started):
	game_started = set_game_started
	if (!game_started):
		position = original_ball_position
		velocity = Vector2.ZERO
		ball_pushed = false

func set_paused(set_paused):
	game_paused = set_paused
	
func get_paused():
	return game_paused

func reset_ball():
	position = original_ball_position
	velocity = Vector2.ZERO
	ball_pushed = false

func _on_area_entered(area):
	if (area.name == "lower_wall" || area.name == "upper_wall"):
		$hit_play.play()
		velocity = velocity.bounce(Vector2.UP)

func _on_body_entered(body):
	if ("player_" in body.name):
		$hit_play.play()
		var low_ness_factor = abs(body.position.y - position.y) / 210
		# interpolation: https://docs.godotengine.org/en/stable/tutorials/math/interpolation.html
		var length = velocity.length()
		
		# ball hit right paddle
		if (velocity.x > 0.0):
			velocity = (upper_angle_right * (1 - low_ness_factor) + 
			 lower_angle_right * low_ness_factor)
		else:
			velocity = (upper_angle_left * (1 - low_ness_factor) + 
			 lower_angle_left * low_ness_factor)
		velocity = velocity.normalized() * length
		velocity = velocity * speed_multiplier
#		velocity = velocity.bounce(Vector2.LEFT) * speed_multiplier
		velocity.x = clamp(velocity.x, -25.0, 25.0)
		velocity.y = clamp(velocity.y, -25.0, 25.0)


func _on_change_color_timer_timeout():
	old_color = new_color
	var same_color = true
	while same_color:
		new_color = COLORS[randi() % COLORS.size()]
		same_color = (new_color == old_color)
