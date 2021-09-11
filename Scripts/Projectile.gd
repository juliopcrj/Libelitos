extends KinematicBody2D

const velocity = Vector2()


func _ready():
	velocity.y = -300
	pass
	
func prepare(x, y):
	velocity.x = x
	velocity.y = y

func _physics_process(delta):
	if(position.y < 0) || get_slide_count() == 1:
		queue_free()
	move_and_slide(velocity)
	#for i in range(get_slide_count() -1 ):
	#	print(get_slide_collision(i))
		
func set_player_fire():
	set_collision_layer_bit(2,true)
	set_collision_mask_bit(1, true)

func set_enemy_fire():
	set_collision_layer_bit(3,true)
	set_collision_mask_bit(0, true)
