class_name ShaderBlockEditor
extends CodeEdit

# ------------------------------------------------------------------------------------------------
static var editorInstance : ShaderBlockEditor

@onready var update_button : Button = $UpdateButton

@onready var slider_x : Slider = $SliderX
@onready var slider_y : Slider = $SliderY
@onready var spinbox : SpinBox = $SpinBox

var current_shader_block : ShaderBlock

# ------------------------------------------------------------------------------------------------
func _ready() -> void:
	editorInstance = self
	update_button.pressed.connect(update_button_pressed)
	 
	slider_x.value_changed.connect(slider_x_changed)
	slider_y.value_changed.connect(slider_y_changed)
	spinbox.value_changed.connect(spinbox_changed)
	
	set_current_shader_block(null)
	
# ------------------------------------------------------------------------------------------------
func _process(delta: float) -> void:
	if current_shader_block:
		var new_position : Vector2 = current_shader_block.global_position
		new_position += Vector2(250.0,0.0)
		new_position -= PanZoomCamera.camera_instance.offset
		new_position *= PanZoomCamera.camera_instance.zoom
		global_position = new_position
		
		scale = PanZoomCamera.camera_instance.zoom

# ------------------------------------------------------------------------------------------------
func set_current_shader_block(shader_block : ShaderBlock) -> void:
	
	if not shader_block or shader_block == current_shader_block:
		current_shader_block = null
		global_position = Vector2(-1000.0,-1000.0)
	else :
		current_shader_block = shader_block
		text = shader_block.fragment_code
		slider_x.value = shader_block.shaderMaterial.get_shader_parameter("sliderx")
		slider_y.value = shader_block.shaderMaterial.get_shader_parameter("slidery")
		spinbox.value = shader_block.shaderMaterial.get_shader_parameter("num")

# ------------------------------------------------------------------------------------------------
func try_close_shader_block(shader_block : ShaderBlock) -> void:
	if shader_block == current_shader_block :
		current_shader_block = null
		global_position = Vector2(-1000.0,-1000.0)

# ------------------------------------------------------------------------------------------------
func update_button_pressed() -> void:
	if current_shader_block:
		current_shader_block.set_frag_code(text)


# ------------------------------------------------------------------------------------------------
func slider_x_changed(value:float) -> void:
	if current_shader_block:
		current_shader_block.shaderMaterial.set_shader_parameter("sliderx", value)

# ------------------------------------------------------------------------------------------------
func slider_y_changed(value:float) -> void:
	if current_shader_block:
		current_shader_block.shaderMaterial.set_shader_parameter("slidery", value)

# ------------------------------------------------------------------------------------------------
func spinbox_changed(value:float) -> void:
	if current_shader_block:
		current_shader_block.shaderMaterial.set_shader_parameter("num", value)
