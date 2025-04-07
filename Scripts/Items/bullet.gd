extends RigidBody3D

@export var speed = 1
var direction = Vector3.ZERO

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	collision_layer = 2  # 设置碰撞层
	collision_mask = 0   # 不与其他物体发生碰撞

func _physics_process(_delta: float) -> void:
	linear_velocity = direction * speed
	
	# 在一定时间后销毁子弹
	await get_tree().create_timer(2.0).timeout
	queue_free()

func set_direction(new_direction: Vector3):
	direction = new_direction
