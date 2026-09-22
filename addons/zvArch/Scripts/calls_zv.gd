class_name zvARCH
extends RefCounted

const load_zvArch = preload("res://addons/zvArch/Scripts/load_zv.gd")
const save_zvArch = preload("res://addons/zvArch/Scripts/save_zv.gd")

static func loadzv(path: String, name : String):
	var parser = load_zvArch.new()
	return parser.parser_READ(path,name)

static func savezv(path: String, name : String, data : Dictionary):
	var parser = save_zvArch.new()
	return parser.parser_WRITE(path, name, data)
