class_name zvARCH
extends RefCounted

const load_zvArch = preload("res://addons/zvArch/Scripts/load_zv.gd")
const save_zvArch = preload("res://addons/zvArch/Scripts/save_zv.gd")
const metadata_zvArch = preload("res://addons/zvArch/Scripts/metadata_zv.gd")

static func loadzv(path : String):
	var parser = load_zvArch.new()
	return parser.parser_READ(path, false)

static func savezv(path : String, data : Dictionary, metadata : Dictionary = {}):
	var parser = save_zvArch.new()
	return parser.parser_WRITE(path, data, metadata, false)

static func savezv_metadata(path : String, metadata : Dictionary):
	var parser = metadata_zvArch.new()
	return parser.parser_METADATA(true, path, metadata)

static func loadzv_metadata(path : String):
	var parser = metadata_zvArch.new()
	return parser.parser_METADATA(false, path)
