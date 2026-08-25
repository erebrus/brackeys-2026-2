class_name PlantStat extends RefCounted

signal changed(type: Types.Stats, value: float)
signal full(type: Types.Stats)
signal empty(type: Types.Stats)

signal decay_speed_changed(type: Types.Stats, value: float)


var type: Types.Stats

var minimum: float = 0
var maximum: float = 100
var current: float = 50

var decay_speed: float = 0:
	set(value):
		if value == decay_speed:
			return
		decay_speed = value
		decay_speed_changed.emit(type, decay_speed)
	

@warning_ignore("shadowed_variable")
static func create(type: Types.Stats) -> PlantStat:
	var stat = PlantStat.new()
	stat.type = type
	
	# TODO: start values by type
	if type == Types.Stats.WATER:
		stat.decay_speed = -1.0
	
	return stat
	

func decay(delta: float) -> void:
	increase(decay_speed * delta)
	

func increase(delta: float) -> void:
	if delta == 0.0:
		return
	
	update(current + delta)
	

func update(new_value: float) -> void:
	new_value = clamp(new_value, minimum, maximum)
	
	if new_value == current:
		return
		
	current = new_value
	changed.emit(type, current)
	
	if current == maximum:
		full.emit(type)
	
	if current == minimum:
		empty.emit(type)
