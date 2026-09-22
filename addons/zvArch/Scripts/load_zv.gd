extends RefCounted

const main_script = preload("res://addons/zvArch/main_zv.gd")

class loadContent:
	var path : String 
	var if_version : bool = false
	var line_index : int = 0
	var lines : Array
	var err : Array = []
	var closed_data : int = 0

	func _init(temp_pth : String, temp_lns : Array) -> void:
		path = temp_pth
		lines = temp_lns
class resultContent:
	var data : Dictionary = {}
	var errors: Array = []
	
	func _init(temp_err : Array, temp_data : Dictionary = {}) -> void:
		data = temp_data
		errors = temp_err

enum type_data {DEFAULT, ARRAY, ENUM}
enum type_format {VAR, INT, FLOAT, BOOL, STRING, VECT2, VECT3, COLOR}

static func new_err(num_err : String, path : String, line : int = 0):
	var err_dict = main_script.ERROR_DICT
	var err = err_dict[num_err]
	if line == 0:
		printerr(str(err+" | Path: ", path))
		return str(err+" | Path: ", path)
	else: 
		printerr(str(err," | Line: ", line ," | Path: ", path))
		return str(err," | Line: ", line ," | Path: ", path)

static func parser_READ(new_path: String, new_name: String):
	var zvDict : Dictionary = {}
	var temp_path = new_path+new_name+".zv"
	
	if not FileAccess.file_exists(temp_path):
		var new_result = resultContent.new([new_err("C01",temp_path)],{})
		return new_result
	var file = FileAccess.open(temp_path,FileAccess.READ)
	if not file:
		var new_result = resultContent.new([new_err("C02",temp_path)],{})
		return new_result
	var text = file.get_as_text().split("\n")
	file.close()
	var new_load = loadContent.new(temp_path,text)
	var data = main_parser(new_load, type_data.DEFAULT)
	if new_load.closed_data != 0:
		new_load.err.append(new_err("L11",new_load.path,new_load.line_index))
	var new_result = resultContent.new(new_load.err,data)
	return new_result

static func main_parser(loadC: loadContent, typ_data: type_data):
	var temp_dict : Dictionary = {}
	var temp_array : Array = []
	while loadC.line_index < loadC.lines.size():
		var line = loadC.lines[loadC.line_index].strip_edges()
		loadC.line_index += 1

		if line == "" or line.begins_with("#"):
			continue
		if not loadC.if_version:
			if line.begins_with("version "):
				var content = line.trim_prefix("version").strip_edges()
				var parts = content.split(":")
				if not parts.size() == 2:
					loadC.err.append(new_err("C04",loadC.path))
					break
				var part1 = parts[0].strip_edges()
				var part2 = parts[1].strip_edges()
				if not part2.is_valid_float():
					loadC.err.append(new_err("C04",loadC.path))
					break
				part2 = part2.to_float()
				if not part2 == main_script.version:
					loadC.err.append(new_err("C03",loadC.path))
					break
				loadC.if_version = true
				continue
			else:
				loadC.err.append(new_err("C04",loadC.path))
				break

		match line.strip_edges().get_slice(" ",0): #Estructuras de datos
			"dict/":
				var content = line.trim_prefix("dict/").strip_edges()
				if content == "" and not typ_data == type_data.ARRAY:
					loadC.err.append(new_err("L01",loadC.path, loadC.line_index))
					continue
				loadC.closed_data += 1
				var resultMain = main_parser(loadC,type_data.DEFAULT)
				if typ_data == type_data.ARRAY: temp_array.append(resultMain)
				else: temp_dict[content] = resultMain
				continue
			"/dict" :
				if loadC.closed_data <= 0:
					loadC.err.append(new_err("L10",loadC.path, loadC.line_index))
					continue
				if not typ_data == type_data.DEFAULT:
					loadC.err.append(new_err("L10",loadC.path, loadC.line_index))
					continue
				loadC.closed_data -= 1
				return temp_dict
			"array/":
				var content = line.trim_prefix("array/").strip_edges()
				if content == "" and not typ_data == type_data.ARRAY:
					loadC.err.append(new_err("L01",loadC.path, loadC.line_index))
					continue
				loadC.closed_data += 1
				var resultMain = main_parser(loadC,type_data.ARRAY)
				if typ_data == type_data.ARRAY: temp_array.append(resultMain)
				else: temp_dict[content] = resultMain
				continue
			"/array" :
				if loadC.closed_data <= 0:
					loadC.err.append(new_err("L10",loadC.path, loadC.line_index))
					continue
				if not typ_data == type_data.ARRAY:
					loadC.err.append(new_err("L10",loadC.path, loadC.line_index))
					continue
				loadC.closed_data -= 1
				return temp_array
		match line.strip_edges().get_slice(" ",0): #Normal and Open
			"var":
				var content = line.trim_prefix("var").strip_edges()
				if not split_main(loadC,typ_data,type_format.VAR,temp_dict,temp_array,content):
					continue
			"int": 
				var content = line.trim_prefix("int").strip_edges()
				if not split_main(loadC,typ_data,type_format.INT,temp_dict,temp_array,content):
					continue 
			"float": 
				var content = line.trim_prefix("float").strip_edges()
				if not split_main(loadC,typ_data,type_format.FLOAT,temp_dict,temp_array,content):
					continue 
			"bool":
				var content = line.trim_prefix("bool").strip_edges()
				if not split_main(loadC,typ_data,type_format.BOOL,temp_dict,temp_array,content):
					continue 
			"str", "str/": 
				var content = str_main(loadC,"str","/str",line)
				if not content:
					content = line.trim_prefix("str").strip_edges()
				if not split_main(loadC,typ_data,type_format.STRING,temp_dict,temp_array,content):
					continue 
			"vec2":
				var content = line.trim_prefix("vec2").strip_edges()
				if not split_main(loadC,typ_data,type_format.VECT2,temp_dict,temp_array,content):
					continue 
			"vec3":
				var content = line.trim_prefix("vec3").strip_edges()
				if not split_main(loadC,typ_data,type_format.VECT3,temp_dict,temp_array,content):
					continue 
			"color":
				var content = line.trim_prefix("color").strip_edges()
				if not split_main(loadC,typ_data,type_format.COLOR,temp_dict,temp_array,content):
					continue 
			_:
				loadC.err.append(new_err("L12",loadC.path,loadC.line_index))
	return temp_dict

