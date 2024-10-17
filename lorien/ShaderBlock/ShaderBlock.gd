class_name ShaderBlock
extends Control

# ------------------------------------------------------------------------------------------------
@onready var shader_rect : ColorRect = $ShaderRect
@onready var edit_button : Button = $EditButton
@onready var close_button : Button = $CloseButton

const template_shader : Shader = preload("res://ShaderBlock/ShaderBlockTemplate.gdshader")
const frag_code_insert_id : String = "//<FRAG_CODE>"
const default_fragment_code : String = "COLOR = vec4(UV, 0.5, 1.0);"

var fragment_code : String

var shader : Shader
var shaderMaterial : ShaderMaterial

# ------------------------------------------------------------------------------------------------
func _ready() -> void:
	edit_button.pressed.connect(edit_button_pressed)
	close_button.pressed.connect(close_button_pressed)
	
	shader = template_shader.duplicate()
	shaderMaterial = ShaderMaterial.new()
	shaderMaterial.shader = shader
	shader_rect.material = shaderMaterial
	
	shaderMaterial.set_shader_parameter("sliderx", 0.0)
	shaderMaterial.set_shader_parameter("slidery", 0.0)
	shaderMaterial.set_shader_parameter("num", 0.0)
	
	set_frag_code(default_fragment_code)
	
# ------------------------------------------------------------------------------------------------
func edit_button_pressed() -> void:
	ShaderBlockEditor.editorInstance.set_current_shader_block(self)

# ------------------------------------------------------------------------------------------------
func close_button_pressed() -> void:
	ShaderBlockEditor.editorInstance.try_close_shader_block(self)
	queue_free()
	
# ------------------------------------------------------------------------------------------------
func set_frag_code(frag_code:String) -> void:
	fragment_code = frag_code
	shader.code = template_shader.code.replace(frag_code_insert_id, frag_code)
