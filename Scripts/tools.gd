const PROXIMITY = 15
const BORDER = 15

var SCREEN_SIZE = Vector2(ProjectSettings.get("display/window/size/width"),
						  ProjectSettings.get("display/window/size/height"))

const LONGE_PRA_CARALHO = Vector2(-1000, -1000)

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

func _aux_enframe(num, lower, upper):
	if num < lower:
		return lower
	if num > upper:
		return upper
	return num

func enframe(vec:Vector2)->Vector2:
	vec.x = _aux_enframe(vec.x, BORDER, SCREEN_SIZE.x - BORDER)
	vec.y = _aux_enframe(vec.y, BORDER, SCREEN_SIZE.y - BORDER)
	return vec
	

func distance(v1:Vector2, v2:Vector2)->float:
	return sqrt((v1.x-v2.x)*(v1.x-v2.x) + (v1.y-v2.y)*(v1.y-v2.y))

func _quadratic_bezier(p0:Vector2, p1:Vector2, p2:Vector2, t:float):
	var q0 = p0.linear_interpolate(p1,t)
	var q1 = p1.linear_interpolate(p2,t)
	return q0.linear_interpolate(q1,t)
