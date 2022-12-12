extends Area2D

func is_colliding():
	var areas = get_overlapping_areas()
	return areas.size() > 0

func get_push_vec():
	var areas = get_overlapping_areas()
	var push_vec = Vector2.ZERO
	if is_colliding():
		var area = areas[0]
		push_vec = area.global_position.direction_to(global_position)
		push_vec = push_vec.normalized()
	return push_vec
