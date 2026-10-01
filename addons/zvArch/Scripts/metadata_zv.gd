extends RefCounted
 
const main_script = preload("res://addons/zvArch/main_zv.gd")
const load_script = preload("res://addons/zvArch/Scripts/load_zv.gd")
const save_script = preload("res://addons/zvArch/Scripts/save_zv.gd")

class SAVE_resultContent:
	var errors : Array = []
	func _init(temp_err : Array) -> void:errors = temp_err

class LOAD_resultContent:
	var errors : Array = []
	var metadata : Dictionary = {}
	
	func _init(temp_err : Array, temp_mtdt : Dictionary = {}) -> void:
		errors = temp_err
		metadata = temp_mtdt

static func new_err(num_err : String, path : String, line : int = 0):
	var err_dict = main_script.ERROR_DICT
	var err = err_dict[num_err]
	if line == 0:
		printerr(str(err+" | Path: ", path))
		return str(err+" | Path: ", path)
	else: 
		printerr(str(err," | Line: ", line ," | Path: ", path))
		return str(err," | Line: ", line ," | Path: ", path)

static func parser_METADATA(s_l_metadata :  bool,new_path : String, new_metadata :  Dictionary = {}):
	if new_path.get_extension().to_lower() != "zv": 
		var new_result = SAVE_resultContent.new([new_err("C05",new_path)])
		return new_result
	if not FileAccess.file_exists(new_path) and not s_l_metadata:
		var new_result = SAVE_resultContent.new([new_err("C01",new_path)])
		return new_result
	var new_result 
	if s_l_metadata:
		var save_metadata = save_script.parser_WRITE(new_path,{},new_metadata,true)
		new_result = SAVE_resultContent.new(save_metadata.errors)
		return new_result
	else: 
		var load_metadata = load_script.parser_READ(new_path, true)
		new_result = LOAD_resultContent.new(load_metadata.errors,load_metadata.metadata)
		return new_result
