extends KinematicBody2D

const _t = preload("res://Scripts/tools.gd")
var GameTools = _t.new()

var Projectile = preload("res://Scenes/Projectile.tscn")
var Shot_Sound = preload("res://Sounds/shot.wav")

signal player_dead

const INVINCIBILITY_TIME = 3
const MOVEMENT_REDUCTION = 50 #percentage
const RESPAWN_TIME = 2
const AFTER_DEATH_SCATTER = 15
const SCATTER_SPEED = 200

var bullets_per_second = 10.0
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
	connect("player_dead", get_parent(), "_on_player_shindeiru")	

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
			take_damage()

func process_inputs():
	if(Input.is_action_pressed("player_shoot")):
		fire()
	var horizontal:float = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var vertical:float = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	var reducto = Input.get_action_strength("player_slow") * MOVEMENT_REDUCTION
	horizontal = horizontal * speed.x * (100-reducto)/100
	vertical = vertical * speed.y * (100-reducto)/100
	movement = Vector2(horizontal, vertical)

func fire():
	if(can_shoot):
		$AudioStreamPlayer2D.play(0)
		var _p = Projectile.instance()
		#_p.velocity = Vector2(0, bullet_speed)
		_p.aim(0, bullet_speed)
		_p.set_player_fire("libelito")
		var main = get_tree().current_scene
		_p.global_position = self.global_position - Vector2(0,10)
		main.add_child(_p)
		can_shoot = false
		bulletTimer.set_wait_time(1/bullets_per_second)
		bulletTimer.start()

func take_damage():
	if not invincible:
		life -=1
		state = "death"
		$body.play("death")
		after_death()
		$wings.visible = false
		disabled = true
		respawnTimer.set_wait_time(RESPAWN_TIME)
		respawnTimer.start()
		
		#invincible = true
		$CollisionShape2D.disabled = true
		

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

func after_death():
	var step = (PI * 2)/AFTER_DEATH_SCATTER
	var root = get_tree().current_scene
	for i in range(AFTER_DEATH_SCATTER):
		var _p = Projectile.instance()
		_p.aim(cos(step*i)*SCATTER_SPEED, sin(step*i)*SCATTER_SPEED)
		_p.position = self.global_position
		_p.set_player_fire("libelito_death")
		root.add_child(_p)
	pass

func _on_respawnTimer_timeout():
	global_position = Vector2(int(GameTools.SCREEN_SIZE.x/2), int(GameTools.SCREEN_SIZE.y*0.9))
	disabled = false
	state = "idle"
	$wings.play("default_iframe")
	$body.set_modulate(Color(1,1,1,0.5))
	$wings.visible = true
	$wings.set_modulate(Color(1,1,1,0.5))

	iFrameTimer.set_wait_time(INVINCIBILITY_TIME)
	iFrameTimer.start()
	respawnTimer.stop()


func _on_body_animation_finished():
	if $body.animation == "death" and life == 0:
		emit_signal("player_dead")
	pass # Replace with function body.

# não vai ser usado, porque o libelo colide com marimba
func _on_Getting_Shot(from:KinematicBody2D):
	pass
