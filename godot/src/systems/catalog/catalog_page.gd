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
		
	
	page.shuffle_facts()
	return page
	

func shuffle_facts() -> void:
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
			plant.current_facts.append(all_facts.pop_front())
		
		if idx < remaining:
			plant.current_facts.append(all_facts.pop_front())
	
	# TODO: if any plant is solved, shuffle again?
	

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
	
