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

const GRENADE_WAIT_LAUNCH = 3.0
const BULLET_SPEED = 200
const DEATH_TIME = 1.02
const BLINK_TIME = 0.08
const FLEE_TIME = 4 #seconds duh
const THROW_TIME = 0.72

var life:int
var can_shoot:bool
var movement:Vector2
var state
var has_grenade:bool

# Called when the node enters the scene tree for the first time.
func _ready():
	has_grenade = true
	can_shoot = false
	state = "idle"
	$wings.playing = true
	$body.playing = true
	connect("grenade_launched", $Grenade, "prepare")
	shotTimer.set_wait_time(GRENADE_WAIT_LAUNCH)
	shotTimer.start()
	
	life = 4

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
		behave()
		move_and_slide(movement)
		if $body.animation != state:
			$body.play(state)


func behave():
	if can_shoot:
		state = "throw"
		can_shoot = false
		throwTimer.set_wait_time(THROW_TIME)
		throwTimer.start()
	if state == "fleeing":
		movement = Vector2(0, -100)
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
	if has_grenade:
		$wings.play("death")
		$body.play("death_with_grenade")
	else:
		$wings.play("death_wo_grenade")
		$body.play("death_wo_grenade")
	$CollisionShape2D.disabled= true
	deathTimer.set_wait_time(DEATH_TIME)
	deathTimer.start()

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
	pass # Replace with function body.
