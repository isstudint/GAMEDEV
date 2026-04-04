extends Parallax2D

@onready var cam = get_viewport().get_camera_2d()

func _process(delta):
	scroll_offset = cam.global_position * (Vector2.ONE - scroll_scale)
