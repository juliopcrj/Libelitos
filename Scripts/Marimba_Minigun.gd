extends KinematicBody2D

#var SCREEN_SIZE = Vector2(ProjectSettings.get("display/window/size/width"),
#						  ProjectSettings.get("display/window/size/height"))
const _t = preload("res://Scripts/tools.gd")
var GameTools = _t.new()

var Projectile = preload("res://Scenes/Projectile.tscn")
onready var shotTimer = get_node("ShotTimer")
onready var moveTimer = get_node("MoveTimer")
onready var reloadTimer = get_node("ReloadTimer")

const SHOTS_PER_SECOND = 3.0
const BULLET_SPEED = 120
const MOVE_WAIT_TIME = 3
const MOVEMENT_SPEED = 200
const RELOAD_TIME = 2
const BRAKE_DISTANCE = 0.60


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
# Called when the node enters the scene tree for the first time.
func _ready():
	can_shoot = true
	can_move = true
	randomize()
	max_shots = randi() % 10 + 5
	life = 3
	spent_shots = 0
	state = "idle"
	$body.playing = true
	$wings.frame = randi()%4
	$wings.playing = true

func fire():
	if can_shoot:
		state = "shooting"
		var _p = Projectile.instance()
		_p.aim(0, BULLET_SPEED)
		_p.global_position = self.global_position + Vector2(-10, 5)
		_p.set_enemy_fire()
		var main = get_tree().current_scene
		main.add_child(_p)
		_p = Projectile.instance()
		_p.aim(0, BULLET_SPEED)
		_p.global_position = self.global_position + Vector2(10, 5)
		_p.set_enemy_fire()
		main.add_child(_p)
		spent_shots += 2
		shotTimer.set_wait_time(1/SHOTS_PER_SECOND)
		shotTimer.start()
		can_shoot = false
		if spent_shots >= max_shots:
			state = "idle"
			reloadTimer.set_wait_time(RELOAD_TIME)
			reloadTimer.start()
		

# warning-ignore:unused_argument
func _process(delta):
# warning-ignore:return_value_discarded
	behave()
	move_and_slide(movement)
		
	if(get_slide_count()):
		if(get_slide_collision(0).collider.name != "Libelitos"):
			take_damage()

	if $body.animation != state:
		$body.play(state)
	
func take_damage():
	life -= 1
	if life == 0:
		queue_free()
	pass

#defining minigun marimba's behavior
func behave():
	if GameTools.close_to(position, destination):
		movement = Vector2.ZERO
	elif GameTools.distance(position,destination) < GameTools.distance(startPoint, destination) * (1-BRAKE_DISTANCE):
		movement = startSpeed - (startSpeed/2 * (
			GameTools.distance(brakePoint, position)/
			GameTools.distance(brakePoint, destination)
		))
	if can_move:
		startPoint = position
		
		destination = Vector2(abs(float(randi() % int(GameTools.SCREEN_SIZE.x) - $Sprite.texture.get_width())),
							 abs(float(randi() % int(GameTools.SCREEN_SIZE.y) - $Sprite.texture.get_height())))
		
		movement = GameTools.normalize(destination - position) * MOVEMENT_SPEED
		startSpeed = movement
		brakePoint = (destination - position) * BRAKE_DISTANCE
			
		can_move = false
		moveTimer.set_wait_time(MOVE_WAIT_TIME)
		moveTimer.start()

	if spent_shots < max_shots:
		fire()

func _on_ShotTimer_timeout():
	can_shoot = true
	shotTimer.stop()

func _on_MoveTimer_timeout():
	can_move = true
	moveTimer.stop()

func _on_ReloadTimer_timeout():
	spent_shots = 0
	reloadTimer.stop()
