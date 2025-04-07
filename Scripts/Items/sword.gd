class_name Sword extends Item

func _init() -> void:
	texture = preload("res://AssetBundle/Weapons/sword_free1.png")
	shape = [
		[1, 0],
		[1, 1],
		[0, 1]
	]
	stack_size = 1
	item_name = "剑"
	description = "一把普通的剑"
	item_color = Color(0, 0, 1, 1)  # 蓝色