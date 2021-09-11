extends KinematicBody2D

var Projectile = preload("res://Scenes/Projectile.tscn")
var Shot_Sound = preload("res://Sounds/shot.wav")

const speed = Vector2()
onready var bulletTimer = get_node("bulletTimer")
var can_shoot = true

func _ready():
	$AudioStreamPlayer2D.stream = Shot_Sound
	$AudioStreamPlayer2D.volume_db = -10
	speed.x = 200
	speed.y = 200
	

func _physics_process(delta):
	process_inputs()

func process_inputs():
	if(Input.is_action_pressed("ui_select")):
		fire()
	var horizontal = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var vertical = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	horizontal = horizontal * speed.x
	vertical = vertical * speed.y
	move_and_slide(Vector2(horizontal, vertical))

func fire():
	if(can_shoot):
		$AudioStreamPlayer2D.play(0)
		var _p = Projectile.instance()
		_p.set_player_fire()
		var main = get_tree().current_scene
		_p.global_position = self.global_position
		main.add_child(_p)
		can_shoot = false
		bulletTimer.set_wait_time(.2)
		bulletTimer.start()



func _on_bulletTimer_timeout():
	can_shoot = true
	bulletTimer.stop()
