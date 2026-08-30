extends Node2D

const DRAG_ARM_DISTANCE_SQUARED = 100

enum CursorShape {
	POINTER,
	OPEN,
	CLOSED
}

var dragging_control: bool:
	set(value):
		dragging_control = value
		_reset_cursor()

var _drag_target: PickableArea
var _drag_position: Vector2i
var _drag_armed: bool
var _drop_areas: Array[DropArea]

var _click_target: PickableArea

var _hovering_over: Array[Node]


@onready var cursor:= %Cursor
@onready var cursor_textures: Dictionary[CursorShape, Sprite2D]= {
	CursorShape.POINTER: %Pointer,
	CursorShape.OPEN: %Open,
	CursorShape.CLOSED: %Closed
}

func _ready() -> void:
	Input.mouse_mode = Input.MOUSE_MODE_HIDDEN
	

func _process(_delta: float) -> void:
	cursor.global_position = get_global_mouse_position()
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton and not event.is_pressed() and event.button_index == MouseButton.MOUSE_BUTTON_LEFT:
		_stop_drag()
		
	if event is InputEventMouseMotion and _is_drag_pre_armed() and not _drag_armed:
		var movement = _drag_position.distance_squared_to(get_viewport().get_mouse_position())
		if movement > DRAG_ARM_DISTANCE_SQUARED:
			_arm_drag()
	

func mouse_entered(target: DropArea) -> void:
	if _drag_armed:
		if _drag_target.collision_mask & target.collision_layer != 0:
			GSLogger.debug("Draggable %s entered area %s" % [_drag_target.target, target.target])
			_drop_areas.append(target)
			target.enter_draggable(_drag_target)
			_drag_target.enter_area(target)
	

func mouse_exited(target: DropArea) -> void:
	if _drag_armed:
		if _drop_areas.has(target):
			GSLogger.debug("Draggable %s exited area %s" % [_drag_target.target, target.target])
			_drop_areas.erase(target)
			target.exit_draggable(_drag_target)
			_drag_target.exit_area(target)
	

func mouse_entered_pickable(node: Node) -> void:
	if not node in _hovering_over:
		_hovering_over.append(node)
	
	_reset_cursor()
	

func mouse_exited_pickable(node: Node) -> void:
	if not node in _hovering_over:
		return
	
	_hovering_over.erase(node)
	
	_reset_cursor()
	

func mouse_pressed(target: PickableArea) -> void:
	GSLogger.debug("Mouse pressed %s" % target.target)
	_click_target = target
	

func mouse_released(target: PickableArea) -> void:
	if _click_target == target:
		GSLogger.debug("Mouse released %s" % target.target)
		target.press()
	

func start_drag(target: PickableArea) -> void:
	if _is_drag_pre_armed():
		return
	
	GSLogger.debug("Pre-arming drag on %s" % target.target)
	_drag_target = target
	_drag_position = get_viewport().get_mouse_position()
	

func _arm_drag() -> void:
	GSLogger.debug("Arming drag on %s" % _drag_target.target)
	_drag_armed = true
	_reset_cursor()
	
	_drag_target.start_drag()
	

func _stop_drag() -> void:
	if not _is_drag_pre_armed():
		return
	
	if _drag_armed:
		_drop()
	else:
		GSLogger.debug("Canceling arming drag on %s" % _drag_target.target)
	
	_drag_target = null
	_drag_armed = false
	_reset_cursor()
	_drop_areas.clear()
	

func _drop() -> void:
	var drop_area: DropArea
	if not _drop_areas.is_empty():
		var idx = _drop_areas.rfind_custom(func(x): return x.can_drop(_drag_target))
		if idx >= 0:
			drop_area = _drop_areas[0]
	
	GSLogger.debug("Dropping %s on area %s" % [_drag_target.target, drop_area.target if drop_area != null else null])
	_drag_target.drop(drop_area)
	
	get_viewport().set_input_as_handled()
	

func _is_drag_pre_armed() -> bool:
	return is_instance_valid(_drag_target)
	

func set_cursor(cursor_shape: CursorShape) -> void:
	for i in cursor_textures:
		cursor_textures[i].visible = i == cursor_shape
	

func _reset_cursor() -> void:
	if _drag_armed or dragging_control:
		set_cursor(CursorShape.CLOSED)
	elif _hovering_over.is_empty():
		set_cursor(CursorShape.POINTER)
	else: 
		set_cursor(CursorShape.OPEN)
	
