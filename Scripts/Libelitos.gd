extends KinematicBody2D

const _t = preload("res://Scripts/tools.gd")
var GameTools = _t.new()

var Projectile = preload("res://Scenes/Projectile.tscn")
var Shot_Sound = preload("res://Sounds/shot.wav")

const invincibility_time = 3
const movement_reduction = 50 #percentage
const respawn_time = 2


var bullets_per_second = 5.0
var speed = Vector2()
var invincible:bool
var life:int
var can_shoot = true
var bullet_speed = -300.0
var movement = Vector2.ZERO
var state 
var disabled:bool

onready var bulletTimer = get_node("bulletTimer")
onready var iFrameTimer = get_node("iFrameTimer")
onready var respawnTimer = get_node("respawnTimer")

func _ready():
	$AudioStreamPlayer2D.stream = Shot_Sound
	$AudioStreamPlayer2D.volume_db = -10
	life = 3
	invincible = false
	speed.x = 200
	speed.y = 200
	state = "idle"
	disabled = false
	$wings.playing = true
	$body.animation = state
	$body.playing = true
	

func _physics_process(_delta):
	if not disabled:
		process_inputs()

		position.x = GameTools._aux_enframe(position.x, 5, GameTools.SCREEN_SIZE.x-5)
		position.y = GameTools._aux_enframe(position.y, 9, GameTools.SCREEN_SIZE.y-9)

		if movement.x == 0:
			state = "idle"
			$wings.rotation_degrees = 0
		else:
			state = "strafe"
			if movement.x < 0:
				$body.flip_h = true
				$wings.rotation_degrees = -8
			else:
				$body.flip_h = false
				$wings.rotation_degrees = 8

		if invincible:
			state += "_iframe"

		if state != $body.animation:
			$body.play(state)

		move_and_slide(movement)
	
		if get_slide_count() > 0:
			for i in range(get_slide_count()):
				if get_slide_collision(i).collider.name.count("Marimba")>0:
					kamikaze()
			take_damage()

func process_inputs():
	if(Input.is_action_pressed("ui_select")):
		fire()
	var horizontal:float = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var vertical:float = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	var reducto = Input.get_action_strength("player_slow") * movement_reduction
	horizontal = horizontal * speed.x * (100-reducto)/100
	vertical = vertical * speed.y * (100-reducto)/100
	movement = Vector2(horizontal, vertical)

func fire():
	if(can_shoot):
		$AudioStreamPlayer2D.play(0)
		var _p = Projectile.instance()
		#_p.velocity = Vector2(0, bullet_speed)
		_p.aim(0, bullet_speed)
		_p.set_player_fire()
		var main = get_tree().current_scene
		_p.global_position = self.global_position - Vector2(0,10)
		main.add_child(_p)
		can_shoot = false
		bulletTimer.set_wait_time(1/bullets_per_second)
		bulletTimer.start()

func take_damage():
	if not invincible:
		life -=1
		global_position = GameTools.LONGE_PRA_CARALHO
		disabled = true
		respawnTimer.set_wait_time(respawn_time)
		respawnTimer.start()
		if life == 0:
			die()
		
		invincible = true
		$CollisionShape2D.disabled = true
		$wings.play("default_iframe")
		$body.set_modulate(Color(1,1,1,0.5))
		$wings.set_modulate(Color(1,1,1,0.5))
		

func kamikaze():
	if not invincible:
		die()

func die():
	queue_free()
	
	#do something to restart

func _on_bulletTimer_timeout():
	can_shoot = true
	bulletTimer.stop()


func _on_iFrameTimer_timeout():
	invincible = false
	$CollisionShape2D.disabled = false
	$wings.play("default")
	$body.set_modulate(Color(1,1,1,1))
	$wings.set_modulate(Color(1,1,1,1))
	iFrameTimer.stop()

func _on_respawnTimer_timeout():
	global_position = Vector2(int(GameTools.SCREEN_SIZE.x/2), int(GameTools.SCREEN_SIZE.y*0.9))
	disabled = false
	iFrameTimer.set_wait_time(invincibility_time)
	iFrameTimer.start()
	respawnTimer.stop()
