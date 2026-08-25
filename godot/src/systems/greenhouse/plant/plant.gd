class_name Plant extends Node2D

signal stat_changed(stat: Types.Stats, value: float)
signal hp_changed(value: float)
signal met_requirements_changed(met: int, unmet: int)
signal died

@export var hp_per_requirement_met: float = 10
@export var hp_per_requirement_unmet: float = -10

@export var wilt_threshold := 30.0
@export var bloom_threshold := 95.0

@export var type: PlantType


var slot: PlantSlot

var stats: Dictionary[Types.Stats, PlantStat]
var alive: bool = true
var hp: PlantStat
var met_requirements: int
var unmet_requirements: int

@onready var pickable_area: PickableArea = %PickableArea
@onready var debug_stat_container: Container = %DebugStatsContainer
@onready var plant_sprite: Sprite2D = %Plant


func _ready() -> void:
	assert(type != null)
	
	pickable_area.dropped.connect(_on_dropped)
	
	hp = PlantStat.create(Types.Stats.HP)
	hp.changed.connect(_on_hp_changed)
	hp.empty.connect(_on_hp_empty)
	
	var hp_progress = PlantStatDebugDisplay.create(hp)
	debug_stat_container.add_child(hp_progress)
	
	for requirement in type.requirements:
		var stat = PlantStat.create(requirement.stat_type) 
		
		stats[stat.type] = stat
		stat.changed.connect(stat_changed.emit)
		
		var progress = PlantStatDebugDisplay.create(stat)
		debug_stat_container.add_child(progress)
	
	
	debug_stat_container.visible = Debug.show_stats
	Debug.show_stats_changed.connect(func(x): debug_stat_container.visible = x)
	
	_update_plant_texture()
	

func _physics_process(delta: float) -> void:
	if not alive:
		return
	
	_update_requirements()
	
	hp.decay(delta)
	
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
	

func _update_requirements() -> void:
	var met := 0
	var unmet := 0
		
	for requirement in type.requirements:
		if _meets_requirement(requirement):
			met += 1
		else:
			unmet += 1
	
	if met != met_requirements or unmet != unmet_requirements:
		met_requirements_changed.emit(met, unmet)
		met_requirements = met
		unmet_requirements = unmet
		hp.decay_speed = met * hp_per_requirement_met + unmet * hp_per_requirement_unmet
	

func _meets_requirement(requirement: Requirement) -> bool:
	if not requirement.stat_type in stats:
		return false
	
	var stat = stats[requirement.stat_type]
	return requirement.minimum <= stat.current and stat.current <= requirement.maximum
	

func _update_plant_texture() -> void:
	var texture: Texture2D
	if is_equal_approx(hp.current, 0.0): 
		texture = type.dead_texture
	elif hp.current < wilt_threshold:
		texture = type.wilted_texture
	elif hp.current < bloom_threshold:
		texture = type.alive_texture
	else:
		texture = type.blooming_texture
	
	if texture != plant_sprite.texture:
		plant_sprite.texture = texture
	

func _on_dropped(area: DropArea) -> void:
	if area == null:
		return
		
	assert(area.target is PlantSlot)
	place(area.target)
	

func _on_hp_changed(_type: Types.Stats, current_hp: float) -> void:
	hp_changed.emit(current_hp)
	_update_plant_texture()
	

func _on_hp_empty(_type: Types.Stats) -> void:
	alive = false
	died.emit()
	
