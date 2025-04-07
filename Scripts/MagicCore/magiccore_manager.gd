extends TextureRect

var magiccore_data = MagicCoreBase.new()
var affected_color: Color = Color(0, 0, 1, 0.3)
var cannot_place_color: Color = Color(1, 0, 0, 0.3)

var dragging_item: Item = null
var hover_pos: Vector2i = Vector2i(-1, -1)

func _ready() -> void:
	custom_minimum_size = Vector2(magiccore_data.grid_size.x * magiccore_data.cell_size.x, 
								magiccore_data.grid_size.y * magiccore_data.cell_size.y)
	size = custom_minimum_size
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	var parent = get_parent()
	if parent is PanelContainer:
		position = (parent.size - size) / 2
		parent.resized.connect(_on_parent_resized)
	
	magiccore_data.initialize_grid()
	add_example_items()

func _on_parent_resized() -> void:
	var parent = get_parent()
	if parent is PanelContainer:
		position = (parent.size - size) / 2

func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		_handle_mouse_motion(event)
	elif event is InputEventMouseButton:
		_handle_mouse_button(event)

func _handle_mouse_motion(event: InputEventMouseMotion) -> void:
	var local_pos = event.position
	hover_pos = Vector2i(local_pos.x / magiccore_data.cell_size.x, local_pos.y / magiccore_data.cell_size.y)
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

func _draw_item_edges(shape: Array, pos: Vector2i, color: Color) -> void:
	var size_y = shape.size()
	var size_x = shape[0].size()
	
	# 绘制上边缘
	for x in range(size_x):
		for y in range(size_y):
			if shape[y][x] == 1:
				var start_pos = Vector2((pos.x + x) * magiccore_data.cell_size.x, (pos.y + y) * magiccore_data.cell_size.y)
				draw_rect(Rect2(start_pos, Vector2(magiccore_data.cell_size.x, 2)), color, true)
				break
	
	# 绘制下边缘
	for x in range(size_x):
		for y in range(size_y - 1, -1, -1):
			if shape[y][x] == 1:
				var start_pos = Vector2((pos.x + x) * magiccore_data.cell_size.x, (pos.y + y + 1) * magiccore_data.cell_size.y - 2)
				draw_rect(Rect2(start_pos, Vector2(magiccore_data.cell_size.x, 2)), color, true)
				break
	
	# 绘制左边缘
	for y in range(size_y):
		for x in range(size_x):
			if shape[y][x] == 1:
				var start_pos = Vector2((pos.x + x) * magiccore_data.cell_size.x, (pos.y + y) * magiccore_data.cell_size.y)
				draw_rect(Rect2(start_pos, Vector2(2, magiccore_data.cell_size.y)), color, true)
				break
	
	# 绘制右边缘
	for y in range(size_y):
		for x in range(size_x - 1, -1, -1):
			if shape[y][x] == 1:
				var start_pos = Vector2((pos.x + x + 1) * magiccore_data.cell_size.x - 2, (pos.y + y) * magiccore_data.cell_size.y)
				draw_rect(Rect2(start_pos, Vector2(2, magiccore_data.cell_size.y)), color, true)
				break

