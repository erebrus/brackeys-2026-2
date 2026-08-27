@tool
extends EditorScript

const CSV_PATH = "res://src/resources/facts/facts.csv"
const RESOURCE_PATH = "res://src/resources/facts"

func _run() -> void:
	var file := FileAccess.open(CSV_PATH, FileAccess.READ)
	if not file:
		print("Could not open %s: %s" % [CSV_PATH, error_string(FileAccess.get_open_error())])
		return
	
	var is_header := true
	var imported := 0
	
	while not file.eof_reached():
		var columns := file.get_csv_line()
		
		if is_header:
			is_header = false
			continue
		
		if columns.is_empty() or columns[0].strip_edges().is_empty():
			continue
		
		var fact := create_fact(columns)
		if fact and save_fact(fact):
			imported += 1
	
	file.close()
	print("%s facts imported into %s" % [imported, RESOURCE_PATH])
	EditorInterface.get_resource_filesystem().scan()
	

func create_fact(columns: PackedStringArray) -> Fact:
	var fact := Fact.new()
	fact.id = columns[0].strip_edges()
	fact.text = columns[1].strip_edges() if columns.size() > 1 else ""
	
	var stat_name := columns[2].strip_edges() if columns.size() > 2 else ""
	if stat_name.is_empty():
		fact.requirement = null
		return fact
	
	var stat_key := stat_name.to_upper()
	if not Types.Stats.has(stat_key):
		print("Skipping fact %s: unknown stat type '%s'" % [fact.id, stat_name])
		return fact
	
	var requirement := Requirement.new()
	requirement.stat_type = Types.Stats[stat_key]
	requirement.decay_speed = column_as_float(columns, 3, fact.id, "decay_speed")
	requirement.minimum = column_as_float(columns, 4, fact.id, "minimum")
	requirement.maximum = column_as_float(columns, 5, fact.id, "maximum")
	fact.requirement = requirement
	
	return fact
	

func column_as_float(columns: PackedStringArray, index: int, fact_id: String, field: String) -> float:
	if columns.size() <= index:
		print("Fact %s has no %s column, defaulting to 0" % [fact_id, field])
		return 0.0
	
	var value := columns[index].strip_edges()
	if not value.is_valid_float():
		if not value.is_empty():
			print("Fact %s has invalid %s '%s', defaulting to 0" % [fact_id, field, value])
		return 0.0
	
	return value.to_float()
	

func save_fact(fact: Fact) -> bool:
	var path := RESOURCE_PATH.path_join(file_name_for(fact.id))
	
	var err := ResourceSaver.save(fact, path)
	if err != OK:
		print("Could not save %s: %s" % [path, error_string(err)])
		return false
	
	print("Saved %s" % path)
	return true
	

func file_name_for(id: String) -> String:
	var base := id.to_snake_case().validate_filename()
	if base.is_empty():
		base = "fact"
	return base + ".tres"
