extends Camera3D

@export var target: Node3D
@export var follow_speed: float = 5.0

var last_target_pos: Vector3
var target_velocity: Vector3
var initial_height: float  # 存储初始Y轴高度

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if target == null:
		push_warning("Camera target not set!")
	else:
		last_target_pos = target.global_position
	initial_height = global_position.y  # 记录初始高度

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if target == null:
		return
		
	# 计算目标速度
	var current_pos = target.global_position
	target_velocity = (current_pos - last_target_pos) / delta
	last_target_pos = current_pos
	
	# 创建目标位置，但只使用目标的X和Z坐标
	var target_xz_pos = Vector3(current_pos.x, initial_height, current_pos.z + 1)
	
	# 使用插值实现平滑跟随，只在X和Z方向
	var new_pos = global_position.lerp(target_xz_pos, delta * follow_speed)
	
	global_position = new_pos
