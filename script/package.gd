extends Area2D

enum PackageType { NORMAL, FRAGILE, HEAVY, SECRET }

@export var type: PackageType = PackageType.NORMAL

# Data per type
const TYPE_DATA = {
	PackageType.NORMAL:  { "weight": 1 },
	PackageType.FRAGILE: { "weight": 1 },  # rusak kalau nabrak
	PackageType.HEAVY:   { "weight": 2 },  # makan 2 slot
	PackageType.SECRET:  { "weight": 1 },  # trigger coworker agresif
}

func get_weight() -> int:
	return TYPE_DATA[type]["weight"]
