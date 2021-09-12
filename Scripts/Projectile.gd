extends KinematicBody2D

var velocity = Vector2()
var SCREEN_SIZE = Vector2(ProjectSettings.get("display/window/size/width"),
						  ProjectSettings.get("display/window/size/height"))

func aim(x, y):
	velocity.x = x
	velocity.y = y

func _physics_process(delta):
	if(self.position.y < 0) || self.position.y > SCREEN_SIZE.y || self.get_slide_count() == 1:
		queue_free()
	self.move_and_slide(velocity)
	#for i in range(get_slide_count() -1 ):
	#	print(get_slide_collision(i))
		
func set_player_fire():
	self.set_collision_layer_bit(2,true)
	self.set_collision_mask_bit(1, true)

func set_enemy_fire():
	self.set_collision_layer_bit(3,true)
	self.set_collision_mask_bit(0, true)
