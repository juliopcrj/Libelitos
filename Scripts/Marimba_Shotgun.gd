extends KinematicBody2D

var SCREEN_SIZE = Vector2(ProjectSettings.get("display/window/size/width"),
						  ProjectSettings.get("display/window/size/height"))

var Projectile = preload("res://Scenes/Projectile.tscn")
onready var shotTimer = get_node("ShotTimer")

const SHOTS_PER_SECOND = 1.5
const BULLET_SPEED = 200

var life:int
var can_shoot:bool

# Called when the node enters the scene tree for the first time.
func _ready():
	can_shoot = true
	life = 2

func fire():
	if can_shoot:
		var _p = Projectile.instance()
		_p.aim(0, BULLET_SPEED)
		_p.global_position = self.global_position
		_p.set_enemy_fire()
		var main = get_tree().current_scene
		main.add_child(_p)
		shotTimer.set_wait_time(1/SHOTS_PER_SECOND)
		shotTimer.start()
		can_shoot = false

func _process(_delta):
	move_and_slide(Vector2.ZERO)
	fire()
	if(get_slide_count()):
		if(get_slide_collision(0).collider.name != "Libelitos"):
			take_damage()
	
func take_damage():
	life -= 1
	if life == 0:
		queue_free()

func _on_ShotTimer_timeout():
	can_shoot = true
	shotTimer.stop()
