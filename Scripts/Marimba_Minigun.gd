extends KinematicBody2D

var SCREEN_SIZE = Vector2(ProjectSettings.get("display/window/size/width"),
						  ProjectSettings.get("display/window/size/height"))


var Projectile = preload("res://Scenes/Projectile.tscn")
onready var shotTimer = get_node("ShotTimer")
onready var moveTimer = get_node("MoveTimer")

const SHOTS_PER_SECOND = 5.0
const BULLET_SPEED = 200
const MOVE_WAIT_TIME = 3
const MOVEMENT_SPEED = 200

var life:int
var can_shoot:bool
var can_move:bool
var destination = Vector2.ZERO
var movement = Vector2.ZERO
var max_shots:int
var spent_shots


# Called when the node enters the scene tree for the first time.
func _ready():
	can_shoot = true
	can_move = true
	randomize()
	max_shots = randi() % 10 + 5
	life = 3
	spent_shots = 0

func fire():
	if can_shoot:
		var _p = Projectile.instance()
		_p.aim(0, BULLET_SPEED)
		_p.global_position = self.global_position
		_p.set_enemy_fire()
		var main = get_tree().current_scene
		main.add_child(_p)
		spent_shots += 1
		shotTimer.set_wait_time(1/SHOTS_PER_SECOND)
		shotTimer.start()
		can_shoot = false

# warning-ignore:unused_argument
func _process(delta):
# warning-ignore:return_value_discarded
	behave()
	move_and_slide(movement)
	if spent_shots < max_shots:
		fire()
		
	if(get_slide_count()):
		if(get_slide_collision(0).collider.name != "Libelitos"):
			take_damage()
	
func take_damage():
	life -= 1
	if life == 0:
		queue_free()
	pass

func close_to(pos:Vector2, dest:Vector2)->bool:
	if(abs(pos.x - dest.x) < 1.5
	and abs(pos.y - dest.y) < 1.5):
		return true
	return false
	
func normalize(vec:Vector2)->Vector2:
	var big = max(abs(vec.x), abs(vec.y))
	return vec/big

#defining minigun marimba's behavior
func behave():
	if close_to(position, destination):
		movement = Vector2.ZERO
	if can_move:
		destination = Vector2(abs(float(randi() % int(SCREEN_SIZE.x) - $Sprite.texture.get_width())),
							 abs(float(randi() % int(SCREEN_SIZE.y) - $Sprite.texture.get_height())))
		
		movement =  normalize(destination - position) * MOVEMENT_SPEED
			
		can_move = false
		moveTimer.set_wait_time(3)
		moveTimer.start()

func _on_ShotTimer_timeout():
	can_shoot = true
	shotTimer.stop()

func _on_MoveTimer_timeout():
	can_move = true
	moveTimer.stop()
	
