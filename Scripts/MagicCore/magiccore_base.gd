class_name MagicCoreBase extends Resource

@export var grid_size: Vector2i = Vector2i(10, 8)
@export var cell_size: Vector2i = Vector2i(64, 64)
@export var magiccore_shape: Array = [
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1],
    [1, 1, 1, 1, 1, 1, 1, 1, 1, 1]
]  # 核心的形状，0表示非核心空间，1表示可用空间，2表示已占用空间
@export var grid_texture: Texture2D = preload("res://AssetBundle/Weapons/backpack_grid.png")

var grid_data: Array[Array] = []
var items_data: Array[Array] = []  # 存储物品对象

func initialize_grid() -> void:
    grid_data.clear()
    items_data.clear()
    for y in range(grid_size.y):
        var row: Array = []
        var items_row: Array = []
        for x in range(grid_size.x):
            if y < magiccore_shape.size() and x < magiccore_shape[y].size():
                row.append(magiccore_shape[y][x])
            else:
                row.append(0)  # 超出核心形状范围的部分设为非核心空间
            items_row.append(null)  # 初始化物品数组
        grid_data.append(row)
        items_data.append(items_row)

func get_grid_data() -> Array[Array]:
    return grid_data

func set_grid_data(x: int, y: int, value: int) -> void:
    if x >= 0 and y >= 0 and x < grid_size.x and y < grid_size.y:
        grid_data[y][x] = value

func get_grid_value(x: int, y: int) -> int:
    if x >= 0 and y >= 0 and x < grid_size.x and y < grid_size.y:
        return grid_data[y][x]
    return 0

func set_item(x: int, y: int, item: Item) -> void:
    if x >= 0 and y >= 0 and x < grid_size.x and y < grid_size.y:
        items_data[y][x] = item

func get_item(x: int, y: int) -> Item:
    if x >= 0 and y >= 0 and x < grid_size.x and y < grid_size.y:
        return items_data[y][x]
    return null 