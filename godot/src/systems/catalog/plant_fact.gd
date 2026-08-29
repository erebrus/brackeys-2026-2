class_name CatalogPlantFact extends PanelContainer


var plant: PlantType

var fact: Fact

var draggable: bool = true
var is_preview: bool = false


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
	
	mouse_entered.connect(func(): MouseController.mouse_entered_pickable(self))
	mouse_exited.connect(func(): MouseController.mouse_exited_pickable(self))
	

func _get_drag_data(_at_position: Vector2) -> CatalogPlantFact:
	if not draggable:
		return null
	
	set_drag_preview(create_preview())
	return self
	

func _exit_tree() -> void:
	if is_preview:
		MouseController.dragging_control = false
	

func disable() -> void:
	draggable = false
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	MouseController.mouse_exited_pickable(self)
	

func create_preview() -> CatalogPlantFact:
	var preview = create(fact, plant)
	preview.is_preview = true
	preview.custom_minimum_size = size
	preview.offset_transform_enabled = true
	preview.offset_transform_position_ratio = Vector2(-0.5, -0.5)
	preview.offset_transform_rotation = -0.05
	MouseController.dragging_control = true
	
	return preview
	
