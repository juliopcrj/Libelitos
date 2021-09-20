extends Node2D

func _ready():
	var score_file = File.new()
	score_file.open("user://score.dat", File.READ)
	var score = score_file.get_as_text()
	score_file.close()

	$Score.text = String(score).pad_zeros(4)


func _process(_delta):
	if Input.is_action_just_pressed("player_shoot"):
		get_tree().change_scene("res://Scenes/StartMenu.tscn")
