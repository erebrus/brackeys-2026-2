class_name Plant extends Node2D

signal stat_changed(stat: Types.Stats, value: float)

var slot: PlantSlot

var stats: Dictionary[Types.Stats, PlantStat]


@onready var pickable_area: PickableArea = %PickableArea


func _init() -> void:
	for stat in Types.Stats.values():
		stats[stat] = PlantStat.create(stat)
		stats[stat].empty.connect(_on_stat_updated)
		stats[stat].full.connect(_on_stat_updated)
		stats[stat].changed.connect(stat_changed.emit)
	

func _ready() -> void:
	pickable_area.dropped.connect(_on_dropped)
	

func _physics_process(delta: float) -> void:
	for stat: PlantStat in stats.values():
		stat.decay(delta)
	

func place(at: PlantSlot) -> void:
	slot = at
	at.plant = self
	global_position = at.drop_area.global_position
	

func increase_stat(stat: Types.Stats, delta: float) -> void:
	if stat in stats:
		stats[stat].increase(delta)
	

func update_stat(stat: Types.Stats, value: float) -> void:
	if stat in stats:
		stats[stat].update(value)
	

func _on_dropped(area: DropArea) -> void:
	if area == null:
		return
		
	assert(area.target is PlantSlot)
	place(area.target)
	

func _on_stat_updated(type: Types.Stats) -> void:
	GSLogger.info("Updated stat %s to %s on plant %s" % [Types.Stats.keys()[type], stats[type].current, name])
