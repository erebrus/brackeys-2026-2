extends PanelContainer


@export var plant: Plant

@export var separate_met_and_unmet:= false

var tween: Tween


@onready var change_label: Label = %ChangeLabel


func _ready() -> void:
	assert(plant != null)
	modulate.a = 0.0
	plant.met_requirements_changed.connect(_on_met_requirements_changed)
	

func _on_met_requirements_changed(met: int, unmet:int) -> void:
	if is_instance_valid(tween):
		tween.kill()
	
	var text = ""
	
	if separate_met_and_unmet:
		text = "".lpad(unmet, "-") + "".lpad(met, "+") 
	else:
		var total = met - unmet
		if total > 0:
			text = "".lpad(total, "+")
		elif total < 0:
			text = "".lpad(-total, "-")
		else:
			text = "="
	
	
	change_label.text = text
	modulate.a = 1.0
	
	tween = create_tween()
	tween.tween_interval(2)
	tween.tween_property(self, "modulate:a", 0, 0.5)
	
