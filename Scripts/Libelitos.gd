extends KinematicBody2D

var Projectile = preload("res://Scenes/Projectile.tscn")



func _physics_process(delta):
	process_inputs()

func process_inputs():
	if(Input.is_action_pressed("ui_select")):
		fire()
	var horizontal = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	var vertical = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	move_and_slide(Vector2(horizontal, vertical))

func fire():
	var _p = Projectile.instance()
	_p.collision_layer # = 2
	_p.set_collision_layer_bit(0b0100)
	_p.set_collision_mask_bit(0b0010)
	var main = get_tree().current_scene
	_p.global_position = self.global_position
	main.add_child(_p)

