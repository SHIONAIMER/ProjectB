extends Node

# 单例实例
static var _instance: Node

static func get_instance() -> Node:
	if not _instance:
		_instance = Node.new()
	return _instance

func _init() -> void:
	_instance = self
	add_item(Sword.new())
	add_item(Axe.new())
	add_item(Sword.new())
	add_item(Sword.new())
	add_item(Sword.new())
	add_item(Sword.new())
	add_item(Sword.new())
	add_item(Sword.new())
	add_item(Sword.new())
	add_item(Sword.new())
	add_item(Sword.new())
	add_item(Sword.new())
	add_item(Sword.new())
	add_item(Sword.new())
	add_item(Sword.new())
	add_item(Sword.new())
	add_item(Sword.new())
	add_item(Sword.new())
	add_item(Sword.new())
	add_item(Sword.new())
	add_item(Sword.new())
	add_item(Sword.new())
	add_item(Sword.new())

# 玩家拥有的所有物品
var player_items: Array[Item] = []

# 添加物品到玩家物品栏
func add_item(item: Item) -> void:
	if not player_items.has(item):
		player_items.append(item)

# 从玩家物品栏移除物品
func remove_item(item: Item) -> void:
	player_items.erase(item)

# 获取玩家所有物品
func get_all_items() -> Array[Item]:
	return player_items.duplicate()

# 检查玩家是否拥有特定物品
func has_item(item: Item) -> bool:
	return player_items.has(item)

# 清空玩家物品栏
func clear_items() -> void:
	player_items.clear() 
