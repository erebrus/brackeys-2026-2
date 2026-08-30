extends Control


@export var plant: Plant

#@export var separate_met_and_unmet:= false

var tween: Tween

@onready var heart: TextureRect = $heart

@onready var plus_1: TextureRect = $plus1
@onready var plus_2: TextureRect = $plus2
@onready var plus_3: TextureRect = $plus3
@onready var minus_1: TextureRect = $minus1
@onready var minus_2: TextureRect = $minus2
@onready var minus_3: TextureRect = $minus3



func _ready() -> void:
	assert(plant != null)
	modulate.a = 0.0
	plant.met_requirements_changed.connect(_on_met_requirements_changed)
	

func _on_met_requirements_changed(met: int, unmet:int) -> void:
	if is_instance_valid(tween):
		tween.kill()
	
	var text = ""
	
	#if separate_met_and_unmet:
		#text = "".lpad(unmet, "-") + "".lpad(met, "+") 
	
	var total = met - unmet
	
	if total > 0:
		text = "".lpad(total, "+")
	elif total < 0:
		text = "".lpad(-total, "-")
	else:
		text = "="

	minus_3.visible = total <= -3
	minus_2.visible = total == -2
	minus_1.visible = total == -1
	heart.visible = total == 0
	plus_1.visible = total == 1
	plus_2.visible = total == 2
	plus_3.visible = total >= 3
		
	
	modulate.a = 1.0
	
	tween = create_tween()
	tween.tween_interval(2)
	tween.tween_property(self, "modulate:a", 0, 0.5)
	
