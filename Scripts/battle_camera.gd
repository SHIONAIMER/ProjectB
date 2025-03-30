extends Camera2D

@export var target: Node2D
@export var follow_speed: float = 5.0
@export var prediction_factor: float = 0  # 预测移动系数
@export var pixel_snap: bool = true  # 是否启用像素对齐

var last_target_pos: Vector2
var target_velocity: Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if target == null:
		push_warning("Camera target not set!")
	else:
		last_target_pos = target.global_position

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if target == null:
		return
		
	# 计算目标速度
	var current_pos = target.global_position
	target_velocity = (current_pos - last_target_pos) / delta
	last_target_pos = current_pos
	
	# 预测目标位置
	# var predicted_pos = current_pos + target_velocity * prediction_factor
	
	# 使用插值实现平滑跟随，并添加预测
	# var new_pos = global_position.lerp(predicted_pos, delta * follow_speed)
	var new_pos = global_position.lerp(current_pos, delta * follow_speed)
	
	# 如果需要像素对齐，进行四舍五入
	if pixel_snap:
		new_pos = new_pos.round()
	
	global_position = new_pos
