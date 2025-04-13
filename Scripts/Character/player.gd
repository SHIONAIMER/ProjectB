class_name Player extends Character

const ROLL_SPEED = 1.5
const ROLL_DURATION = 0.3

var is_rolling = false
var roll_timer = 0.0
var roll_direction = Vector3.ZERO

@export var bullet = preload("res://Sprites/Items/Bullet.tscn")
@export var bullet_speed = 1

func _physics_process(delta: float) -> void:
	# 获取水平和垂直方向的输入
	var horizontal_direction := Input.get_axis("walk_left", "walk_right")
	var vertical_direction := Input.get_axis("walk_up", "walk_down")
	
	# 处理射击
	if Input.is_action_just_pressed("shoot"):
		shoot()
	
	# 处理翻滚
	if Input.is_action_just_pressed("roll") and not is_rolling:
		is_rolling = true
		roll_timer = ROLL_DURATION
		# 保存翻滚方向
		roll_direction = Vector3(horizontal_direction, 0, vertical_direction).normalized()
		if roll_direction == Vector3.ZERO:
			roll_direction = Vector3.RIGHT if !animated_sprite.flip_h else Vector3.LEFT
	
	if is_rolling:
		roll_timer -= delta
		velocity = roll_direction * ROLL_SPEED
		if roll_timer <= 0:
			is_rolling = false
	else:
		# 正常移动
		velocity.x = horizontal_direction * SPEED
		velocity.z = vertical_direction * SPEED
	
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

# 添加射击函数
func shoot() -> void:
	print("射击")
	if not bullet:
		push_error("Bullet scene not assigned!")
		return
		
	# 获取鼠标位置并转换为3D空间坐标
	var mouse_pos = get_viewport().get_mouse_position()
	var camera = get_viewport().get_camera_3d()
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	
	# 创建射线以获取鼠标在地面上的位置
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)

	print(result)
	
	if true:
		# 计算射击方向
		#var target_pos = result.position
		#var direction = (target_pos - global_position).normalized()
		var direction = Vector3.RIGHT
		
		# 实例化子弹
		var bullet_instance = bullet.instantiate()
		get_tree().current_scene.add_child(bullet_instance)
		bullet_instance.global_position = global_position + Vector3(0.1, 0.1, 0)
		
		# 设置子弹旋转
		var angle = atan2(direction.z, direction.x)
		bullet_instance.rotation.y = -angle
		
		# 设置子弹速度（需要确保子弹场景有对应的属性）
		if bullet_instance.has_method("set_direction"):
			bullet_instance.set_direction(direction)
