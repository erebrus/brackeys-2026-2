class_name CatalogPlant extends MarginContainer

signal fact_added(plant: CatalogPlant, fact: CatalogPlant)

var plant: PlantType

@onready var solved_overlay: Control = %Solved
@onready var facts_container: PlantFactsContainer = %FactsContainer
@onready var buy_button: BaseButton = %BuyButton

@warning_ignore("shadowed_variable")
static func create(plant: PlantType) -> CatalogPlant:
	var scene: CatalogPlant = load("uid://e83ma3nckg3").instantiate()
	scene.plant = plant
	return scene
	

func _ready() -> void:
	if plant == null:
		return
	
	%PlantPortrait.texture = plant.textures[Plant.PlantState.NORMAL]
	%BuyButton.pressed.connect(Events.plant_bought.emit.bind(plant))
	
	Events.free_tray_slots_changed.connect(func(x): buy_button.disabled = x == 0)
	
	plant.solved.connect(_on_solved)
	facts_container.fact_added.connect(_on_fact_added)
	GameUtils.clear_node(facts_container)
	
	for fact in plant.current_facts:
		var fact_node := CatalogPlantFact.create(Globals.facts[fact], plant)
		facts_container.add_child(fact_node)
	

func _on_fact_added(fact: CatalogPlantFact) -> void:
	fact_added.emit(self, fact)
	

func _on_solved() -> void:
	solved_overlay.show()
	
	facts_container.solved = true
	for fact: CatalogPlantFact in facts_container.get_children():
		fact.disable()
