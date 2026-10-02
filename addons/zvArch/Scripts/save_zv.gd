extends RefCounted

const main_script = preload("res://addons/zvArch/main_zv.gd")

class saveContent:
	var path : String
	var line_index : int
	var lines : Array = []
	var data : Dictionary 
	var warn : Array = []
	var mtdt : Dictionary = {}
	
	func _init(temp_path : String, temp_data : Dictionary, temp_mtdt : Dictionary) -> void:
		path = temp_path
		data = temp_data
		mtdt = temp_mtdt

class resultContent:
	var errors: Array = []
	
	func _init(temp_err : Array) -> void:
		errors = temp_err

enum type_data {DEFAULT, ARRAY, ENUM}

static func new_err(num_err : String, path : String, line : int = 0):
	var err_dict = main_script.ERROR_DICT
	var err = err_dict[num_err]
	if line == 0:
		push_warning(str(err+" | Path: ", path))
		return str(err+" | Path: ", path)
	else: 
		printerr(str(err," | Key: ", line ," | Path: ", path))
		return str(err," | Key: ", line ," | Path: ", path)

static func parser_WRITE(new_path: String, new_data : Dictionary, new_metadata : Dictionary = {}, only_metadata : bool = false):
	var new_save : saveContent = saveContent.new(new_path, new_data, new_metadata) 
	if only_metadata:
		if not FileAccess.file_exists(new_path):
			var file = FileAccess.open(new_path,FileAccess.WRITE)
			file.store_string("")
			file.close()
		var file = FileAccess.open(new_path,FileAccess.READ)
		if not file:
			var new_result = resultContent.new([new_err("C02",new_path)])
			return new_result
		var temp_text = file.get_as_text().strip_edges()
		file.close()
		if temp_text.is_empty():
			new_save.lines.append(format_main("version",main_script.namePlugin,str(main_script.version.front()),type_data.DEFAULT))
			new_save.lines.append("")
		var text = temp_text.split("\n")
		var init = text.find("mtdt/")
		var finish = text.find("/mtdt")
		if init != -1 and finish != -1 and init < finish:
			text = text.slice(0,init) + text.slice(finish + 1)
			new_save.lines.append_array(text)
		elif init == -1 and finish == -1:
			if not temp_text.is_empty():
				new_save.lines.append_array(text)
		else:
			var new_result = resultContent.new([new_err("M01",new_path)])
			return new_result
	else: 
		new_save.lines.append(format_main("version",main_script.namePlugin,str(main_script.version.front()),type_data.DEFAULT))
		new_save.lines.append("")
		main_parser(new_save,type_data.DEFAULT,new_data) #Data
	if not new_metadata.is_empty(): 
		new_save.lines.append("")
		new_save.lines.append("mtdt/")
		main_parser(new_save,type_data.DEFAULT,new_metadata) #Metadata
		new_save.lines.append("/mtdt")
	if new_path.get_extension().to_lower() != "zv": 
		var new_result = resultContent.new([new_err("C05",new_path)])
		return new_result
	var file = FileAccess.open(new_path,FileAccess.WRITE)
	if not file:
		var new_result = resultContent.new([new_err("S01",new_path)])
		return new_result
	file.store_string("\n".join(new_save.lines))
	file.close()
	var new_result = resultContent.new(new_save.warn)
	return new_result

static func main_parser(saveC : saveContent, typ_data : type_data, data):
	var keys  = data.keys() if data is Dictionary else range(data.size())
	for key in keys:
		saveC.line_index += 1
		if typeof(key) != TYPE_STRING and typ_data != type_data.ARRAY:
			saveC.warn.append(new_err("S03",saveC.path,saveC.line_index))
		match typeof(data[key]):
			TYPE_DICTIONARY :
				saveC.lines.append("dict/ %s"%("" if typ_data == type_data.ARRAY else key))
				main_parser(saveC,type_data.DEFAULT,data[key])
				saveC.lines.append("/dict")
			TYPE_ARRAY: 
				saveC.lines.append("array/ %s"%("" if typ_data == type_data.ARRAY else key))
				main_parser(saveC,type_data.ARRAY,data[key])
				saveC.lines.append("/array")
			TYPE_INT:saveC.lines.append(format_main("int",key,str(data[key]),typ_data))
			TYPE_FLOAT:saveC.lines.append(format_main("float",key,str(data[key]),typ_data))
			TYPE_BOOL:saveC.lines.append(format_main("bool",key,str(data[key]),typ_data))
			TYPE_STRING:
				var text : String = data[key]
				if text.contains("\n") or text.contains("\r"):
					text = text.replace("\r\n", "\n").replace("\r","\n")
					saveC.lines.append_array(format_multiline(key, text, typ_data)) 
				else: 
					if text != text.strip_edges() or (text.length() >= 2 and text.begins_with("\"") and text.ends_with("\"")):
						text = "\"" + text + "\""
					saveC.lines.append(format_main("str",key,text,typ_data))
			TYPE_VECTOR2:
				var vec2 = str(data[key])
				vec2 = vec2.trim_prefix("(").trim_suffix(")").strip_edges()
				saveC.lines.append(format_main("vec2",key,str(vec2),typ_data))
			TYPE_VECTOR3:
				var vec3 = str(data[key])
				vec3 = vec3.trim_prefix("(").trim_suffix(")").strip_edges()
				saveC.lines.append(format_main("vec3",key,str(vec3),typ_data))
			TYPE_COLOR:
				var colr = str(data[key])
				colr = colr.trim_prefix("(").trim_suffix(")").strip_edges()
				saveC.lines.append(format_main("color",key,str(colr),typ_data))
			_: 
				saveC.warn.append(new_err("S02",saveC.path,saveC.line_index))
				saveC.lines.append(format_main("var",key,str(data[key]),typ_data))
			_: 
				saveC.warn.append(new_err("S02",saveC.path,saveC.line_index))
				saveC.lines.append(format_main("var",key,str(data[key]),typ_data))

static func format_main(prefix: String, name, value: String, typ_data: type_data, suffix: String = ""):
	if typ_data == type_data.ARRAY:
		return "%s %s" % [prefix, value] if suffix == "" else "%s %s %s" % [prefix, value, suffix]
	else: return "%s %s : %s" % [prefix, name, value] if suffix == "" else "%s %s : %s %s" % [prefix, name, value, suffix]

static func format_multiline(name, value: String, typ_data : type_data):
	var out : Array = ["str/" if typ_data == type_data.ARRAY else "str/ %s :" % name]
	out.append_array(Array(value.split("\n")))
	out.append("/str")
	return out
