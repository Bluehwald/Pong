extends Node2D

const LIGHTRED = "#FF6A6A"
const LIGHTGREEN = "#6AFF6A"
const LIGHTBLUE = "#6A6AFF"
const LIGHTYELLOW = "#FFFF6A"
const LIGHTPURPLE = "#D07AFF"
const LIGHTCYAN = "#6AFFFF"
const LIGHTORANGE = "#FFB852"
const LIGHTBROWN = "#C0A080"
const LIGHTGRAY = "#A0A0A0"
const DARKGRAY = "#606060"
const COLORS = [LIGHTRED, LIGHTGREEN, LIGHTBLUE, LIGHTYELLOW, LIGHTPURPLE, LIGHTCYAN, LIGHTORANGE, LIGHTBROWN, LIGHTGRAY, DARKGRAY]
	
var old_color_p
var new_color_p
var old_color_o
var new_color_o
var old_color_n
var new_color_n
var old_color_g
var new_color_g

var game_started

var music_pause_position

# Called when the node enters the scene tree for the first time.
func _ready():
	$title_parent/title_timer.start()
	var old_colors = assign_random_different_colors()
	old_color_p = old_colors[0]
	old_color_o = old_colors[1]
	old_color_n = old_colors[2]
	old_color_g = old_colors[3]
	var new_colors = assign_random_different_colors()
	new_color_p = new_colors[0]
	new_color_o = new_colors[1]
	new_color_n = new_colors[2]
	new_color_g = new_colors[3]
	
	$player_left.set_color(LIGHTCYAN)
	$player_right.set_color(LIGHTRED)
	
	$player_left.set_player("Left")
	$player_right.set_player("Right")
	
	$player_left.game_started = false
	$player_right.game_started = false	
	game_started = false
	
	$score_left.hide()
	$score_right.hide()
	
	$paused_screen.hide()
	$title_parent/win_label.hide()
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# gradually change color in title
	var max_time = $title_parent/title_timer.wait_time
	var current_time = $title_parent/title_timer.wait_time - $title_parent/title_timer.time_left
	var mid_color_p = gradient_color_change(old_color_p, new_color_p, current_time, max_time)
	var mid_color_o = gradient_color_change(old_color_o, new_color_o, current_time, max_time)
	var mid_color_n = gradient_color_change(old_color_n, new_color_n, current_time, max_time)
	var mid_color_g = gradient_color_change(old_color_g, new_color_g, current_time, max_time)
	update_title(mid_color_p, mid_color_o, mid_color_n, mid_color_g)
	
	if (game_started):
		if (Input.is_action_just_pressed("Pause")):
			if ($ball.get_paused()):
				$ball.set_paused(false)
				$player_left.set_paused(false)
				$player_right.set_paused(false)
				$background_music.play(music_pause_position)
				$paused_screen.hide()
				$HUD.hide()
			else:
				$ball.set_paused(true)
				$player_left.set_paused(true)
				$player_right.set_paused(true)
				music_pause_position = $background_music.get_playback_position()
				$background_music.stop()
				$paused_screen.show()
				$HUD.show()
		if (Input.is_action_just_pressed("Reset")):
			reset()
				
	if (Input.is_action_pressed("Quit")):
		get_tree().quit()
	if (!game_started):
		if (Input.is_action_pressed("Start-PVP")):
			start_game()
		if (Input.is_action_pressed("Start-PVE")):
			start_game()
			$player_right.set_computer_playing(true)

func start_game():
	$play_start_game.play()
	game_started = true
	$player_left.return_to_mid()
	$player_right.return_to_mid()
	$ball.set_game_started(game_started)
	
	$HUD.hide()
	$title_parent/title_label.hide()
	$score_left.show()
	$score_right.show()
	$score_left.text = "0"
	$score_right.text = "0"

func reset():
	game_started = false
	$score_left.hide()
	$score_right.hide()
	$title_parent/title_label.show()
	$HUD.show()
	$ball.set_game_started(game_started)
	$paused_screen.hide()
	$background_music.stop()
	$background_music.play()
	$ball.set_paused(false)
	$player_left.set_paused(false)
	$player_right.set_paused(false)
	$player_left.reset()
	$player_right.reset()
	$player_right.set_computer_playing(false)

func _on_title_timer_timeout():
	old_color_p = new_color_p
	old_color_o = new_color_o
	old_color_n = new_color_n
	old_color_g = new_color_g
	var new_colors = assign_random_different_colors()
	new_color_p = new_colors[0]
	new_color_o = new_colors[1]
	new_color_n = new_colors[2]
	new_color_g = new_colors[3]

func gradient_color_change(old_color, new_color, time_current, time_max):
	old_color = Color(old_color)
	new_color = Color(new_color)
	var time_factor = time_current / time_max
	return old_color.lerp(new_color, time_factor).to_html()

func assign_random_different_colors():
	var same_colors = true
	var c1
	var c2
	var c3
	var c4
	
	while same_colors:
		c1 = COLORS[randi() % COLORS.size()]
		c2 = COLORS[randi() % COLORS.size()]
		c3 = COLORS[randi() % COLORS.size()]
		c4 = COLORS[randi() % COLORS.size()]
		same_colors = (c1 == c2) || (c1 == c3) || (c1 == c4) || (c2 == c3) || (c2 == c4) || (c3 == c4)
	return [c1, c2, c3, c4]

func update_title(c1, c2, c3, c4):
	$title_parent/title_label.bbcode_text = "[color={}]P[/color] [color={}]O[/color] [color={}]N[/color] [color={}]G[/color]".format([c1, c2, c3, c4], "{}")

func _on_area_out_player_left_collision_area_entered(area):
	$score_sound.play()
	$ball.reset_ball()
	$score_right.text = str(int($score_right.text) + 1)
	if (int($score_right.text) == 10):
		reset()
		$title_parent/win_label.show()
		$title_parent/win_label.text = "R i g h t   P l a y e r   h a s   w o n"

func _on_area_out_player_right_collision_2_area_entered(area):
	$score_sound.play()
	$ball.reset_ball()
	$score_left.text = str(int($score_left.text) + 1)
	if (int($score_left.text) == 10):
		reset()
		$title_parent/win_label.show()
		$title_parent/win_label.text = "L e f t   P l a y e r   h a s   w o n"
