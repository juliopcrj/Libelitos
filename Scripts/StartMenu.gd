extends Node2D

func _process(delta):
	if Input.is_action_just_pressed("player_shoot"):
		get_tree().change_scene("res://Scenes/Instructions.tscn")

