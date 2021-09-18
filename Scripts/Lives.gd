extends Node2D

var lives

func _ready():
	lives = 3

func decrease_lives():
	lives -= 1
	if lives < 3:
		$"3".visible = false
	if lives < 2:
		$"2".visible = false
	if lives < 1:
		$"1".visible = false
