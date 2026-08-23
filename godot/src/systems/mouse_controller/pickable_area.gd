class_name PickableArea extends Area2D

signal pressed

signal picked
signal dragged
signal dropped(area: DropArea)

signal entered_area(area: DropArea)
signal exited_area(area: DropArea)


@export var target: Node2D

@export var is_clickable: bool
@export var is_draggable: bool
@export var snap_on_hover: bool

var is_dragging: bool = false
var hover_area: DropArea

var _offset: Vector2
var _pick_position: Vector2

func _ready() -> void:
	input_event.connect(_on_input_event)
	

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and is_dragging:
		if not snap_on_hover or hover_area == null:
			target.global_position = get_global_mouse_position() - _offset # TODO: should always pickup from origin?
		dragged.emit()
	

func _on_input_event(_viewport: Viewport, event: InputEvent, _shape_idx: int) -> void:
	if event is InputEventMouseButton:
		if event.is_pressed():
			if is_clickable:
				MouseController.mouse_pressed(self)
			
			if is_draggable:
				MouseController.start_drag(self)
				_offset = get_global_mouse_position() - target.global_position
				_pick_position = target.global_position
		else:
			MouseController.mouse_released(self)
	


func press() -> void:
	pressed.emit()
	

func start_drag() -> void:
	is_dragging = true
	picked.emit()
	

func drop(drop_area: DropArea) -> void:
	is_dragging = false
	hover_area = null
	
	if drop_area == null:
		target.global_position = _pick_position
	else:
		target.global_position = drop_area.global_position
	
	dropped.emit(drop_area)
	

func enter_area(area: DropArea) -> void:
	hover_area = area
	if snap_on_hover:
		target.global_position = area.global_position
	area_entered.emit(area)
	

func exit_area(area: DropArea) -> void:
	hover_area = null
	area_exited.emit(area)
	
