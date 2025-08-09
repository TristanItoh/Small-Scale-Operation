extends Node2D

@onready var lab_station = $LabIcon
@onready var pack_station = $PackIcon
@onready var quality_station = $QualityIcon
@onready var distribute_station = $Distribute
@onready var background = $Background
@onready var label = $Label

const SHADOW_1 = preload("res://assets/shadow1 (2).png")
const SHADOW_2 = preload("res://assets/shadow2 (2).png")
const SHADOW_3 = preload("res://assets/shadow3 (2).png")
const SHADOW_4 = preload("res://assets/shadow4.png")

func _ready():
	update_button_states()
	FadeEffect.fade_in()

func update_button_states():
	var station = GameState.get_station()

	lab_station.disabled = station != 1
	pack_station.disabled = station != 2
	quality_station.disabled = station != 3
	distribute_station.disabled = station != 4

	match station:
		1:
			background.texture = SHADOW_1
		2:
			background.texture = SHADOW_2
		3:
			background.texture = SHADOW_3
		4:
			background.texture = SHADOW_4
		_:
			print("Unknown station: ", station)
