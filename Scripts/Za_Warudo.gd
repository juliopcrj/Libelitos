extends Node2D

onready var Marimba_Minigun = preload("../Scenes/Marimba_Minigun.tscn")
onready var Marimba_Grenadier = preload("../Scenes/Marimba_Grenadier.tscn")
onready var Marimba_Shotgun = preload("../Scenes/Marimba_Shotgun.tscn")
onready var marimbas = [Marimba_Minigun, Marimba_Shotgun, Marimba_Grenadier ]

onready var spawnTimer = get_node("SpawnTimer")
const SPAWN_TIME = 5

func _ready():
	spawnTimer.set_wait_time(SPAWN_TIME)
	#spawnTimer.start()

func spawn():
	var which =  randi() % 2
	var _m = marimbas[which].instance()
	_m.position = Vector2(90, -100)
	add_child(_m)

func _on_SpawnTimer_timeout():
	spawn()


