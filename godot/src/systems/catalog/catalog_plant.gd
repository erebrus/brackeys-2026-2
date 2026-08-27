class_name CatalogPlant extends MarginContainer


var plant: PlantType


@onready var facts_container: Container = %FactsContainer

@warning_ignore("shadowed_variable")
static func create(plant: PlantType) -> CatalogPlant:
	var scene: CatalogPlant = load("uid://e83ma3nckg3").instantiate()
	scene.plant = plant
	return scene
	

func _ready() -> void:
	if plant == null:
		return
	
	%PlantPortrait.texture = plant.textures[Plant.PlantState.NORMAL]
	
	GameUtils.clear_node(facts_container)
	
	for fact in plant.current_facts:
		var fact_node := CatalogPlantFact.create(Globals.facts[fact])
		facts_container.add_child(fact_node)
		
