const PROXIMITY = 5

var SCREEN_SIZE = Vector2(ProjectSettings.get("display/window/size/width"),
						  ProjectSettings.get("display/window/size/height"))

func calculate_movement(pos:Vector2, dest:Vector2)->Vector2:
	return dest-pos

func close_to(pos:Vector2, dest:Vector2)->bool:
	if(abs(pos.x - dest.x) < PROXIMITY
	and abs(pos.y - dest.y) < PROXIMITY):
		return true
	return false
	
func normalize(vec:Vector2)->Vector2:
	var big = max(abs(vec.x), abs(vec.y))
	return vec/big
