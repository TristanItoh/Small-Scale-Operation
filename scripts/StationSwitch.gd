extends Button

@export var scene_to_load : PackedScene

func _ready():
	self.pressed.connect(_on_Button_pressed)

func _on_Button_pressed():
	if scene_to_load:
		self.disabled = true
		await FadeEffect.fade_out()
		get_tree().change_scene_to_packed(scene_to_load)
	else:
		print("No scene assigned to load!")