static func split_main(loadC:loadContent,typ_data: type_data, typ_format : type_format, temp_dict : Dictionary, temp_array : Array, content: String):
	var parts = content.split(":", true, 1)
	var resultFormat
	if  parts.size() != 2 and parts.size() != 1:
		loadC.err.append(new_err("L01",loadC.path, loadC.line_index))
		return false
	if parts.size() == 2: resultFormat = format_split(loadC,typ_format, parts[1])
	elif parts.size() == 1 and typ_data == type_data.ARRAY:resultFormat = format_split(loadC,typ_format, parts[0])
	if resultFormat == null:
		loadC.err.append(new_err("L02",loadC.path, loadC.line_index))
		return false
	if typ_data == type_data.ARRAY:
		temp_array.append(resultFormat)
		return true 
	else:
		var title = parts[0].strip_edges()
		temp_dict[title] = resultFormat
		return true 
static func format_split(loadC:loadContent, typ_format: type_format, content):
	content = content.strip_edges()
	match typ_format:
		type_format.VAR:
			var result_format = var_format(content)
			return format_split(loadC,result_format, content)
		type_format.INT:
			if identify_format(type_format.INT, content):return content.to_int()
			else:
				loadC.err.append(new_err("L03",loadC.path))
				return 
		type_format.FLOAT:
			if identify_format(type_format.FLOAT, content):return content.to_float()
			else:
				loadC.err.append(new_err("L04",loadC.path))
				return 
		type_format.BOOL:
			if identify_format(type_format.BOOL, content):
				if content == "true" or content == "1": return true
				else:return false
			else:
				loadC.err.append(new_err("L05",loadC.path))
				return 
		type_format.STRING: 
			if identify_format(type_format.STRING, content):
				return content.substr(1, content.length() - 2)
			else: return content
		type_format.VECT2:
			if identify_format(type_format.VECT2, content):
				var parts = content.split(",")
				for i in parts.size():
					parts[i] = parts[i].strip_edges()
				var vec0 = parts[0]
				var vec1 = parts[1]
				vec0 = vec0.to_float()
				vec1 = vec1.to_float()
				var vec2 : Vector2 = Vector2(vec0,vec1)
				return vec2
			else: 
				loadC.err.append(new_err("L06",loadC.path))
				return 
		type_format.VECT3:
			if identify_format(type_format.VECT3, content):
				var parts = content.split(",")
				for i in parts.size():
					parts[i] = parts[i].strip_edges()
				var vec0 = parts[0]
				var vec1 = parts[1]
				var vec2 = parts[2]
				vec0 = vec0.to_float()
				vec1 = vec1.to_float()
				vec2 = vec2.to_float()
				var vec3 : Vector3 = Vector3(vec0,vec1,vec2)
				return vec3
			else:
				loadC.err.append(new_err("L07",loadC.path))
				return 
		type_format.COLOR:
			if identify_format(type_format.COLOR,content):
				var parts = content.split(",")
				if parts.size() == 1 and parts[0].begins_with("#"):return Color.html(parts[0])
				else:
					for i in parts.size():
						parts[i] = parts[i].strip_edges()
					var col0 = parts[0]
					var col1 = parts[1]
					var col2 = parts[2]
					var col3 = parts[3]
					col0 = col0.to_float()
					col1 = col1.to_float()
					col2 = col2.to_float()
					col3 = col3.to_float()
					var color : Color = Color(col0,col1,col2,col3)
					return color
			else: 
				loadC.err.append(new_err("L08",loadC.path))
				return

