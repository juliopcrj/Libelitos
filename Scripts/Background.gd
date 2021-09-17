extends Node2D

func _process(delta):
	$bg1.position.y += 0.5
	$bg2.position.y += 0.5
	$bg3.position.y += 0.5
	
	if($bg1.position.y > 480):
		$bg1.position.y = -160
	if($bg2.position.y > 480):
		$bg2.position.y = -160
	if($bg3.position.y > 480):
		$bg3.position.y = -160
