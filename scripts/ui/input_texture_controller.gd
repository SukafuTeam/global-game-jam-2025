extends TextureRect

enum Type {
	NEXT,
	BACK,
	CREDITS,
	P1_JUMP,
	P2_JUMP
}

@export var type: Type

func _ready():
	InputDetector.input_changed.connect(input_changed)
	input_changed(0)

func input_changed(_p_index: int):
	match type:
		Type.NEXT:
			texture = InputDetector.current_next_texture
		Type.BACK:
			texture = InputDetector.current_back_texture
		Type.CREDITS:
			texture = InputDetector.current_credits_texture
		Type.P1_JUMP:
			texture = InputDetector.current_p1_jump_texture
		Type.P2_JUMP:
			texture = InputDetector.current_p2_jump_texture
