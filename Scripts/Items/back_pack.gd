extends PanelContainer

const ItemManager = preload("res://Scripts/Items/item_manager.gd")
const ItemCard = preload("res://Sprites/UI/ItemCard.tscn")

@onready var grid_container = $MarginContainer/ScrollContainer/GridContainer

func _ready() -> void:
	# 设置GridContainer的列数
	grid_container.columns = 999
	
	# 初始化背包显示
	update_backpack_display()

func update_backpack_display() -> void:
	# 清除现有物品显示
	for child in grid_container.get_children():
		child.queue_free()
	
	# 获取所有物品并创建对应的UI
	for item in ItemManager.get_instance().get_all_items():
		# 创建ItemCard实例
		var item_card = ItemCard.instantiate()
		
		# 设置物品信息
		var texture_rect = item_card.get_node("TextureRect")
		texture_rect.texture = item.texture
		texture_rect.tooltip_text = item.item_name
		
		# 将ItemCard添加到GridContainer中
		grid_container.add_child(item_card)

# 当物品管理器中的物品发生变化时调用此函数
func on_items_changed() -> void:
	update_backpack_display()
