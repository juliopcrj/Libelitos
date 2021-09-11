extends KinematicBody2D

const velocity = Vector2()


func _ready():
	velocity.y = -300
	pass
	
func prepare(x, y):
	velocity.x = x
	velocity.y = y

func _physics_process(delta):
	if(position.y < 0):
		queue_free()
	move_and_slide(velocity)
