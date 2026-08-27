class_name ToolTray extends Node2D


@export var slots: Array[PlantSlot]


func _ready() -> void:
	for slot in slots:
		slot.plant_changed.connect(_on_slot_plant_changed)
	
	Events.plant_bought.connect(_on_plant_bought)
	

func _on_slot_plant_changed(_plant: Plant) -> void:
	var free_slots: int = 0
	for slot in slots:
		if slot.plant == null:
			free_slots += 1
	
	Events.free_tray_slots_changed.emit(free_slots)
	

func _on_plant_bought(type: PlantType) -> void:
	var slot_idx = slots.find_custom(func(x): return x.plant == null)
	if slot_idx < 0:
		return
	
	var slot = slots[slot_idx]
	var plant = Plant.create(type)
	slot.set_plant(plant)
	
