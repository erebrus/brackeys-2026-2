@tool
extends EditorScript

const CSV_PATH = "res://src/resources/plants/plants.csv"
const RESOURCE_PATH = "res://src/resources/plants"
const IMAGE_PATH = "res://assets/gfx/plants"

func _run() -> void:
	var file := FileAccess.open(CSV_PATH, FileAccess.READ)
	if not file:
		print("Could not open %s: %s" % [CSV_PATH, error_string(FileAccess.get_open_error())])
		return
	
	if not DirAccess.dir_exists_absolute(RESOURCE_PATH):
		var err := DirAccess.make_dir_recursive_absolute(RESOURCE_PATH)
		if err != OK:
			print("Could not create %s: %s" % [RESOURCE_PATH, error_string(err)])
			return
	
	var is_header := true
	var imported := 0
	
	while not file.eof_reached():
		var columns := file.get_csv_line()
		
		if is_header:
			is_header = false
			continue
		
		if columns.size() < 2 or columns[0].strip_edges().is_empty():
			continue
		
		var nice_name := columns[0].strip_edges()
		var plant_name := columns[1].strip_edges()
		
		if save_plant(nice_name, plant_name):
			imported += 1
	
	file.close()
	print("%s plant types imported into %s" % [imported, RESOURCE_PATH])
	EditorInterface.get_resource_filesystem().scan()
	

func save_plant(nice_name: String, plant_name: String) -> bool:
	var path := RESOURCE_PATH.path_join("%s.tres" % [nice_name])
	

	var plant := PlantType.new()	
	plant.nice_name = nice_name
	plant.name = plant_name
	
	plant.textures[Plant.PlantState.DEAD] = load("%s/%s-%s.png" % [IMAGE_PATH, nice_name, "dead"])
	plant.textures[Plant.PlantState.WILTING] = load("%s/%s-%s.png" % [IMAGE_PATH, nice_name, "wilted"])
	plant.textures[Plant.PlantState.NORMAL] = load("%s/%s-%s.png" % [IMAGE_PATH, nice_name, "normal"])
	plant.textures[Plant.PlantState.THRIVING] = load("%s/%s-%s.png" % [IMAGE_PATH, nice_name, "healthy"])
	
	for state:Plant.PlantState in plant.textures:
		if plant.textures[state] == null:
			print("Failed to load image for state %s for plant %s " % [state, nice_name])
	var err := ResourceSaver.save(plant, path)
	if err != OK:
		print("Could not save %s: %s" % [path, error_string(err)])
		return false
	
	print("Saved %s (nice_name=%s, name=%s)" % [path, nice_name, plant_name])
	return true
	