static func str_main(loadC: loadContent, prefix: String, suffix: String, line: String,):
	var type_str = line.strip_edges().get_slice(" ",0)
	if type_str.length() <= prefix.length() or type_str[prefix.length()] != "/":return
	var new_prefix = prefix+"/"
	var content : Array = [line.trim_prefix(new_prefix).strip_edges()]
	var close_str : int = 0
	while loadC.line_index < loadC.lines.size():
		var next_line = loadC.lines[loadC.line_index].strip_edges()
		loadC.line_index += 1
		if next_line.begins_with(new_prefix):
			close_str += 1
		if next_line.begins_with(suffix) and close_str == 0:
			return "\n".join(content)
		elif next_line == suffix:
			close_str -= 1
		content.append(next_line)
	loadC.err.append(new_err("L09",loadC.path, loadC.line_index))
	return

static func var_format(content:String):
	content = content.strip_edges()
	if identify_format(type_format.VAR, content):
		return type_format.STRING
	elif identify_format(type_format.INT,content):
		return type_format.INT
	elif identify_format(type_format.FLOAT,content):
		return type_format.FLOAT
	elif identify_format(type_format.BOOL,content):
		return type_format.BOOL
	elif identify_format(type_format.VECT2,content):
		return type_format.VECT2
	elif identify_format(type_format.VECT3,content):
		return type_format.VECT3
	elif identify_format(type_format.COLOR,content):
		return type_format.COLOR
	else:
		return type_format.STRING

static func identify_format(typ_format:type_format, content:String):
	content = content.strip_edges()
	match typ_format:
		type_format.STRING:
			if content.begins_with("\"") and content.ends_with("\"") and content.length() >= 2:
				return true
			else: return false
		type_format.INT:
			if content.is_valid_int():return true 
			else: return false
		type_format.FLOAT:
			if content.is_valid_float():return true 
			else: return false
		type_format.BOOL:
			content = content.to_lower()
			if content == "true" or content == "1" or content == "false" or content == "0": return true 
			else: return false 
		type_format.VECT2:
			var parts = content.split(",")
			if parts.size() != 2:return false
			for i in parts.size():
				parts[i] = parts[i].strip_edges()
			if not parts[0].is_valid_float() or not parts[1].is_valid_float():return false
			return true
		type_format.VECT3:
			var parts = content.split(",")
			if parts.size() != 3 :return false
			for i in parts.size():
				parts[i] = parts[i].strip_edges()
			if not parts[0].is_valid_float() or not parts[1].is_valid_float() or not parts[2].is_valid_float():return false
			return true
		type_format.COLOR:
			var parts = content.split(",")
			if parts.size() == 1 and parts[0].begins_with("#") :
				if not Color.html_is_valid(parts[0]):return false
				return true
			elif parts.size() == 4:
				for i in parts.size():
					parts[i] = parts[i].strip_edges()
				if not parts[0].is_valid_float() or not parts[1].is_valid_float() or not parts[2].is_valid_float() or not parts[3].is_valid_float():
					return false
				else:return true
			else:return false 
