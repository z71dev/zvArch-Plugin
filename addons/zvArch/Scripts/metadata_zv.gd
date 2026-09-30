extends RefCounted
 
const main_script = preload("res://addons/zvArch/main_zv.gd")
const call_script = preload("res://addons/zvArch/Scripts/calls_zv.gd")

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
	if not FileAccess.file_exists(new_path):
		var new_result = SAVE_resultContent.new([new_err("C01",new_path)])
		return new_result
	var file = FileAccess.open(new_path,FileAccess.READ)
	if not file:
		var new_result = SAVE_resultContent.new([new_err("C02",new_path)])
		return new_result
	file.close()
	
	var new_result
	var load_metadata = call_script.loadzv(new_path)
	if s_l_metadata:
		var save_metadata = call_script.savezv(new_path,load_metadata.data,new_metadata)
		var group_errors : Array  = save_metadata.errors
		group_errors.append_array(load_metadata.errors)
		new_result = SAVE_resultContent.new(group_errors)
		return new_result
	new_result = LOAD_resultContent.new(load_metadata.errors,load_metadata.metadata)
	return new_result
