class_name PlantType extends Resource

@export var nice_name:String 

@export var name: String

@export var textures: Dictionary[Plant.PlantState, Texture2D]

@export var facts: Array[Fact]

@export var start_facts: Array[String]

var current_facts: Array[String]


func has_correct_facts() -> bool:
	var extra: Array[String] = current_facts.duplicate()
	
	for fact: Fact in facts:
		if extra.has(fact.id):
			extra.erase(fact.id)
		else:
			return false
	
	return extra.is_empty()
	
