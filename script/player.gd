extends CharacterBody2D

# === CONFIG ===
@export var max_speed: float = 400.0
@export var acceleration: float = 800.0
@export var friction: float = 400.0      # base friction (tanpa paket)
@export var max_packages: int = 3
var packages: Array = []  # isi PackageType
var nearby_packages: Array = []
@onready var anim = $AnimationPlayer
# === STATE ===
var nearby_package: Node = null  # paket yang lagi deket
var is_picking_up = false
var pending_package = null
var is_dropping = false

# Makin banyak paket = friction makin kecil (lebih susah berhenti)
func get_current_friction() -> float:
	var weight_factor = 1.0 - (get_total_weight() * 0.25)  # -25% per paket
	return friction * clamp(weight_factor, 0.25, 1.0)

# Makin banyak paket = speed max berkurang
func get_current_max_speed() -> float:
	return max_speed - (get_total_weight() * 30.0)  # -30 per paket

func _physics_process(delta: float) -> void:
	nearby_package = get_closest_package()
	var input_dir = Vector2(
		Input.get_axis("ui_left", "ui_right"),
		Input.get_axis("ui_up", "ui_down")
	).normalized()
	# Input pickup/drop
	if Input.is_action_just_pressed("pick-package") and not is_picking_up:# ganti key sesuai selera
		print(pickup)
		if nearby_package and can_pickup(nearby_package):
			is_picking_up = true
			pending_package = nearby_package
			anim.play("pick_package")
		elif not packages.is_empty():
			is_picking_up = true
			is_dropping = true
			pending_package = null
			anim.play("drop_package")

	if input_dir != Vector2.ZERO:
		# Accelerate
		velocity = velocity.move_toward(
			input_dir * get_current_max_speed(),
			acceleration * delta
		)
	else:
		# Decelerate (inertia effect di sini!)
		velocity = velocity.move_toward(
			Vector2.ZERO,
			get_current_friction() * delta
		)
	if is_picking_up: return
	_update_animation()
		
	move_and_slide()
	
var last_direction: float = 1.0  # simpan arah terakhir
	
	
func _update_animation() -> void:
	var input_x = Input.get_axis("ui_left", "ui_right")
	if velocity.length() > 10.0:
		if input_x < 0:
			if anim.current_animation != "walk_left":
				anim.play("walk_left")
		elif input_x > 0:
			if anim.current_animation != "walk_right":
				anim.play("walk_right")
	else:
		if anim.current_animation != "idle":
			anim.play("idle")
	if input_x != 0:
		last_direction = sign(input_x)
	
func get_total_weight() -> int:
	var total = 0
	for pkg in packages:
		total += pkg.get_weight()
	print(total)
	return total
	
func can_pickup(pkg) -> bool:
	return get_total_weight() + pkg.get_weight() <= max_packages

func pickup(pkg):
	if pkg == null:
		return

	if pkg.get_parent() == null:
		return

	packages.append(pkg)

	pkg.reparent($PackageHolder)

	pkg.position = Vector2(0, -20 - (packages.size() * 10))
	pkg.z_index = 10

	print("PICKUP SUCCESS")

func _on_animation_player_animation_finished(anim_name):

	if anim_name == "pick_package":
		if pending_package:
			pickup(pending_package)
			pending_package = null

	elif anim_name == "drop_package":
		if is_dropping:
			drop_package()
			is_dropping = false

	is_picking_up = false
	anim.play("idle")

func drop_package():
	if packages.is_empty():
		return null

	var pkg = packages.pop_back()

	pkg.reparent(get_tree().current_scene)

	var throw_direction = Vector2(last_direction, 0)

	# posisi awal lempar
	pkg.global_position = global_position + (throw_direction * 0)

	# target lempar
	var target_position = pkg.global_position + (throw_direction * 300)

	# tween lempar
	var tween = create_tween()

	tween.tween_property(
		pkg,
		"global_position",
		target_position,
		0.25
	)
	pkg.z_index = 0

	print("DROP SUCCESS")

	return pkg

func _on_detection_zone_area_entered(area):
	print("DETECT AREA: ", area.name)
	if area.has_method("get_weight"):
		print("VALID PACKAGE")
		nearby_packages.append(area)
		
func _on_detection_zone_area_exited(area):
	if area == nearby_package:
		nearby_packages.erase(area)

func get_closest_package():
	if nearby_packages.is_empty():
		return null
		
	var closest = nearby_packages[0]
	var closest_dist = position.distance_to(closest.position)

	for p in nearby_packages:
		var dist = position.distance_to(p.position)
		if dist < closest_dist:
			closest = p
			closest_dist = dist

	return closest
