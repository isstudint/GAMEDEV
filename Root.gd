extends Node2D

@onready var LevelPast = $LevelPast
@onready var LevelPresent = $LevelPresent

var is_past = true  


func _ready():

	LevelPast.visible = is_past
	LevelPast.set_process(is_past)
	
	LevelPresent.visible = !is_past
	LevelPresent.set_process(!is_past)


func _input(event):
	if event.is_action_pressed("switch_time"):  
		switch_timeline()

func switch_timeline():
	is_past = !is_past
	
	LevelPast.visible = is_past
	LevelPast.set_process(is_past)
	
	LevelPresent.visible = !is_past
	LevelPresent.set_process(!is_past)
