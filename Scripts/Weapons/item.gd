@tool class_name Item extends Resource

@export var texture: Texture2D
@export var size: Vector2i = Vector2i(1, 1)  # 物品占用的格子数
@export var stack_size: int = 1  # 最大堆叠数量
@export var current_stack: int = 1  # 当前堆叠数量
@export var item_name: String = ""
@export var description: String = ""

var grid_position: Vector2i = Vector2i(-1, -1)  # 在网格中的位置

func can_stack_with(other: Item) -> bool:
    return item_name == other.item_name and current_stack < stack_size

func add_to_stack(amount: int = 1) -> int:
    var space_left = stack_size - current_stack
    var actual_add = min(amount, space_left)
    current_stack += actual_add
    return amount - actual_add  # 返回未能添加的数量

func remove_from_stack(amount: int = 1) -> int:
    var actual_remove = min(amount, current_stack)
    current_stack -= actual_remove
    return actual_remove  # 返回实际移除的数量
