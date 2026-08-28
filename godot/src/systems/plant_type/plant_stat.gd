class_name PlantStat extends RefCounted

signal changed(type: Types.Stats, value: float)
signal full(type: Types.Stats)
signal empty(type: Types.Stats)

signal decay_speed_changed(type: Types.Stats, value: float)


const DEFAULT_DECAY_SPEED: Dictionary[Types.Stats, float] = {
	Types.Stats.WATER: -1,
	Types.Stats.SLIME: -1,
	Types.Stats.BLOOD: -1,
	Types.Stats.AFFECTION: -1,
	Types.Stats.BUGS: -1
}

var type: Types.Stats

var minimum: float = 0:
	set(value):
		if value == minimum:
			return
		minimum = value
		update(current)
	

var maximum: float = 100:
	set(value):
		if value == maximum:
			return
		maximum = value
		update(current)
	

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
	
	if DEFAULT_DECAY_SPEED.has(type):
		stat.decay_speed = DEFAULT_DECAY_SPEED[type]
	
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
