@tool
extends EditorScript

const RESOURCE_PATH = "res://src/resources/plants"
const IMAGE_PATH = "res://assets/gfx/plants"

func _run() -> void:
	var plants := load_previous_plants()
	update_images(plants)
	update_requirements(plants)
	
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
	

func update_requirements(plants: Dictionary[String, PlantType]) -> void:
	# TODO: load requirements from csv
	for plant: PlantType in plants.values():
		var reqs: Array[Requirement]
		if randf() < 0.5:
			reqs.append(create_requirement(Types.Stats.SUNLIGHT))
		else:
			reqs.append(create_requirement(Types.Stats.TEMPERATURE))
		
		reqs.append(create_requirement(Types.Stats.WATER))
		
		plant.requirements = reqs
	

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
	
	if plant.requirements.size() < 1:
		return false
		
	return true
