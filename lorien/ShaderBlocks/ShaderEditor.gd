class_name ShaderEditor
extends Panel

# ------------------------------------------------------------------------------
static var instance : ShaderEditor

@onready var code_edit : CodeEdit = $CodeEdit
@onready var update_button : Button = $UpdateButton
@onready var close_button : Button = $CloseButton

var active_shader_block : ShaderBlock = null

var code_edit_breakpoint_clearing : bool = false

# ------------------------------------------------------------------------------
func _ready() -> void:
	instance = self
	code_edit.breakpoint_toggled.connect(code_edit_breakpoint_toggled)
	update_button.pressed.connect(update_button_pressed)
	close_button.pressed.connect(close_button_pressed)
	ProjectManager.active_project_changed.connect(active_project_changed)
	
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
	
	if vectortype == -1:
		return code
	
	var truncated_code := "\n".join(lines.slice(0, line+1))
	
	if vectortype == 1:
		truncated_code += "\nCOLOR = vec4(%s, %s, %s, 1.0);" % [outname,outname,outname]
	elif vectortype == 2:
		truncated_code += "\nCOLOR = vec4(%s, 0.0, 1.0);" % outname
	elif vectortype == 3:
		truncated_code += "\nCOLOR = vec4(%s, 1.0);" % outname
	elif vectortype == 4:
		truncated_code += "\nCOLOR = %s;" % outname
	
	return truncated_code

func get_vector_type(inname:String) -> Array:
	var vectortype := 0
	var outname := inname
	
	if inname.begins_with("float "):
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
