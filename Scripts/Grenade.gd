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


const MAX_SPEED = 150

var explosion_timer:float
var movement:Vector2
var destination:Vector2
var scatter_amount:int
var speed:float

func prepare():
	randomize()
	explosion_timer = MIN_TIME + randf()*(MAX_TIME-MIN_TIME)
	speed = MAX_SPEED #may be changed to random
	scatter_amount = randi()%(MAX_SCATTER-MIN_SCATTER) + MIN_SCATTER
	destination = GameTools.enframe(Vector2(randf()*GameTools.SCREEN_SIZE.x, randf()*GameTools.SCREEN_SIZE.y))
	movement = GameTools.normalize(destination - global_position) * speed
	finalCountdown.set_wait_time(explosion_timer)
	finalCountdown.start()

func _process(_delta):
	if GameTools.close_to(position, destination):
		movement = Vector2.ZERO
	# warning-ignore:return_value_discarded
	move_and_slide(movement)
	

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
