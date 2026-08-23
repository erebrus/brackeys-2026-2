class_name BaseLevel extends Node

@export var override_game_state: GameState


var game_state:GameState


func _ready() -> void:
	$Plant.place($PlantSlot)
	

func set_state(_game_state:GameState):
	game_state = _game_state
