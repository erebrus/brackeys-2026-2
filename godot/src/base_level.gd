class_name BaseLevel extends Node2D

const SCREEN_SIZE = Vector2(1920, 1080)

@export var override_game_state: GameState


var current_room := 0
var greenhouses: Array[Greenhouse]
var tween: Tween

var game_state:GameState


func set_state(_game_state:GameState):
	game_state = _game_state
	

func _ready() -> void:
	for child in get_children():
		if child is Greenhouse:
			greenhouses.append(child)
	prepare_next_rooms()
	

func move_room(direction: int) -> void:
	current_room = (current_room + direction) % greenhouses.size()
	var target_position := - greenhouses[current_room].position.x
	
	if is_instance_valid(tween):
		tween.kill()
	
	tween = create_tween()
	tween.tween_property(self, "global_position:x", target_position, 0.5)
	
	prepare_next_rooms()
	

func prepare_next_rooms() -> void:
	var left = (current_room - 1) % greenhouses.size()
	var right = (current_room + 1) % greenhouses.size()
	
	greenhouses[left].position.x = greenhouses[current_room].position.x - SCREEN_SIZE.x
	greenhouses[right].position.x = greenhouses[current_room].position.x + SCREEN_SIZE.x
	
	
