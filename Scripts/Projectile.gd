extends KinematicBody2D

var velocity = Vector2()
var SCREEN_SIZE = Vector2(ProjectSettings.get("display/window/size/width"),
						  ProjectSettings.get("display/window/size/height"))

signal shot_hit

func aim(x, y):
	velocity.x = x
	velocity.y = y

func _physics_process(_delta):
	self.move_and_slide(velocity)

	if get_slide_count() > 0:
		var target = get_slide_collision(0).collider
		connect("shot_hit", target, "_on_Getting_Shot")
		emit_signal("shot_hit", self)
	
	if (self.position.y < 0 || self.position.y > SCREEN_SIZE.y ||
	 self.position.x < 0 || self.position.x > SCREEN_SIZE.x) :
		queue_free()

func set_player_fire(type:String):
	$Sprite.play(type)
	if type == "libelito":
		$libelito.disabled = false
		self.set_collision_layer_bit(2,true)
		self.set_collision_mask_bit(1, true)

func set_enemy_fire(enemy:String):
	$Sprite.play(enemy)
	if enemy == "grenadier":
		$grenadier.disabled = false
	elif enemy == "minigun":
		$minigun.disabled = false
	else:
		$shotgun.disabled = false
	self.set_collision_layer_bit(3,true)
	self.set_collision_mask_bit(0, true)

func _on_Shot_Processed():
	queue_free()

func set_color(c:Color):
	$Sprite.set_modulate(c)
