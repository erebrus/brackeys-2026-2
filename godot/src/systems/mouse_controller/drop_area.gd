class_name DropArea extends Area2D

signal draggable_entered(draggable: DropArea)
signal draggable_exited(draggable: DropArea)


@export var target: Node

var disabled: bool = false:
	set(value):
		disabled = value
		$CollisionShape2D.disabled = disabled

func _ready() -> void:
	mouse_entered.connect(MouseController.mouse_entered.bind(self))
	mouse_exited.connect(MouseController.mouse_exited.bind(self))
	

func can_drop(_draggagle: PickableArea) -> bool:
	return true
	

func enter_draggable(draggable: PickableArea) -> void:
	draggable_entered.emit(draggable)
	

func exit_draggable(draggable: PickableArea) -> void:
	draggable_exited.emit(draggable)
	
