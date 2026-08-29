class_name CatalogPage extends Resource

signal solved


@export var plants: Dictionary[String, PlantType]

var is_solved:= false


@warning_ignore("shadowed_variable")
static func create(plants: Array[PlantType]) -> CatalogPage:
	var page := CatalogPage.new()
	
	for plant in plants:
		if plant is PlantType:
			page.plants[plant.name] = plant
		
	
	for i in 100:
		if page.shuffle_facts(false):
			break
	
	return page
	

func shuffle_facts(force: bool) -> bool:
	var all_facts: Array[String]
	for plant: PlantType in plants.values():
		all_facts.append_array(plant.facts.map(func(x): return x.id))
	
	all_facts.shuffle()
	var facts_per_plant = all_facts.size() / plants.size()
	var remaining = all_facts.size() - facts_per_plant * plants.size()
	
	for idx in plants.size():
		var plant: PlantType = plants.values()[idx]
		plant.current_facts.clear()
		
		for i in facts_per_plant:
			if not _add_fact(plant, all_facts, force):
				return false
		
		if idx < remaining:
			if not _add_fact(plant, all_facts, force):
				return false
	
	return true
	

func _add_fact(plant: PlantType, all_facts: Array[String], force: bool) -> bool:
	for fact in all_facts:
		if not force and plant.current_facts.has(fact):
			continue
		
		plant.current_facts.append(fact)
		
		if not force and plant.has_correct_facts():
			plant.current_facts.erase(fact)
			continue
		
		all_facts.erase(fact)
		return true
	
	return false
	

func move_fact(fact_id: String, old_plant: PlantType, new_plant: PlantType) -> void:
	old_plant.remove_fact(fact_id)
	new_plant.add_fact(fact_id)
	
	if is_solved:
		return
	
	var is_complete:= true
	for plant: PlantType in plants.values():
		if not plant.has_correct_facts():
			GSLogger.info("Plant %s has facts %s, but should be %s" % [plant.name, plant.current_facts, plant.facts.map(func(x): return x.id)])
			is_complete = false
			break
		
	
	if is_complete:
		is_solved = true
		solved.emit()
	
