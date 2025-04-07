class_name Axe extends Item

func _init() -> void:
	texture = preload("res://AssetBundle/Weapons/2hand_axe_free1.png")
	shape = [
		[1, 1],
		[1, 1],
		[0, 1]
	]
	stack_size = 1
	item_name = "斧"
	description = "一把普通的斧"
	item_color = Color(1, 0, 0, 1)