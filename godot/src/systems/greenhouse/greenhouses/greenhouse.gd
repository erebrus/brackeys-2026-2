class_name Greenhouse extends Node2D


@export var stats: Dictionary[Types.Stats, float]

func _ready() -> void:
	_configure_slots(self)
	$ColorRect.hide()
	

func _configure_slots(node: Node) -> void:
	for child in node.get_children():
		if child is PlantSlot:
			child.stats = stats
		_configure_slots(child)
	