func _draw() -> void:
	# 绘制网格背景
	for y in range(magiccore_data.grid_size.y):
		for x in range(magiccore_data.grid_size.x):
			var pos = Vector2(x * magiccore_data.cell_size.x, y * magiccore_data.cell_size.y)
			if magiccore_data.get_grid_value(x, y) != 0:  # 只绘制核心空间
				draw_texture_rect(magiccore_data.grid_texture, Rect2(pos, Vector2(magiccore_data.cell_size.x, magiccore_data.cell_size.y)), false)
	
	# 绘制物品和边缘
	var drawn_items = []  # 用于记录已绘制的物品
	for y in range(magiccore_data.grid_size.y):
		for x in range(magiccore_data.grid_size.x):
			var item = _get_item_at(Vector2i(x, y))
			if item != null and item.texture != null and not drawn_items.has(item):
				# 绘制物品边缘
				_draw_item_edges(item.shape, item.grid_position, item.item_color)
				
				# 绘制物品纹理
				var pos = Vector2(item.grid_position.x * magiccore_data.cell_size.x, item.grid_position.y * magiccore_data.cell_size.y)
				draw_texture_rect(item.texture, 
								Rect2(pos, Vector2(item.get_size().x * magiccore_data.cell_size.x, 
												 item.get_size().y * magiccore_data.cell_size.y)),
								false)
				drawn_items.append(item)
	
	# 绘制拖拽中的物品和预期放置位置的边缘
	if dragging_item != null:
		var mouse_pos = get_local_mouse_position()
		draw_texture_rect(dragging_item.texture,
						 Rect2(mouse_pos - Vector2(magiccore_data.cell_size) / 2,
							  Vector2(dragging_item.get_size().x * magiccore_data.cell_size.x,
									dragging_item.get_size().y * magiccore_data.cell_size.y)),
						 false)
		
		# 绘制预期放置位置的边缘和冲突区域
		var affected_items = _get_affected_items(dragging_item, hover_pos)
		var conflict_color = null
		if affected_items.size() == 1:
			conflict_color = affected_color
		elif affected_items.size() > 1:
			conflict_color = cannot_place_color
			
		# 绘制冲突区域
		if conflict_color != null:
			for y in range(dragging_item.get_size().y):
				for x in range(dragging_item.get_size().x):
					if dragging_item.shape[y][x] == 1:
						var check_pos = Vector2i(hover_pos.x + x, hover_pos.y + y)
						if check_pos.x >= 0 and check_pos.y >= 0 and check_pos.x < magiccore_data.grid_size.x and check_pos.y < magiccore_data.grid_size.y:
							if magiccore_data.get_grid_value(check_pos.x, check_pos.y) == 2:  # 已被占用
								var conflict_pos = Vector2(check_pos.x * magiccore_data.cell_size.x, check_pos.y * magiccore_data.cell_size.y)
								draw_rect(Rect2(conflict_pos, Vector2(magiccore_data.cell_size.x, magiccore_data.cell_size.y)), conflict_color, true)
		
		# 绘制物品边缘
		_draw_item_edges(dragging_item.shape, hover_pos, dragging_item.item_color)

func _can_place_item(item: Item, pos: Vector2i) -> bool:
	if pos.x < 0 or pos.y < 0:
		return false
	if pos.x + item.get_size().x > magiccore_data.grid_size.x:
		return false
	if pos.y + item.get_size().y > magiccore_data.grid_size.y:
		return false
	
	# 检查目标位置是否有其他物品或是否为非核心空间
	for y in range(item.get_size().y):
		for x in range(item.get_size().x):
			if item.shape[y][x] == 1:
				if magiccore_data.get_grid_value(pos.x + x, pos.y + y) == 0:  # 非核心空间
					return false
				if magiccore_data.get_grid_value(pos.x + x, pos.y + y) == 2:  # 已被占用
					return false
	return true

func _place_item(item: Item, pos: Vector2i) -> void:
	for y in range(item.get_size().y):
		for x in range(item.get_size().x):
			if item.shape[y][x] == 1:
				magiccore_data.set_grid_data(pos.x + x, pos.y + y, 2)  # 标记为已占用
				magiccore_data.set_item(pos.x + x, pos.y + y, item)  # 存储物品对象
	item.grid_position = pos

func _remove_item_from_grid(item: Item) -> void:
	var pos = item.grid_position
	for y in range(item.get_size().y):
		for x in range(item.get_size().x):
			if item.shape[y][x] == 1:
				magiccore_data.set_grid_data(pos.x + x, pos.y + y, 1)  # 恢复为可用空间
				magiccore_data.set_item(pos.x + x, pos.y + y, null)  # 清除物品对象

func _get_item_at(pos: Vector2i) -> Item:
	if pos.x < 0 or pos.y < 0 or pos.x >= magiccore_data.grid_size.x or pos.y >= magiccore_data.grid_size.y:
		return null 
	return magiccore_data.get_item(pos.x, pos.y)  # 直接从物品数组中获取

func _process(_delta: float) -> void:
	pass

func add_example_items() -> void:
	var sword = Sword.new()
	var sword2 = Sword.new()
	var axe = Axe.new()

	# 将物品放入核心
	if _can_place_item(sword, Vector2i(0, 0)):
		_place_item(sword, Vector2i(0, 0))
	if _can_place_item(sword2, Vector2i(0, 3)):
		_place_item(sword2, Vector2i(0, 3))
	if _can_place_item(axe, Vector2i(4, 4)):
		_place_item(axe, Vector2i(4, 4))
	
	# 强制重绘
	queue_redraw()

func _get_affected_items(item: Item, pos: Vector2i) -> Array[Item]:
	var affected_items: Array[Item] = []
	for y in range(item.get_size().y):
		for x in range(item.get_size().x):
			if item.shape[y][x] == 1:
				var check_pos = Vector2i(pos.x + x, pos.y + y)
				var existing_item = _get_item_at(check_pos)
				if existing_item != null and not affected_items.has(existing_item):
					affected_items.append(existing_item)
	return affected_items
