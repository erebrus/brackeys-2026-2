class_name InteractionArea extends Area2D


@export var target: Node


func get_hover_area() -> InteractionArea:
	var areas = get_overlapping_areas()
	for area in areas:
		if area is InteractionArea:
			return area
	return null
	
