class_name ShaderTool
extends CanvasTool

# -------------------------------------------------------------------------------------------------
const SHADER_BLOCK = preload("res://ShaderBlock/ShaderBlock.tscn")

@onready var shaders_parent : Node2D = $"../SubViewport/Shaders"

# -------------------------------------------------------------------------------------------------
func tool_event(event: InputEvent) -> void:
	if event is InputEventMouseButton && !disable_stroke:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				create_shader_block(_cursor.global_position)

# -------------------------------------------------------------------------------------------------
func create_shader_block(position: Vector2) -> void:
	var block : Control = SHADER_BLOCK.instantiate()
	shaders_parent.add_child(block);
	block.position = position
	#var material = ShaderMaterial.new()
	#var shader = Shader.new()
