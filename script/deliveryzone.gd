extends Area2D

signal package_delivered(pkg)

func _on_body_entered(body):
	if body.has_method("drop_package") and not body.packages.is_empty():
		var pkg = body.packages.pop_back()
		body.carried_packages = body.get_total_weight()
		emit_signal("package_delivered", pkg)
		# connect signal ini ke GameManager buat hitung score/kuota
