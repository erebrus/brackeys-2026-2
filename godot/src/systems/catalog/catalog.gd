class_name Catalog extends MarginContainer


@onready var plant_container: Container = %PlantContainer


func _ready() -> void:
	%PanelContainer.visible = %Button.button_pressed
	
	create_page(Globals.plant_types.values().slice(0, 8))
	

func create_page(plants: Array[PlantType]) -> void:
	GameUtils.clear_node(plant_container)
	
	for plant in plants:
		var plant_node := CatalogPlant.create(plant)
		plant_container.add_child(plant_node)
	

func _on_button_toggled(toggled_on: bool) -> void:
	%PanelContainer.visible = toggled_on
	
	get_tree().paused = toggled_on
	
