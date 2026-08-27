class_name CatalogPlantFact extends PanelContainer

var fact: Fact

@warning_ignore("shadowed_variable")
static func create(fact: Fact) -> CatalogPlantFact:
	var scene: CatalogPlantFact = load("uid://dmk74ill31lem").instantiate()
	scene.fact = fact
	return scene
	

func _ready() -> void:
	if fact == null:
		return
	
	%Label.text = fact.text
	
