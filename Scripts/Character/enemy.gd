extends "res://Scripts/Character/character.gd"

@export var target: Node3D
@export var detection_range: float = 5.0  # 检测范围
@export var stop_distance: float = 0.1    # 停止距离

func _physics_process(delta: float) -> void:
	if not target:
		return
		
	# 计算与目标的距离
	var distance_to_target = global_position.distance_to(target.global_position)
	
	# 如果目标在检测范围内
	if distance_to_target <= detection_range:
		# 计算朝向目标的方向
		var direction = (target.global_position - global_position).normalized()
		
		# 如果距离大于停止距离，则继续移动
		if distance_to_target > stop_distance:
			velocity.x = direction.x * SPEED
			velocity.z = direction.z * SPEED
		else:
			# 到达停止距离时停止移动
			velocity = Vector3.ZERO
	else:
		# 目标超出检测范围时停止移动
		velocity = Vector3.ZERO
	
	# 更新动画状态
	_update_animation_state()
	
	# 应用移动
	move_and_slide()

func _update_animation_state() -> void:
	if not animated_sprite:
		return
		
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
