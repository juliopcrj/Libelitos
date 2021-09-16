extends KinematicBody2D


onready var GameTools = preload("../Scripts/tools.gd").new()

var Projectile = preload("res://Scenes/Projectile.tscn")
onready var finalCountdown = get_node("FinalCountdown")

# explosion time
const MIN_TIME = 1.5
const MAX_TIME = 5.0

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
	$Sprite.playing = true
	finalCountdown.set_wait_time(explosion_timer)
	finalCountdown.start()

func _process(_delta):
	if finalCountdown.time_left < explosion_timer/4 and finalCountdown.time_left > 0:
		$Sprite.speed_scale = 2
	if GameTools.close_to(position, destination):
		movement = Vector2.ZERO
	# warning-ignore:return_value_discarded
	move_and_slide(movement)
	

func explode():
	$Sprite.speed_scale = 1
	$Sprite.play("megumin")
	var step = (PI * 2)/scatter_amount
	var root = get_tree().current_scene
	for i in range(scatter_amount):
		var _p = Projectile.instance()
		_p.aim(cos(step*i)*SCATTER_SPEED, sin(step*i)*SCATTER_SPEED)
		_p.position = self.global_position
		_p.set_enemy_fire("grenadier")
		root.add_child(_p)
		
	
func _on_FinalCountdown_timeout():
	explode()
	finalCountdown.stop()



func _on_Sprite_animation_finished():
	if $Sprite.animation == "megumin":
		queue_free()
