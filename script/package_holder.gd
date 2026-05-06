extends Marker2D

func update_package_positions():
	for i in range(get_child_count()):
		var pkg = get_child(i)
		pkg.position = Vector2(0, -16 * i)
