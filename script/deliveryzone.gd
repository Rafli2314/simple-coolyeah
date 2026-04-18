extends Area2D

func _on_body_entered(body):
	if body.has_method("drop_package"):
		body.drop_package()

func drop_package() -> Node:  # return pkg-nya
	if packages.is_empty(): return null
	var pkg = packages.pop_back()
	carried_packages = get_total_weight()
	return pkg
