class_name Plant extends Node2D

signal stat_changed(stat: Types.Stats, value: float)
signal hp_changed(value: float)
signal met_requirements_changed(met: int, unmet: int)
signal state_changed(state: PlantState)

enum PlantState { DEAD, WILTING, NORMAL, THRIVING}

@export var hp_per_requirement_met: float = 10
@export var hp_per_requirement_unmet: float = -2

@export var wilt_threshold := 35.0
@export var bloom_threshold := 99.0

@export var type: PlantType

@onready var destroy_sfx: AudioStreamPlayer = $sfx/destroy_sfx

var slot: PlantSlot
var pot: Pot

var stats: Dictionary[Types.Stats, PlantStat]
var state: PlantState = PlantState.NORMAL
var hp: PlantStat
var met_requirements: int
var unmet_requirements: int

@onready var debug_stat_container: Container = %DebugStatsContainer
@onready var plant_sprite: Sprite2D = %Plant
@onready var pickup_plant_sfx: AudioStreamPlayer = $sfx/pickup_plant_sfx

@onready var drop_plant_cart_sfx: AudioStreamPlayer = $sfx/drop_plant_cart_sfx
@onready var drop_plant_invalid_sfx: AudioStreamPlayer = $sfx/drop_plant_invalid_sfx
@onready var drop_plant_slot_sfx: AudioStreamPlayer = $sfx/drop_plant_slot_sfx
@onready var blossom_sfx: AudioStreamPlayer = $sfx/blossom_sfx
@onready var death_sfx: AudioStreamPlayer = $sfx/death_sfx


@warning_ignore("shadowed_variable")
static func create(type: PlantType) -> Plant:
	var scene: Plant = load("uid://fkj5cerqpbce").instantiate()
	scene.type = type
	
	return scene
	

func _ready() -> void:
	assert(type != null)
	
	_setup_stats()
	
	state_changed.connect(_on_state_changed)
	_update_plant_sprite()
	
	_setup_pot()
	

func _physics_process(delta: float) -> void:
	if state == PlantState.DEAD:
		return
	
	if slot == null or not slot.allow_stat_decay:
		return
	
	if pot.pickable_area.is_dragging:
		return
	
	_update_requirements()
	
	hp.decay(delta)
	
	for stat: PlantStat in stats.values():
		stat.decay(delta)
	

func increase_stat(stat: Types.Stats, delta: float) -> void:
	if stat in stats:
		stats[stat].increase(delta)
	

func update_stat(stat: Types.Stats, value: float) -> void:
	if stat in stats:
		stats[stat].update(value)
	

func _setup_stats() -> void:
	hp = PlantStat.create(Types.Stats.HP)
	hp.changed.connect(_on_hp_changed)
	
	var hp_progress = PlantStatDebugDisplay.create(hp)
	debug_stat_container.add_child(hp_progress)
	
	for fact in type.facts:
		if fact.requirement == null:
			continue
		
		var stat = PlantStat.create(fact.requirement.stat_type) 
		if fact.requirement.custom_decay_speed:
			stat.decay_speed = fact.requirement.decay_speed
		
		stats[stat.type] = stat
		stat.changed.connect(stat_changed.emit)
		
		var progress = PlantStatDebugDisplay.create(stat)
		debug_stat_container.add_child(progress)
	
	debug_stat_container.visible = Debug.show_stats
	Debug.show_stats_changed.connect(func(x): debug_stat_container.visible = x)
	

func _setup_pot() -> void:
	pot = Pot.create(self)
	pot.picked.connect(func():pickup_plant_sfx.play())
	pot.clicked.connect(_on_clicked)
	pot.dropped.connect(_on_dropped)
	add_child(pot)
	
	var pot_base = pot.get_plant_base()
	plant_sprite.position.y = pot_base.y - plant_sprite.texture.get_height() / 2.0
	plant_sprite.position.x = pot_base.x
	

func _update_requirements() -> void:
	var met := 0
	var unmet := 0
	
	hp.maximum = 100
	hp.minimum = 0
	
	for fact in type.facts:
		if fact.requirement == null:
			continue
		
		if _meets_requirement(fact.requirement):
			met += 1
			hp.minimum = 25
		else:
			unmet += 1
			hp.maximum = 75
	
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
	

func _update_plant_state() -> void:
	var new_state: PlantState 
	
	if is_equal_approx(hp.current, 0.0): 
		new_state = PlantState.DEAD
	elif hp.current < wilt_threshold:
		new_state = PlantState.WILTING
	elif hp.current < bloom_threshold:
		new_state = PlantState.NORMAL
	else:
		new_state = PlantState.THRIVING
	
	if new_state != state:
		state = new_state
		state_changed.emit(state)
	

func _update_plant_sprite() -> void:
	plant_sprite.texture = type.textures[state]
	

func _on_clicked() -> void:
	if state == PlantState.DEAD:
		destroy_sfx.play()
		destroy_sfx.finished.connect(destroy_sfx.queue_free)
		destroy_sfx.reparent(get_parent())
		queue_free()
		

func _on_dropped(new_slot: PlantSlot) -> void:
	if new_slot != null:
		new_slot.set_plant(self)
		if new_slot.allow_stat_decay:
			drop_plant_slot_sfx.play()
		else:
			drop_plant_cart_sfx.play()
	else:
		drop_plant_invalid_sfx.play()

func _on_hp_changed(_type: Types.Stats, current_hp: float) -> void:
	hp_changed.emit(current_hp)
	_update_plant_state()
	

func _on_state_changed(_state: PlantState) -> void:
	_update_plant_sprite()
	if _state == PlantState.THRIVING:
		blossom_sfx.play()
	elif _state == PlantState.DEAD:
		death_sfx.play()
	
