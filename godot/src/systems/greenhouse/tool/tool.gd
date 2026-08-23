class_name Tool extends Node2D

@onready var pickable_area: PickableArea = $PickableArea
@onready var interaction_area: InteractionArea = $InteractionArea


func _ready() -> void:
	pickable_area.dragged.connect(_on_dragged)
	pickable_area.dropped.connect(_on_dropped)

func _pour() -> void:
	var plant_area: InteractionArea = interaction_area.get_hover_area()
	if plant_area == null:
		rotation = 0
	else:
		if plant_area.global_position.x > global_position.x:
			scale.x = -1
			rotation = PI / 6
		else:
			scale.x = 1
			rotation = -PI / 6
	

func _on_dragged() -> void:
	_pour()
	

func _on_dropped(_area: DropArea) -> void:
	scale.x = 1
	rotation = 0
	
