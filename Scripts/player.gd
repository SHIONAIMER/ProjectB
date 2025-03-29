extends CharacterBody2D

const SPEED = 300.0

@onready var animated_sprite = $AnimatedSprite2D

func _ready() -> void:
	# 确保动画精灵存在
	if not animated_sprite:
		push_error("AnimatedSprite2D node not found!")
		return

func _physics_process(_delta: float) -> void:
	# 获取水平和垂直方向的输入
	var horizontal_direction := Input.get_axis("walk_left", "walk_right")
	var vertical_direction := Input.get_axis("walk_up", "walk_down")
	
	# 设置水平和垂直速度
	velocity.x = horizontal_direction * SPEED
	velocity.y = vertical_direction * SPEED
	
	# 更新动画状态
	_update_animation_state()
	
	# 应用移动
	move_and_slide()

func _update_animation_state() -> void:
	if not animated_sprite:
		return
		
	# 根据移动方向设置动画
	if velocity.length() > 0:
		# 有移动时播放移动动画
		if not animated_sprite.is_playing() or animated_sprite.animation != "walk":
			animated_sprite.play("walk")
		# 根据水平方向设置动画方向
		if velocity.x != 0:
			animated_sprite.flip_h = velocity.x < 0
	else:
		# 静止时播放待机动画
		if not animated_sprite.is_playing() or animated_sprite.animation != "idle":
			animated_sprite.play("idle")