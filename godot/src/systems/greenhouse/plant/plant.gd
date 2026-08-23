class_name Plant extends Node2D


var slot: PlantSlot


@onready var pickable_area: PickableArea = %PickableArea


func _ready() -> void:
	pickable_area.dropped.connect(_on_dropped)
	

func place(at: PlantSlot) -> void:
	slot = at
	at.plant = self
	pickable_area.drop(slot.drop_area)
	

func _on_dropped(area: DropArea) -> void:
	if area == null:
		return
		
	assert(area.target is PlantSlot)
	slot = area.target
	
