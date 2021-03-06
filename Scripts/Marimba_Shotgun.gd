extends KinematicBody2D

const _t = preload("res://Scripts/tools.gd")
var GameTools = _t.new()

var Projectile = preload("res://Scenes/Projectile.tscn")
var Shot_Sound = load("res://Sounds/shot_marimba.wav")
onready var shotTimer = get_node("ShotTimer")
onready var moveTimer = get_node("MoveTimer")
onready var reloadTimer = get_node("ReloadTimer")
onready var blinkTimer = get_node("BlinkTimer")
onready var secondShotTimer = get_node("SecondShotTimer")

const SHOTS_PER_SECOND = 0.5
const BULLET_SPEED = 80
const MOVE_WAIT_TIME = 3
const MOVEMENT_SPEED = 50
const RELOAD_TIME = 4
const BRAKE_DISTANCE = 0.60
const BLINK_TIME = 0.08
const SPREAD_AMOUNT = 6

signal on_shot_processed
signal killed

var score = 5
var life:int
var can_shoot:bool
var can_move:bool
var destination = Vector2.ZERO
var movement = Vector2.ZERO
var max_shots:int
var spent_shots
var state
var startPoint:Vector2
var startSpeed:Vector2
var brakePoint:Vector2
var position_left:Vector2
var position_right:Vector2
var wait_time_to_shoot
var initial_time

# Called when the node enters the scene tree for the first time.
func _ready():
	initial_time = OS.get_unix_time()
	$Audio.stream = Shot_Sound
	$Audio.volume_db = -10
	position_left = Vector2(30,30)
	position_right = Vector2(150,30)
	can_shoot = false
	can_move = true
	randomize()
	wait_time_to_shoot = randf()*2
	shotTimer.set_wait_time(wait_time_to_shoot)
	shotTimer.start()
	max_shots = 2
	life = score
	spent_shots = 0
	state = "idle"
	$body.playing = true
	$wings.frame = randi()%4
	$wings.playing = true
	connect("killed", get_parent(), "increase_score")

func fire():
	if can_shoot:
		$Audio.play(0)
		var step = (PI * 2) /(SPREAD_AMOUNT * 6)
		var root = get_tree().current_scene
		for i in range(SPREAD_AMOUNT, SPREAD_AMOUNT*2 + 1):
			var _p = Projectile.instance()
			_p.aim(cos(step*i)*BULLET_SPEED, sin(step*i)*BULLET_SPEED)
			_p.position = self.global_position + Vector2(-10,15) # "gun" position
			_p.set_enemy_fire("shotgun")
			root.add_child(_p)
		state = "shooting"
		spent_shots += 2
		secondShotTimer.set_wait_time(0.66667)
		secondShotTimer.start()
		shotTimer.set_wait_time(1/SHOTS_PER_SECOND)
		shotTimer.start()
		can_shoot = false
		if spent_shots >= max_shots:
			reloadTimer.set_wait_time(RELOAD_TIME)
			reloadTimer.start()
		

# warning-ignore:unused_argument
func _process(delta):
# warning-ignore:return_value_discarded
	if life > 0:
		behave()
		move_and_slide(movement)

		if $body.animation != state:
			$body.play(state)
	
func take_damage():
	life -= 1
	if life == 0:
		die()
	else:
		$body.set_modulate(Color(1,0,0,1))
		blinkTimer.set_wait_time(BLINK_TIME)
		blinkTimer.start()

func die():
	var elapsed = OS.get_unix_time() - initial_time
	if elapsed > 10:
		score *= 3
	elif elapsed > 5:
		score *= 2
	emit_signal("killed", score)
	$wings.play("death")
	$body.play("death")
	$CollisionShape2D.disabled= true


#defining minigun marimba's behavior
func behave():
	if GameTools.close_to(position, destination):
		movement = Vector2.ZERO
		if spent_shots < max_shots:
			fire()
#	elif GameTools.distance(position,destination) < GameTools.distance(startPoint, destination) * (1-BRAKE_DISTANCE):
#		movement = startSpeed - (startSpeed/2 * (
#			GameTools.distance(brakePoint, position)/
#			GameTools.distance(brakePoint, destination)
#		))
	if can_move:
		startPoint = position
		
		destination.y  = position_right.y
		destination.x = position_left.x + (position_right.x - position_left.x)*randf()
		
		movement = GameTools.normalize(destination - position) * MOVEMENT_SPEED
		startSpeed = movement
		brakePoint = (destination - position) * BRAKE_DISTANCE
			
		can_move = false
		moveTimer.set_wait_time(MOVE_WAIT_TIME)
		moveTimer.start()


func _on_ShotTimer_timeout():
	can_shoot = true
	shotTimer.stop()

func _on_MoveTimer_timeout():
	can_move = true
	moveTimer.stop()

func _on_ReloadTimer_timeout():
	spent_shots = 0
	reloadTimer.stop()

func _on_Getting_Shot(from:KinematicBody2D):
	take_damage()
	connect("on_shot_processed", from, "_on_Shot_Processed")
	emit_signal("on_shot_processed")

func _on_BlinkTimer_timeout():
	$body.set_modulate(Color(1,1,1,1))
	blinkTimer.stop()

func _on_SecondShotTimer_timeout():
	$Audio.play(0)
	var step = (PI * 2) /(SPREAD_AMOUNT * 6)
	var root = get_tree().current_scene
	for i in range(SPREAD_AMOUNT, SPREAD_AMOUNT*2 + 1):
		var _p = Projectile.instance()
		_p.aim(cos(step*i)*BULLET_SPEED, sin(step*i)*BULLET_SPEED)
		_p.position = self.global_position + Vector2(10,15) # "gun" position
		_p.set_enemy_fire("shotgun")
		root.add_child(_p)	
	secondShotTimer.stop()

func _on_body_animation_finished():
	if $body.animation == "death":
		queue_free()
	if $body.animation == "shooting":
		state = "idle"

func _on_BG_Song_finished():
	print("terminou")
	$BG_song.play(0)
