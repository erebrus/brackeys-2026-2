class_name PlantSlot extends Node2D


@export var stats: Dictionary[Types.Stats, float]

var plant: Plant:
	set(value):
		plant = value
		for stat in stats:
			plant.update_stat(stat, stats[stat])
	

@onready var drop_area: DropArea = %DropArea
