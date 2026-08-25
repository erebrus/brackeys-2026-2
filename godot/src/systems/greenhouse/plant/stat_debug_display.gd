class_name PlantStatDebugDisplay extends HBoxContainer

var stat: PlantStat

@onready var progress := %ProgressBar


func _ready() -> void:
	%Label.text = Types.Stats.keys()[stat.type]
	progress.min_value = stat.minimum
	progress.max_value = stat.maximum
	progress.value = stat.current
	
	stat.changed.connect(_on_stat_changed)
	

func _on_stat_changed(_type: Types.Stats, value: float) -> void:
	progress.value = value
	

@warning_ignore("shadowed_variable")
static func create(stat: PlantStat) -> PlantStatDebugDisplay:
	var scene = load("uid://rb8p3x2axwyy").instantiate() as PlantStatDebugDisplay
	scene.stat = stat
	return scene
