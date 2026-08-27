@tool
extends EditorScript

const CSV_PATH = "res://src/resources/plants/plants.csv"
const RESOURCE_PATH = "res://src/resources/plants"
const IMAGE_PATH = "res://assets/gfx/plants"
const FACTS_PATH = "res://src/resources/facts"

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
	
	var facts := load_facts()
	
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
		var fact_ids := columns[2].strip_edges() if columns.size() > 2 else ""
		
		if save_plant(nice_name, plant_name, fact_ids, facts):
			imported += 1
	
	file.close()
	print("%s plant types imported into %s" % [imported, RESOURCE_PATH])
	EditorInterface.get_resource_filesystem().scan()
	

func load_facts() -> Dictionary[String, Fact]:
	var facts: Dictionary[String, Fact]
	
	var dir := DirAccess.open(FACTS_PATH)
	if not dir:
		print("Could not open %s" % FACTS_PATH)
		return facts
	
	for file_name: String in dir.get_files():
		if file_name.get_extension() not in ["tres", "res"]:
			continue
		
		var fact := load(FACTS_PATH.path_join(file_name)) as Fact
		if not fact:
			print("Skipping non-fact resource %s/%s" % [FACTS_PATH, file_name])
			continue
		
		var id: String = fact.id if not fact.id.is_empty() else file_name.get_basename()
		if id in facts:
			print("Duplicate fact id %s in %s/%s" % [id, FACTS_PATH, file_name])
		facts[id] = fact
	
	print("%s facts loaded from %s" % [facts.size(), FACTS_PATH])
	return facts
	

func resolve_facts(nice_name: String, fact_ids: String, facts: Dictionary[String, Fact]) -> Array[Fact]:
	var result: Array[Fact]
	
	for fact_id: String in fact_ids.split(",", false):
		var id := fact_id.strip_edges()
		if id.is_empty():
			continue
		
		if id not in facts:
			print("Unknown fact %s for plant %s" % [id, nice_name])
			continue
		
		result.append(facts[id])
	
	return result
	

func save_plant(nice_name: String, plant_name: String, fact_ids: String, facts: Dictionary[String, Fact]) -> bool:
	var path := RESOURCE_PATH.path_join("%s.tres" % [nice_name])
	

	var plant := PlantType.new()	
	plant.nice_name = nice_name
	plant.name = plant_name
	
	plant.textures[Plant.PlantState.DEAD] = load("%s/%s-%s.png" % [IMAGE_PATH, nice_name, "dead"])
	plant.textures[Plant.PlantState.WILTING] = load("%s/%s-%s.png" % [IMAGE_PATH, nice_name, "wilted"])
	plant.textures[Plant.PlantState.NORMAL] = load("%s/%s-%s.png" % [IMAGE_PATH, nice_name, "normal"])
	plant.textures[Plant.PlantState.THRIVING] = load("%s/%s-%s.png" % [IMAGE_PATH, nice_name, "healthy"])
	
	plant.facts = resolve_facts(nice_name, fact_ids, facts)
	if plant.facts.is_empty():
		print("Plant %s has no facts" % nice_name)
	
	for state:Plant.PlantState in plant.textures:
		if plant.textures[state] == null:
			print("Failed to load image for state %s for plant %s " % [state, nice_name])
	var err := ResourceSaver.save(plant, path)
	if err != OK:
		print("Could not save %s: %s" % [path, error_string(err)])
		return false
	
	print("Saved %s (nice_name=%s, name=%s, facts=%s)" % [path, nice_name, plant_name, plant.facts.size()])
	return true
	
