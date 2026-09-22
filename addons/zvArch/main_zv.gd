@tool
extends EditorPlugin

const namePlugin : String  = "zvArch"
const version : float = 0.1

const PRINT_DICT : Dictionary = {
	"PRT01" : "[b]- The plugin ´zvArch` has been activated -> [url=%s][/url] -[/b]",
	"PRT02" : "- bye.zv -" 
}     
const ERROR_DICT : Dictionary = {
	##Default
	"C01" : "ERROR_C01 | Route misspelled or not exist ",
	"C02" : "ERROR_C02 | Could not open file (permision/corruption) ",
	"C03" : "ERROR_C03 | Incompatible version ",
	"C04" : "ERROR_C04 | Version line missing or malformed ",
	##Load
	"L01" : "ERROR_LD01 | Misign `:` or value ",
	"L02" : "ERROR_LD02 | Invalid / maformed value (generic) ",
	"L03" : "ERROR_LD03 | Invalid INT ",
	"L04" : "ERROR_LD04 | Invalid FLOAT ",
	"L05" : "ERROR_LD05 | Invalid BOOL ",
	"L06" : "ERROR_LD06 | Invalid VEC2 ",
	"L07" : "ERROR_LD07 | Invalid VEC3 ",
	"L08" : "ERROR_LD08 | Invalid COLOR ",
	"L09" : "ERROR_LD09 | Unclosed multiline string block ",
	"L10" : "ERROR_LD10 | Orphaned closing tag or mismatch with opening tag ",
	"L11" : "ERROR_LD11 | dict/array/ sin cerrar al final del archivo ",
	"L12" : "ERROR_LD12 | Unrecognized tag/type ",
	##Save
	"S01" : "ERROR_SV01 | Could no create/write file ",
	"S02" : "ERROR_SV02 | Unsupported data type - value converted to a string ",
	"S03" : "ERROR_SV03 | Dictionary key is not String"
}

#Plugin functions 
func _enable_plugin() -> void:
	print_rich(PRINT_DICT["PRT01"])
func _disable_plugin() -> void:
	print(PRINT_DICT["PRT02"])
func _enter_tree() -> void:
	pass
func _exit_tree() -> void:
	pass
