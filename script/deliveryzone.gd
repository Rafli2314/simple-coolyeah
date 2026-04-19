extends Area2D

func _on_body_entered(body):
	if body.has_method("drop_package"):
		print("📦 PLAYER MASUK ZONE — packages sebelum drop: ", body.packages.size())
		body.drop_package()
		print("✅ DROP DONE — packages setelah drop: ", body.packages.size())
	else:
		print("⚠️ body masuk tapi bukan player: ", body.name)
