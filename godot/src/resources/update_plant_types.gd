@tool
extends EditorScript

const RESOURCE_PATH = "res://src/resources/plants"
const IMAGE_PATH = "res://assets/gfx/plants"

func _run() -> void:
	var plants := load_previous_plants()
	update_images(plants)
	update_facts(plants)
	
	for plant_name in plants:
		if is_valid(plants[plant_name]):
			ResourceSaver.save(plants[plant_name], RESOURCE_PATH.path_join(plant_name + ".tres"))
	

func load_previous_plants() -> Dictionary[String, PlantType]:
	print("Loading plant resources")
	var resources = load_resources(RESOURCE_PATH)
	
	var plants: Dictionary[String, PlantType]
	
	for r in resources:
		if r is PlantType:
			var plant = r as PlantType
			plants[r.name] = plant
	
	print("%s plants loaded" % plants.size())
	return plants
	

func update_images(plants: Dictionary[String, PlantType]) -> void:
	print("Loading images in %s" % IMAGE_PATH)
	var dir = DirAccess.open(IMAGE_PATH)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if file_name.get_extension() != "png":
				print("Skipping non image %s/%s" % [IMAGE_PATH, file_name])
			else:
				var no_extension = file_name.substr(0, file_name.length() - 4)
				var parts = no_extension.split("-")
				
				if parts.size() != 2:
					print("Skipping image %s/%s" % [IMAGE_PATH, file_name])
				else:
					var name = parts[0]
					var state = parts[1]
					
					var plant: PlantType
					if name in plants:
						plant = plants[name]
					else:
						plant = PlantType.new()
						plant.name = name
						plants[name] = plant
					
					set_image(plant, state, load("%s/%s" % [IMAGE_PATH, file_name]))
					
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	

func update_facts(plants: Dictionary[String, PlantType]) -> void:
	# TODO: load facts from csv
	for plant: PlantType in plants.values():
		
		var fact1 := Fact.new()
		
		if randf() < 0.5:
			fact1.requirement = create_requirement(Types.Stats.SUNLIGHT)
		else:
			fact1.requirement = create_requirement(Types.Stats.TEMPERATURE)
		update_fact_name(fact1)
		
		var fact2 := Fact.new()
		
		fact2.requirement = create_requirement(Types.Stats.WATER)
		if randf() < 0.5:
			fact2.requirement.decay_speed = -1.0
		else:
			fact2.requirement.decay_speed = -8.0
		update_fact_name(fact2)
		if fact2.requirement.decay_speed > -8.0:
			fact2.text += ", and is not very thirsty"
		else:
			fact2.text += ", and is very thirsty"
		
		fact1.id = fact1.text
		fact2.id = fact2.text
		plant.facts = [fact1, fact2]
	

func set_image(plant: PlantType, state_name: String, texture: Texture2D) -> void:
	var state: Plant.PlantState
	match state_name:
		"dead":
			state = Plant.PlantState.DEAD
		"wilted":
			state = Plant.PlantState.WILTING
		"normal":
			state = Plant.PlantState.NORMAL
		"healthy":
			state = Plant.PlantState.THRIVING
		_:
			print("Unknown plant state %s for plant %s" % [state_name, plant.name])
			return
	
	plant.textures[state] = texture
	

func create_requirement(stat: Types.Stats) -> Requirement:
	var requirement = Requirement.new()
	requirement.stat_type = stat
	if randf() < 0.5:
		requirement.minimum = 50.0
		requirement.maximum = 100.0
	else:
		requirement.minimum = 0.0
		requirement.maximum = 50.0
		
	return requirement
	

func update_fact_name(fact: Fact) -> void:
	var name: String
	if fact.requirement.minimum < 1.0:
		name = "Hates "
	else:
		name = "Loves "
	
	name += Types.Stats.keys()[fact.requirement.stat_type].to_lower()
	
	fact.text = name
	

func load_resources(path: String) -> Array:
	var result: Array[Resource]
	print("Loading resources in %s" % path)
	
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if dir.current_is_dir():
				var child_results = load_resources(path.path_join(file_name))
				result.append_array(child_results)
			else:
				var trimed = file_name.trim_suffix(".remap")
				if trimed.get_extension() not in ["res", "tres", "tscn"]:
					print("Skipping non-resource %s/%s" % [path, file_name])
				else:
					print("Loading resource %s/%s" % [path, file_name])
					
					var res = load(path.path_join(trimed))
					result.append(res)
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	
	return result
	

func is_valid(plant: PlantType) -> bool:
	if plant.name.is_empty():
		return false
	
	for state in Plant.PlantState.values():
		if not plant.textures.has(state):
			return false
	
	if plant.facts.size() < 1:
		return false
		
	return true
