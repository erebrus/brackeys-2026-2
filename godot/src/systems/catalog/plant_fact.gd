class_name CatalogPlantFact extends PanelContainer


var plant: PlantType

var fact: Fact

@warning_ignore("shadowed_variable")
static func create(fact: Fact, plant: PlantType) -> CatalogPlantFact:
	var scene: CatalogPlantFact = load("uid://dmk74ill31lem").instantiate()
	scene.fact = fact
	scene.plant = plant
	return scene
	

func _ready() -> void:
	if fact == null:
		return
	
	%Label.text = fact.text
	

func _get_drag_data(_at_position: Vector2) -> CatalogPlantFact:
	set_drag_preview(create_preview())
	return self
	
#
func create_preview() -> CatalogPlantFact:
	var preview = create(fact, plant)
	preview.custom_minimum_size = size
	preview.offset_transform_enabled = true
	preview.offset_transform_position_ratio = Vector2(-0.5, -0.5)
	preview.offset_transform_rotation = -0.05
	
	return preview
	
