extends TextureButton


func _ready() -> void:
	
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
func _on_mouse_entered() -> void:
	$Label.set("theme_override_colors/font_color",Color("9b8fb3"))

func _on_mouse_exited() -> void:
	pass
	$Label.set("theme_override_colors/font_color",Color("382842"))
