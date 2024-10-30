class_name ShaderBlockManager
extends Node2D

static var instance : ShaderBlockManager

const project_format : String = "res://ShaderBlocks/Projects/%s.tscn"
const lorien_extension : String = ".lorien"
const shader_tag_start : String = "sh("
const shader_tag_end : String = ")"

var shader_project_dict : Dictionary = {}
var active_file : String

func _ready() -> void:
	instance = self
	ProjectManager.active_project_changed.connect(active_project_changed)


func active_project_changed (_p:Project, current:Project) -> void:
	
	if current and current.get_scene_file_path() == active_file: 
		return
		
	# clear out all children
	for child in get_children():
		remove_child(child)
	active_file = ""
	
	if not current: return
	
	var file := current.get_scene_file_path()
	active_file = file
	
	if shader_project_dict.has(file):
		add_child(shader_project_dict[file])
		return
	
	var index := file.find(shader_tag_start)
	if index >= 0:
		index += shader_tag_start.length()
		var end_index := file.findn(shader_tag_end, index)
		if end_index >= 0:
			var length := end_index - index
			var name := file.substr(index,length)
			var project := get_shader_project(name, file)
			add_child(project)

func get_shader_project(name : String, file : String) -> Node:
	var path := project_format % name
	print(path)
	
	if not ResourceLoader.exists(path): return null
	
	var shader_project_scene = load(path) as PackedScene
	var shader_project = shader_project_scene.instantiate() as Node
	shader_project_dict[file] = shader_project
	return shader_project
