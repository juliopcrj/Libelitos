extends KinematicBody2D

#var SCREEN_SIZE = Vector2(ProjectSettings.get("display/window/size/width"),
#						  ProjectSettings.get("display/window/size/height"))
						
onready var GameTools = preload("../Scripts/tools.gd").new()

var Projectile = preload("res://Scenes/Projectile.tscn")
onready var finalCountdown = get_node("FinalCountdown")

# explosion time
const MIN_TIME = 1.5
const MAX_TIME = 3.0

# scatter shots
const MIN_SCATTER = 10
const MAX_SCATTER = 20
const SCATTER_SPEED = 100

const MAX_SPEED = 200.0

var explosion_timer:float
var movement:Vector2
var scatter_amount:int
var speed:float

func _ready():
	randomize()
	explosion_timer = MIN_TIME + randf()*(MAX_TIME-MIN_TIME)
	speed = randf()*MAX_SPEED
	scatter_amount = randi()%(MAX_SCATTER-MIN_SCATTER) + MIN_SCATTER
	movement = Vector2.ZERO
	#movement = GameTools.normalize(Vector2(randf()*GameTools.SCREEN_SIZE.x, randf()*GameTools.SCREEN_SIZE.y)) * speed
	finalCountdown.set_wait_time(explosion_timer)
	finalCountdown.start()

func _process(delta):
	move_and_slide(movement)
	pass

func explode():
	var step = (PI * 2)/scatter_amount
	var root = get_tree().current_scene
	for i in range(scatter_amount):
		var _p = Projectile.instance()
		_p.aim(cos(step*i)*SCATTER_SPEED, sin(step*i)*SCATTER_SPEED)
		_p.position = self.global_position
		_p.set_enemy_fire()
		root.add_child(_p)
		
	
func _on_FinalCountdown_timeout():
	explode()
	finalCountdown.stop()
	queue_free()
