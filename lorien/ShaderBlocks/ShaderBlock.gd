class_name ShaderBlock
extends Control

const template_shader : Shader = preload("res://ShaderBlocks/ShaderTemplate.gdshader")
const frag_code_insert_id : String = "//<FRAG_CODE>"

@export_multiline var starting_code : String = "COLOR = vec4(UV, 0.5, 1.0);"

@onready var background : Panel = $BackgroundPanel
@onready var highlight : Panel = $BackgroundPanel/HighlightPanel

@onready var shaderpanel : Panel = $BackgroundPanel/ShaderPanel
@onready var debugpanel : Panel = $BackgroundPanel/DebugPanel

var shader : Shader
var shadermaterial : ShaderMaterial

var debug_shader : Shader
var debug_shadermaterial : ShaderMaterial

var frag_code : String:
	get:
		return frag_code
	set(value):
		frag_code = value
		shader.code = template_shader.code.replace(frag_code_insert_id, value)

var debug_code : String:
	get:
		return debug_code
	set(value):
		if value.is_empty():
			debugpanel.visible = false
		else:
			debug_code = value
			debug_shader.code = template_shader.code.replace(frag_code_insert_id, value)
			debugpanel.visible = true

func _ready() -> void:
	background.gui_input.connect(background_input)
	
	shader = Shader.new()
	shadermaterial = ShaderMaterial.new()
	shadermaterial.shader = shader
	shaderpanel.material = shadermaterial
	
	debug_shader = Shader.new()
	debug_shadermaterial = ShaderMaterial.new()
	debug_shadermaterial.shader = debug_shader
	debugpanel.material = debug_shadermaterial
	
	set_active(false)
	
	frag_code = starting_code

func set_active(active : bool) -> void:
	highlight.visible = active
	if not active:
		debugpanel.visible = false

func background_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_RIGHT and event.is_pressed():
			if ShaderEditor.instance:
				ShaderEditor.instance.set_active_shader_block(self)
