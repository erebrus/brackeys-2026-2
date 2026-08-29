class_name Tool extends Node2D


@export var stat: Types.Stats
@export var pour_speed: float
@export_range(-180, 180, 0.001, "radians_as_degrees") var pour_rotation: float = 0.0

@export var particles: Array[GPUParticles2D]

var plant: Plant

@onready var pickable_area: PickableArea = $PickableArea
@onready var interaction_area: InteractionArea = $InteractionArea
@onready var pivot: Node2D = %RotationPivot
@onready var sfx: AudioStreamPlayer = $sfx
@onready var pickup_sfx: AudioStreamPlayer = $pickup_sfx


func _ready() -> void:
	pickable_area.dragged.connect(_on_dragged)
	pickable_area.dropped.connect(_on_dropped)
	pickable_area.picked.connect(func():pickup_sfx.play())

func _physics_process(delta: float) -> void:
	if plant == null:
		return
	
	plant.increase_stat(stat, pour_speed * delta)
	

func start_pouring() -> void:
	toggle_particles(true)
	pivot.rotation = pour_rotation
	sfx.play()

func stop_pouring() -> void:
	pivot.rotation = 0
	toggle_particles(false)
	sfx.stop()
	

func toggle_particles(on: bool) -> void:
	for particle in particles:
		particle.emitting = on
	

func _on_dragged() -> void:
	var plant_area := interaction_area.get_hover_area()
	var new_plant = plant_area.target as Plant if plant_area != null else null
	
	if new_plant != plant:
		plant = new_plant
		if plant:
			start_pouring()
		else:
			stop_pouring()
	


func _on_dropped(_area: DropArea) -> void:
	plant = null
	stop_pouring()
	
