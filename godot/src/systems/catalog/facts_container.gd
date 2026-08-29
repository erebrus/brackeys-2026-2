class_name PlantFactsContainer extends VBoxContainer

signal fact_added(fact: CatalogPlantFact)


var solved: bool

func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	if solved:
		return false
	
	if not data is CatalogPlantFact:
		return false
	
	if get_child_count() > 3:
		return false
		
	return true
	

func _drop_data(at_position: Vector2, data: Variant) -> void:
	var fact := data as CatalogPlantFact
	
	if fact == null:
		return
	
	fact.reparent(self)
	fact_added.emit(fact)
	
