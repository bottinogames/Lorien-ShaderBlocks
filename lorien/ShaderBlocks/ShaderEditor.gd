class_name ShaderEditor
extends Panel

# ------------------------------------------------------------------------------
static var instance : ShaderEditor

@onready var code_edit : CodeEdit = $CodeEdit
@onready var update_button : Button = $UpdateButton
@onready var close_button : Button = $CloseButton

@onready var slider1 : Slider = $HSlider1
@onready var slider2 : Slider = $HSlider2
@onready var slider3 : Slider = $HSlider3

var active_shader_block : ShaderBlock = null

var code_edit_breakpoint_clearing : bool = false

# ------------------------------------------------------------------------------
func _ready() -> void:
	instance = self
	code_edit.breakpoint_toggled.connect(code_edit_breakpoint_toggled)
	update_button.pressed.connect(update_button_pressed)
	close_button.pressed.connect(close_button_pressed)
	ProjectManager.active_project_changed.connect(active_project_changed)
	
	slider1.value_changed.connect(slider1_change)
	slider2.value_changed.connect(slider2_change)
	slider3.value_changed.connect(slider3_change)
	
	visible = false

# ------------------------------------------------------------------------------
func set_active_shader_block(shader_block:ShaderBlock) -> void:
	if shader_block and shader_block != active_shader_block:
		if active_shader_block:
			active_shader_block.set_active(false)
		active_shader_block = shader_block
		shader_block.set_active(true)
		
		code_edit.text = shader_block.frag_code
		
		visible = true
		
	else:
		if active_shader_block:
			active_shader_block.set_active(false)
		active_shader_block = null
		visible = false
		release_focus()

# ------------------------------------------------------------------------------
func update_button_pressed() -> void:
	if active_shader_block:
		active_shader_block.frag_code = code_edit.text
	
	var breakpoints := code_edit.get_breakpointed_lines();
	if breakpoints.size() > 0:
		active_shader_block.debug_code = get_debug_code(code_edit.text, breakpoints[0]);
	
func close_button_pressed() -> void:
	set_active_shader_block(null)
	
	
# ------------------------------------------------------------------------------
func slider1_change(value : float) -> void:
	RenderingServer.global_shader_parameter_set("slider1", value)

func slider2_change(value : float) -> void:
	RenderingServer.global_shader_parameter_set("slider2", value)

func slider3_change(value : float) -> void:
	RenderingServer.global_shader_parameter_set("slider3", value)

# ------------------------------------------------------------------------------
func active_project_changed(__p: Project, __c: Project) -> void:
	set_active_shader_block(null)
	
# ------------------------------------------------------------------------------
func code_edit_breakpoint_toggled(line:int) -> void:
	release_focus()
	if not code_edit_breakpoint_clearing:
		if code_edit.is_line_breakpointed(line):
			code_edit_breakpoint_clearing = true
			code_edit.clear_breakpointed_lines()
			code_edit.set_line_as_breakpoint(line, true)
			code_edit_breakpoint_clearing = false
			
			if active_shader_block:
				active_shader_block.frag_code = code_edit.text
				active_shader_block.debug_code = get_debug_code(code_edit.text, line)
		elif active_shader_block:
			active_shader_block.debug_code = ""

func get_debug_code(code:String, line:int) -> String:
	var lines := code.split("\n")
	var selected_line := lines[line].strip_edges(true,true)
	
	var equals_index := selected_line.find("=")
	if equals_index < 0:
		return ""
	var outname := selected_line.left(equals_index).strip_edges(true,true)
	var vectortype : int = -1
	
	var typeout := get_vector_type(outname)
	vectortype = typeout[0]
	
	if vectortype == 0:
		var basename := outname
		var accessorindex = outname.find(".")
		if accessorindex > -1:
			basename = outname.left(accessorindex)
			
		for i in range(line-1, -1, -1):
			var backline := lines[i].dedent()
			var backequals := backline.find("=")
			if backequals < 0:
				continue
			var checkvar := backline.left(backequals).strip_edges(true,true)
			var checktypeout := get_vector_type(checkvar)
			if checktypeout[0] == 0:
				continue
			if basename == checktypeout[1]:
				vectortype = checktypeout[0]
				outname = basename
				break
	else:
		outname = typeout[1]
	
	if vectortype <= 0:
		return code
	
	var truncated_code := "\n".join(lines.slice(0, line+1))
	
	if active_shader_block.override_debug_types and active_shader_block.override_debug_types.size() > vectortype:
		truncated_code += active_shader_block.override_debug_types[vectortype].format({"value": outname})
	elif vectortype == 1:
		truncated_code += "\nCOLOR = vec4({value}, {value}, {value}, 1.0);".format({"value": outname})
	elif vectortype == 2:
		truncated_code += "\nCOLOR = vec4({value}, 0.0, 1.0);".format({"value": outname})
	elif vectortype == 3:
		truncated_code += "\nCOLOR = vec4({value}, 1.0);".format({"value": outname})
	elif vectortype == 4:
		truncated_code += "\nCOLOR = {value};".format({"value": outname})
	
	return truncated_code

func get_vector_type(inname:String) -> Array:
	var vectortype := 0
	var outname := inname
	
	var override_names = active_shader_block.override_debug_names;
	if override_names and override_names.has(inname):
		vectortype = override_names[inname]
	elif inname.begins_with("float "):
		outname = outname.substr(6)
		vectortype = 1
	elif inname.begins_with("vec2 "):
		outname = outname.substr(5)
		vectortype = 2
	elif inname.begins_with("vec3 "):
		outname = outname.substr(5)
		vectortype = 3
	elif inname.begins_with("vec4 "):
		outname = outname.substr(5)
		vectortype = 4
	elif inname.begins_with("COLOR"):
		outname = "COLOR"
		vectortype = 4
	
	return [vectortype, outname.strip_edges(true,true)]
