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
				active_shader_block.debug_code = get_debug_code(code_edit.text, line)
		elif active_shader_block:
			active_shader_block.debug_code = ""

func get_debug_code(code:String, line:int) -> String:
	var lines := code.split("\n")
	var selected_line := lines[line].dedent()
	
	var equals_index := selected_line.find("=")
	if equals_index < 0:
		return code
	var outname := selected_line.left(equals_index)
	var vectortype : int = -1
	
	if selected_line.begins_with("float "):
		outname = outname.substr(6)
		vectortype = 1
	if selected_line.begins_with("vec2 "):
		outname = outname.substr(5)
		vectortype = 2
	if selected_line.begins_with("vec3 "):
		outname = outname.substr(5)
		vectortype = 3
	if selected_line.begins_with("vec4 "):
		outname = outname.substr(5)
		vectortype = 4
	
	if vectortype == -1:
		return code
	
	var truncated_code := "\n".join(lines.slice(0, line+1))
	
	if vectortype == 1:
		truncated_code += "\nCOLOR = vec4(%s, %s, %s, 1.0);" % [outname,outname,outname]
	if vectortype == 2:
		truncated_code += "\nCOLOR = vec4(%s, 0.0, 1.0);" % outname
	if vectortype == 3:
		truncated_code += "\nCOLOR = vec4(%s, 1.0);" % outname
	if vectortype == 4:
		truncated_code += "\nCOLOR = %s;" % outname
	
	return truncated_code
