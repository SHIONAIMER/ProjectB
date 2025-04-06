class_name Character extends CharacterBody3D

@export var SPEED = 1.0

@onready var animated_sprite = $AnimatedSprite3D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# 确保动画精灵存在
	if not animated_sprite:
		push_error("AnimatedSprite3D node not found!")
		return
	
	# 确保精灵可见
	animated_sprite.visible = true
	animated_sprite.play("idle")
