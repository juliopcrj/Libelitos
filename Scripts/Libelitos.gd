extends KinematicBody2D

var Projectile = preload("res://Scenes/Projectile.tscn")
var Shot_Sound = preload("res://Sounds/shot.wav")


const bullets_per_second = 5.0
const invincibility_time = 2
const speed = Vector2()
const BULLET_SPEED = -300.0

var invincible:bool
var life:int
var can_shoot = true

onready var bulletTimer = get_node("bulletTimer")
onready var iFrameTimer = get_node("iFrameTimer")

func _ready():
	$AudioStreamPlayer2D.stream = Shot_Sound
	$AudioStreamPlayer2D.volume_db = -10
	life = 3
	invincible = false
	speed.x = 200
	speed.y = 200
	

func _physics_process(delta):
	process_inputs()

func process_inputs():
	if(Input.is_action_pressed("ui_select")):
		fire()
	var horizontal = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var vertical = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	horizontal = horizontal * speed.x
	vertical = vertical * speed.y
	move_and_slide(Vector2(horizontal, vertical))
	if get_slide_count() > 0:
		for i in range(get_slide_count()):
			if get_slide_collision(i).collider.name.count("Marimba")>0:
				kamikaze()
		take_damage()

func fire():
	if(can_shoot):
		$AudioStreamPlayer2D.play(0)
		var _p = Projectile.instance()
		#_p.velocity = Vector2(0, BULLET_SPEED)
		_p.aim(0, BULLET_SPEED)
		_p.set_player_fire()
		var main = get_tree().current_scene
		_p.global_position = self.global_position
		main.add_child(_p)
		can_shoot = false
		bulletTimer.set_wait_time(1/bullets_per_second)
		bulletTimer.start()

func take_damage():
	if not invincible:
		life -=1
		iFrameTimer.set_wait_time(invincibility_time)
		iFrameTimer.start()
		if life == 0:
			die()
		
		$CollisionShape2D.disabled = true
		invincible = true
		
func kamikaze():
	if not invincible:
		die()

func die():
	queue_free()
	
	#do something to restart

func _on_bulletTimer_timeout():
	can_shoot = true
	bulletTimer.stop()


func _on_iFrameTimer_timeout():
	invincible = false
	$CollisionShape2D.disabled = false
	iFrameTimer.stop()
