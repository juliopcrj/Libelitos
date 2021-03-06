extends Node2D

onready var Marimba_Minigun = preload("../Scenes/Marimba_Minigun.tscn")
onready var Marimba_Grenadier = preload("../Scenes/Marimba_Grenadier.tscn")
onready var Marimba_Shotgun = preload("../Scenes/Marimba_Shotgun.tscn")
onready var marimbas = [Marimba_Minigun, Marimba_Shotgun, Marimba_Grenadier ]

onready var grenadier_timer = get_node("Grenadier")
onready var shotgun_timer = get_node("Shotgun")
onready var minigun_timer = get_node("Minigun")
onready var stage_timer = get_node("StageTimer")

var GRENADIER_SPAWN_TIME
var MINIGUN_SPAWN_TIME
var SHOTGUN_SPAWN_TIME
const STAGE_TIME = 120

var GRENADIER_SPAWN_AMOUNT
var MINIGUN_SPAWN_AMOUNT
var SHOTGUN_SPAWN_AMOUNT

var pos
var last_pos
var font

var score:int

func _ready():
	score = 0
	pos = randi() % 4
	last_pos = 0
	
	GRENADIER_SPAWN_TIME = 15
	MINIGUN_SPAWN_TIME = 5
	SHOTGUN_SPAWN_TIME = 10
	
	GRENADIER_SPAWN_AMOUNT = 1
	MINIGUN_SPAWN_AMOUNT = 1
	SHOTGUN_SPAWN_AMOUNT = 1

	
	grenadier_timer.set_wait_time(GRENADIER_SPAWN_TIME)
	shotgun_timer.set_wait_time(SHOTGUN_SPAWN_TIME)
	minigun_timer.set_wait_time(MINIGUN_SPAWN_TIME)
	stage_timer.set_wait_time(STAGE_TIME)
	
	grenadier_timer.start()
	shotgun_timer.start()
	minigun_timer.start()
	stage_timer.start()
	
#	font = DynamicFont.new()
#	font.font_data = load("res://Fonts/megaman_2.ttf")
#	font.size = 64
#	$Time.set("custom_fonts/font", font)

func _process(delta):
	$Labels/Time.text = String(int(stage_timer.time_left))
	$Labels/Score.text = String(score).pad_zeros(4)
	if ( not find_node("*Marimba*", true, false)) and $StageTimer.is_stopped():
		var score_file = File.new()
		score_file.open("user://score.dat", File.WRITE)
		score *= $Libelitos.get_life_multiplier()
		score_file.store_string(str(score))
		score_file.close()
		get_tree().change_scene("res://Scenes/Victory.tscn")

func spawn(which:int):
	var _m = marimbas[which].instance()
	randomize()
	_m.position = Vector2(20 + randi()%140, -100)
	if which == 2:
		pos = (pos +1 ) %4
		_m.set_start_position(pos)
		last_pos = pos
	add_child(_m)

func _on_Grenadier_timeout():
	for i in range(GRENADIER_SPAWN_AMOUNT):
		spawn(2)

	if stage_timer.time_left < 30:
		GRENADIER_SPAWN_AMOUNT = 3
		return
	if stage_timer.time_left < 75:
		GRENADIER_SPAWN_AMOUNT = 2
		return
	if stage_timer.time_left < 90:
		GRENADIER_SPAWN_AMOUNT = 1
		return
	if stage_timer.time_left < 105:
		GRENADIER_SPAWN_AMOUNT = 2
		return
	

func _on_Shotgun_timeout():
	for i in range(SHOTGUN_SPAWN_AMOUNT):
		spawn(1)
	if stage_timer.time_left < 30:
		SHOTGUN_SPAWN_AMOUNT = 3
		return
	if stage_timer.time_left < 60:
		SHOTGUN_SPAWN_AMOUNT = 2
		return

	if SHOTGUN_SPAWN_AMOUNT == 2:
		SHOTGUN_SPAWN_AMOUNT = 1
	else:
		 SHOTGUN_SPAWN_AMOUNT = 2



func _on_Minigun_timeout():
	for _i in range(MINIGUN_SPAWN_AMOUNT):
		spawn(0)

	MINIGUN_SPAWN_AMOUNT += 1
	if MINIGUN_SPAWN_AMOUNT >= 5:
		MINIGUN_SPAWN_AMOUNT = 1
	
	if stage_timer.time_left < 60:
		if MINIGUN_SPAWN_AMOUNT == 1:
			MINIGUN_SPAWN_AMOUNT = 2

	if stage_timer.time_left < 30:
		if MINIGUN_SPAWN_AMOUNT == 2:
			MINIGUN_SPAWN_AMOUNT = 3

func _on_StageTimer_timeout():
	grenadier_timer.stop()
	shotgun_timer.stop()
	minigun_timer.stop()
	stage_timer.stop()

func _on_player_shindeiru():
	get_tree().change_scene("res://Scenes/GameOver.tscn")

func increase_score(s):
	score += s
