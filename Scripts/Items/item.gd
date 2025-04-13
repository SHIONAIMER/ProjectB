class_name Item extends Resource

enum ItemCategory {
    None,
    Weapon,
}

enum ItemType {
    None,
    Sword,
    Axe,
    Bow,
    Crossbow,
    Staff,
    Wand,
    Shield,
}

enum ItemRarity {
    None,
    Common,
    Uncommon,
    Rare,
    Epic,
    Legendary,
}

@export var texture: Texture2D
@export var shape: Array = [[1]]  # 物品的形状，1表示占用，0表示不占用
@export var stack_size: int = 1  # 最大堆叠数量
@export var current_stack: int = 1  # 当前堆叠数量
@export var item_name: String = ""
@export var description: String = ""
@export var item_color: Color = Color(0, 1, 0, 1)
@export var item_index: int = 0
@export var item_category: ItemCategory = ItemCategory.None
@export var item_type: ItemType = ItemType.None
@export var item_rarity: ItemRarity = ItemRarity.None
var grid_position: Vector2i = Vector2i(-1, -1)  # 在网格中的位置

func get_size() -> Vector2i:
    return Vector2i(shape[0].size(), shape.size())

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