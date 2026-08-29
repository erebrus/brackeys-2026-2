class_name PlantSlot extends Node2D

signal plant_changed(plant: Plant)

@export var allow_stat_decay: bool = true
@export var stats: Dictionary[Types.Stats, float]

var plant: Plant

@onready var drop_area: DropArea = %DropArea


func remove_plant() -> void:
	if plant == null:
		return
	
	GSLogger.info("Removing plant %s from slot with stats %s" % [plant.type.name, stats])
	
	plant.slot = null
	plant = null
	plant_changed.emit(null)
	

func set_plant(value: Plant) -> void:
	if value == plant:
		return
	
	assert(plant == null)
	assert(value != null)
	
	plant = value
	
	if plant.slot != null:
		plant.slot.remove_plant()
	
	GSLogger.info("Adding plant %s to slot with stats %s" % [plant.type.name, stats])
	
	if plant.get_parent() == null:
		add_child(plant)
	else:
		plant.reparent(self)
	
	plant.position = Vector2.ZERO
	plant.slot = self
	
	for stat in stats:
		plant.update_stat(stat, stats[stat])
	
	plant_changed.emit(plant)
	
	
