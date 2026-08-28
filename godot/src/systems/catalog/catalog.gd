class_name Catalog extends MarginContainer

var current_page:= 0

@onready var plant_container: Container = %PlantContainer


func _ready() -> void:
	%PanelContainer.visible = %Button.button_pressed
	
	create_page()
	

func create_page() -> void:
	var page = Globals.pages[current_page]
	%SolvedLabel.visible = page.is_solved
	
	GameUtils.clear_node(plant_container)
	
	for plant in page.plants.values():
		var plant_node := CatalogPlant.create(plant)
		plant_container.add_child(plant_node)
		plant_node.fact_added.connect(_on_fact_added)
	

func _on_button_toggled(toggled_on: bool) -> void:
	%PanelContainer.visible = toggled_on
	
	get_tree().paused = toggled_on
	

func _on_previous_page_pressed() -> void:
	if current_page == 0:
		return
	
	current_page -= 1
	create_page()


func _on_next_page_pressed() -> void:
	if current_page >= Globals.pages.size() - 1:
		return
	
	current_page += 1
	create_page()
	

func _on_fact_added(plant: CatalogPlant, fact: CatalogPlantFact) -> void:
	var old_plant = fact.plant
	if old_plant == plant.plant:
		return
	
	var page = Globals.pages[current_page]
	page.move_fact(fact.fact.id, old_plant, plant.plant)
	
	if page.is_solved:
		%SolvedLabel.show()
