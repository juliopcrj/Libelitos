extends KinematicBody2D

var SCREEN_SIZE = Vector2(ProjectSettings.get("display/window/size/width"),
						  ProjectSettings.get("display/window/size/height"))

onready var shotTimer = get_node("ShotTimer")

signal grenade_launched


const GRENADE_WAIT_LAUNCH = 3.0
const BULLET_SPEED = 200

var life:int
var can_shoot:bool


# Called when the node enters the scene tree for the first time.
func _ready():
	can_shoot = false
	connect("grenade_launched", $Grenade, "prepare")
	shotTimer.set_wait_time(GRENADE_WAIT_LAUNCH)
	shotTimer.start()
	
	life = 2

func fire():
	emit_signal("grenade_launched")
	var root = get_tree().current_scene
	var node = get_node("Grenade")
	node.position = self.global_position
	remove_child(node)
	root.add_child(node)
	can_shoot = false

func _process(_delta):
	# warning-ignore:return_value_discarded
	move_and_slide(Vector2.ZERO)
	if can_shoot:
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
