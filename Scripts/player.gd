extends CharacterBody2D

const SPEED = 200.0
const ROLL_SPEED = 300.0
const ROLL_DURATION = 0.3

@onready var animated_sprite = $AnimatedSprite2D
var is_rolling = false
var roll_timer = 0.0
var roll_direction = Vector2.ZERO

func _ready() -> void:
	# 确保动画精灵存在
	if not animated_sprite:
		push_error("AnimatedSprite2D node not found!")
		return

func _physics_process(delta: float) -> void:
	# 获取水平和垂直方向的输入
	var horizontal_direction := Input.get_axis("walk_left", "walk_right")
	var vertical_direction := Input.get_axis("walk_up", "walk_down")
	
	# 处理翻滚
	if Input.is_action_just_pressed("roll") and not is_rolling:
		is_rolling = true
		roll_timer = ROLL_DURATION
		# 保存翻滚方向
		roll_direction = Vector2(horizontal_direction, vertical_direction).normalized()
		if roll_direction == Vector2.ZERO:
			roll_direction = Vector2.RIGHT if !animated_sprite.flip_h else Vector2.LEFT
	
	if is_rolling:
		roll_timer -= delta
		velocity = roll_direction * ROLL_SPEED
		if roll_timer <= 0:
			is_rolling = false
	else:
		# 正常移动
		velocity.x = horizontal_direction * SPEED
		velocity.y = vertical_direction * SPEED
	
	# 更新动画状态
	_update_animation_state()
	
	# 应用移动
	move_and_slide()

func _update_animation_state() -> void:
	if not animated_sprite:
		return
		
	# 根据移动状态设置动画
	if is_rolling:
		if not animated_sprite.is_playing() or animated_sprite.animation != "roll":
			animated_sprite.play("roll")
		if roll_direction.x != 0:
			animated_sprite.flip_h = roll_direction.x < 0
	elif velocity.length() > 0:
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
