extends NinePatchRect
class_name CharOptionController

@export var char_index: int = 0

@onready var portrait: TextureRect = $PortraitMask/Portrait
@onready var frame: NinePatchRect = $FocusedFrame

var focused: bool:
	set(value):
		if value != focused:
			change_focus(value)
		focused = value
	get:
		return focused
var is_p1: bool:
	set(value):
		if value:
			frame.modulate = Constants.p1_color
		else:
			frame.modulate = Constants.p2_color
		is_p1 = value
	get:
		return is_p1

var selected: bool:
	set(value):
		if value != selected:
			if value:
				select()
			else:
				if focus_tween:
					focus_tween.kill()
				portrait.modulate.a = 1.0
				frame.visible = true
		selected = value
	get:
		return selected

var focus_tween:Tween


func _ready():
	portrait.texture = get_data().idle_portrait

func change_focus(new_focus: bool):
	if focus_tween:
		focus_tween.kill()
		
	focus_tween = create_tween()
	
	if new_focus:
		frame.visible = true
		focus_tween.tween_property(
			self,
			"scale",
			Vector2.ONE * 1.2,
			0.2
		).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	else:
		frame.visible = false
		focus_tween.tween_property(
			self,
			"scale",
			Vector2.ONE * 0.9,
			0.2
		).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)

func select():
	if focus_tween:
		focus_tween.kill()
	
	focus_tween = create_tween()
	focus_tween.tween_property(
		self,
		"scale",
		Vector2.ONE * 0.9,
		0.2
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_BACK)
	focus_tween.tween_callback(func():
		portrait.modulate.a = 0.5
		frame.visible = false
	)
	focus_tween.tween_property(
		self,
		"scale",
		Vector2.ONE * 1.2,
		0.2
	).set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)

func get_data():
	return Constants.get_character(char_index)
