class_name Pot extends Node2D

signal dropped(slot: PlantSlot)

@export var plant: Plant

static var scenes: Array[String] = [
	"uid://ba4u1ghogdnpf",
	"uid://b1khxho0877xl",
	"uid://bkh1mqrso3whn",
]


@onready var pickable_area: PickableArea = %PickableArea


@warning_ignore("shadowed_variable")
static func create(plant: Plant) -> Pot:
	var packed_scene = load(scenes.pick_random())
	var scene: Pot = packed_scene.instantiate()
	scene.plant = plant
	
	return scene


func _ready() -> void:
	assert(plant != null)
	
	pickable_area.target = plant
	pickable_area.dropped.connect(_on_dropped)
	

func get_plant_base() -> Vector2:
	return %PlantBaseMarker.position
	

func _on_dropped(area: DropArea) -> void:
	if area == null:
		return
		
	assert(area.target is PlantSlot)
	dropped.emit(area.target)
