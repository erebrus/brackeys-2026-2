class_name PlantType extends Resource

signal solved

@export var nice_name:String 

@export var name: String

@export var textures: Dictionary[Plant.PlantState, Texture2D]

@export var facts: Array[Fact]

var current_facts: Array[String]


func remove_fact(fact_id: String) -> void:
	current_facts.erase(fact_id)
	if has_correct_facts():
		solved.emit()
	

func add_fact(fact_id: String) -> void:
	current_facts.append(fact_id)
	if has_correct_facts():
		solved.emit()
	

func has_correct_facts() -> bool:
	var extra: Array[String] = current_facts.duplicate()
	
	for fact: Fact in facts:
		if extra.has(fact.id):
			extra.erase(fact.id)
		else:
			return false
	
	return extra.is_empty()
	
