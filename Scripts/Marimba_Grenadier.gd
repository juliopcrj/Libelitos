extends KinematicBody2D

const _t = preload("res://Scripts/tools.gd")
var GameTools = _t.new()

onready var shotTimer = get_node("ShotTimer")
onready var deathTimer = get_node("DeathTimer")
onready var blinkTimer = get_node("BlinkTimer")
onready var fleeTimer = get_node("FleeTimer")
onready var throwTimer = get_node("ThrowTimer")

signal grenade_launched
signal on_shot_processed
signal killed

const GRENADE_WAIT_LAUNCH = 3.0
const BULLET_SPEED = 200
const DEATH_TIME = 1.02
const BLINK_TIME = 0.08
const FLEE_TIME = 4 #seconds duh
const THROW_TIME = 0.72
const MOVEMENT_SPEED = 100
const PREPARE_RATE = 0.5

var score = 4
var life:int
var can_shoot:bool
var movement:Vector2
var state
var has_grenade:bool
var start_point:Vector2
var end_point:Vector2
var mid_point:Vector2
var bezier_delta:float


# Called when the node enters the scene tree for the first time.
func _ready():
	has_grenade = true
	can_shoot = false
	$wings.playing = true
	$body.playing = true
	connect("grenade_launched", $Grenade, "prepare")
	life = 4
	bezier_delta = 0
	connect("killed", get_parent(), "increase_score")

func set_start_position(n:int): #0,1,2,3 = LU, RU, LD, RD
	state = "preparing"
	if n == 0:
		position = Vector2(-20,-20)
		end_point = Vector2(160,280)
	elif n == 1:
		position = Vector2(200, -20)
		end_point = Vector2(20,280)
	elif n == 2:
		position = Vector2(-20, 340)
		end_point = Vector2(160,30)
	elif n == 3:
		position = Vector2(200, 340)
		end_point = Vector2(20,30)

	start_point = position

	if position.y < 0:
		mid_point = Vector2(end_point.x, start_point.y)
	else:
		mid_point = Vector2(start_point.x, end_point.y)


func fire():
	emit_signal("grenade_launched")
	var root = get_tree().current_scene
	var node = get_node("Grenade")
	node.position = self.global_position + Vector2(14, 7)
	node.visible = true
	remove_child(node)
	root.add_child(node)
	has_grenade = false


func _process(_delta):
	# warning-ignore:return_value_discarded
	if life > 0:
		behave(_delta)
		move_and_slide(movement)
		if state != "preparing":
			if $body.animation != state:
				$body.play(state)


func behave(_delta):
	if state == "preparing":
		if GameTools.close_to(position, end_point):
			state = "idle"
			shotTimer.set_wait_time(GRENADE_WAIT_LAUNCH)
			shotTimer.start()

		position = GameTools._quadratic_bezier(start_point, mid_point, end_point, bezier_delta)
		bezier_delta += (_delta * PREPARE_RATE)

		return
	if can_shoot:
		state = "throw"
		can_shoot = false
		throwTimer.set_wait_time(THROW_TIME)
		throwTimer.start()
	if state == "fleeing":
		movement = Vector2(0, -1) * MOVEMENT_SPEED
		if GameTools.close_to(Vector2(position.x, -200), position):
			queue_free()

func take_damage():
	life -= 1
	if life == 0:
		die()
	else:
		$body.set_modulate(Color(1,0,0,1))
		blinkTimer.set_wait_time(BLINK_TIME)
		blinkTimer.start()

func die():
	if state == "throw":
		score *= 2
	if state == "fleeing" and position.y < 30:
		score *= 3
	emit_signal("killed", score)
	if has_grenade:
		$wings.play("death")
		$body.play("death_with_grenade")
	else:
		$wings.play("death")
		$body.play("death_wo_grenade")
	$CollisionShape2D.disabled= true
#	deathTimer.set_wait_time(DEATH_TIME)
#	deathTimer.start()

func _on_Getting_Shot(from:KinematicBody2D):
	take_damage()
	connect("on_shot_processed", from, "_on_Shot_Processed")
	emit_signal("on_shot_processed")

func _on_ShotTimer_timeout():
	can_shoot = true
	shotTimer.stop()

func _on_DeathTimer_timeout():
	queue_free()
	deathTimer.stop()

func _on_BlinkTimer_timeout():
	$body.set_modulate(Color(1,1,1,1))
	blinkTimer.stop()

func _on_FleeTimer_timeout():
	state = "fleeing"
	fleeTimer.stop()


func _on_ThrowTimer_timeout():
	fire()
	throwTimer.stop()
	fleeTimer.set_wait_time(FLEE_TIME)
	fleeTimer.start()


func _on_body_animation_finished():
	if state == "throw":
		state = "idle_wo_grenade"
	if $body.animation == "death_with_grenade" or $body.animation == "death_wo_grenade":
		queue_free()
