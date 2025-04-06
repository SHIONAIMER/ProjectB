extends TextureRect

# 网格属性
@export var grid_size: Vector2i = Vector2i(10, 8)
@export var grid_texture: Texture2D = preload("res://AssetBundle/Weapons/backpack_grid.png")
var cell_size: Vector2i = Vector2i(64, 64)
var grid_data: Array[Array] = []
var can_place_color: Color = Color(0, 1, 0, 0.5)
var affected_color: Color = Color(0, 0, 1, 0.5)
var cannot_place_color: Color = Color(1, 0, 0, 0.5)

# 物品相关
var dragging_item: Item = null
var hover_pos: Vector2i = Vector2i(-1, -1)

func _ready() -> void:
	custom_minimum_size = Vector2(grid_size.x * cell_size.x, grid_size.y * cell_size.y)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	var parent = get_parent()
	if parent is PanelContainer:
		position = (parent.size - size) / 2
		parent.resized.connect(_on_parent_resized)
	
	_initialize_grid()

func _on_parent_resized() -> void:
	var parent = get_parent()
	if parent is PanelContainer:
		position = (parent.size - size) / 2

func _initialize_grid() -> void:
	grid_data.clear()
	for y in range(grid_size.y):
		var row: Array = []
		for x in range(grid_size.x):
			row.append(null)  # null 表示空格子
		grid_data.append(row)
	add_example_items()

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_handle_mouse_motion(event)
	elif event is InputEventMouseButton:
		_handle_mouse_button(event)

func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	var local_pos = event.position
	hover_pos = Vector2i(local_pos.x / cell_size.x, local_pos.y / cell_size.y)
	queue_redraw()

func _handle_mouse_button(event: InputEventMouseButton) -> void:
	if event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if dragging_item == null:
			_try_pickup_item()
		else:
			_try_place_item()

func _try_pickup_item() -> void:
	if dragging_item != null:
		return
		
	var item = _get_item_at(hover_pos)
	if item != null:
		dragging_item = item
		_remove_item_from_grid(item)
		queue_redraw()

func _try_place_item() -> void:
	if dragging_item == null:
		return
		
	var affected_items = _get_affected_items(dragging_item, hover_pos)
	if affected_items.size() <= 1:
		if _can_place_item(dragging_item, hover_pos):
			_place_item(dragging_item, hover_pos)
			dragging_item = null
		else:
			# 如果无法放置，则拾取被影响的物品
			if affected_items.size() == 1:
				var item = affected_items[0]
				_remove_item_from_grid(item)
				var temp_item = dragging_item
				dragging_item = item
				if _can_place_item(temp_item, hover_pos):
					_place_item(temp_item, hover_pos)
	queue_redraw()

func _draw() -> void:
	# 绘制网格背景
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var pos = Vector2(x * cell_size.x, y * cell_size.y)
			draw_texture_rect(grid_texture, Rect2(pos, Vector2(cell_size.x, cell_size.y)), false)
	
	# 绘制物品
	var drawn_items = []  # 用于记录已绘制的物品
	for y in range(grid_size.y):
		for x in range(grid_size.x):
			var item = grid_data[y][x]
			if item != null and item.texture != null and not drawn_items.has(item):
				var pos = Vector2(x * cell_size.x, y * cell_size.y)
				draw_texture_rect(item.texture, 
								Rect2(pos, Vector2(item.size.x * cell_size.x, 
												 item.size.y * cell_size.y)),
								false)
				drawn_items.append(item)
	
	# 绘制拖拽中的物品和预期放置位置的边框
	if dragging_item != null:
		var mouse_pos = get_local_mouse_position()
		draw_texture_rect(dragging_item.texture,
						 Rect2(mouse_pos - Vector2(cell_size) / 2,
							  Vector2(dragging_item.size.x * cell_size.x,
									dragging_item.size.y * cell_size.y)),
						 false)
		
		# 绘制预期放置位置的边框
		var affected_items = _get_affected_items(dragging_item, hover_pos)
		var border_pos = Vector2(hover_pos.x * cell_size.x, hover_pos.y * cell_size.y)
		var border_size = Vector2(dragging_item.size.x * cell_size.x, dragging_item.size.y * cell_size.y)
		
		if affected_items.size() == 0:
			draw_rect(Rect2(border_pos, border_size), can_place_color, false, 2.0)
		elif affected_items.size() == 1:
			draw_rect(Rect2(border_pos, border_size), affected_color, false, 2.0)
		else:
			draw_rect(Rect2(border_pos, border_size), cannot_place_color, false, 2.0)

func _can_place_item(item: Item, pos: Vector2i) -> bool:
	if pos.x < 0 or pos.y < 0:
		return false
	if pos.x + item.size.x > grid_size.x:
		return false
	if pos.y + item.size.y > grid_size.y:
		return false
	
	# 检查目标位置是否有其他物品
	for y in range(item.size.y):
		for x in range(item.size.x):
			if grid_data[pos.y + y][pos.x + x] != null:
				return false
	return true

func _place_item(item: Item, pos: Vector2i) -> void:
	for y in range(item.size.y):
		for x in range(item.size.x):
			grid_data[pos.y + y][pos.x + x] = item
	item.grid_position = pos

func _remove_item_from_grid(item: Item) -> void:
	var pos = item.grid_position
	for y in range(item.size.y):
		for x in range(item.size.x):
			grid_data[pos.y + y][pos.x + x] = null

func _get_item_at(pos: Vector2i) -> Item:
	if pos.x < 0 or pos.y < 0 or pos.x >= grid_size.x or pos.y >= grid_size.y:
		return null
	return grid_data[pos.y][pos.x]

func _process(_delta: float) -> void:
	pass

func add_example_items() -> void:
	var sword = Item.new()
	sword.texture = preload("res://AssetBundle/Weapons/sword_free1.png")
	sword.size = Vector2i(2, 3)  # 大型武器占用更多格子
	sword.item_name = "铁剑"
	sword.description = "一把普通的铁剑"

	var sword2 = Item.new()
	sword2.texture = preload("res://AssetBundle/Weapons/sword_free1.png")
	sword2.size = Vector2i(2, 3)  # 大型武器占用更多格子
	sword2.item_name = "铁剑"
	sword2.description = "一把普通的铁剑"

	var axe = Item.new()
	axe.texture = preload("res://AssetBundle/Weapons/2hand_axe_free1.png")
	axe.size = Vector2i(2, 3)  # 小型物品占用1个格子
	axe.stack_size = 20  # 可以堆叠20个
	axe.item_name = "生命药水"
	axe.description = "恢复100点生命值"

	# 将物品放入背包
	if _can_place_item(sword, Vector2i(0, 0)):
		_place_item(sword, Vector2i(0, 0))
		_place_item(sword2, Vector2i(0, 3))
	if _can_place_item(axe, Vector2i(4, 4)):
		_place_item(axe, Vector2i(4, 4))

func _get_affected_items(item: Item, pos: Vector2i) -> Array[Item]:
	var affected_items: Array[Item] = []
	for y in range(item.size.y):
		for x in range(item.size.x):
			var check_pos = Vector2i(pos.x + x, pos.y + y)
			var existing_item = _get_item_at(check_pos)
			if existing_item != null and not affected_items.has(existing_item):
				affected_items.append(existing_item)
	return affected_items
