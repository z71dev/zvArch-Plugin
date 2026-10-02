## ZVARCH
***
**zvArch** is a data saving/loading plugin for Godot based on ".zv", a custom file format designed to be simple, easy to read, and easy to integrate.

Contents
- API and usage examples
- Supported data types
- What is a .zv format? Syntax
- Error Handling
- Roadmap
- How to Contribute and Support the Plugin

### API

To access the API, you must log in with the class:
``` zvARCH ```

##### SAVE DATA ("savezv")
```
data = {"health" : 100}
metadata = {"timestamp" : Time.get_unix_time_from_system()}

zvARCH.savezv(path : String, data : Dictionary, metadata : Dictionary = {})
```

- path: must end with ".zv".
- data: Dictionary with the data to be stored.
- metadata (optional): Dictionary with additional data.

##### LOAD DATA ("loadzv")
```
var result = zvARCH.loadzv(path : String)

var playerData = result.data
var saveData = result.metadata

health = playerData["health"] #100
timestamp = saveData["timestamp"] #1727520312
```

- path: path to the ".zv" file.
- Return: Returns an instance with the loaded information:
	- To access the dictionary with the saved data, use the ```.data``` property.
	- To access the dictionary with the saved metadata, use the ```.metadata``` property.

----
**Metadata:** Metadata-only functions are much more efficient because they do not load or transform data other than metadata.

##### SAVE METADATA ("savezv_metadata")
```
zvARCH.savezv_metadata(path: String, metadata: Dictionary)
```

- path: must end in ".zv".
- metadata: Dictionary with the metadata to be stored.
- **Note:** Saving replaces existing metadata.

##### LOAD METADATA ("loadzv_metadata")
```
var result = zvARCH.loadzv_metadata(path: String)

var saveData = result.metadata

timestamp = saveData["timestamp"] #1727520312
```

- path: path to the ".zv" file.
- Return: Returns an instance with the loaded information:
	- To access the dictionary with the saved metadata, use the `.metadata` property.

## Accepted Data Types
**DATA**
```INT, FLOAT, BOOL, STRING, VECTOR2, VECTOR3, COLOR```

**STRUCTURES** (Allows unlimited nested structures)
``` DICTIONARY, ARRAY```

**UNKNOWN DATA**
Unknown data is stored as ``` STRING ```, and within the ".zv" format, it is stored as ``` VAR ```. This is done so that it can be manually decomposed. Caution is advised if you attempt to use the data even while it is still ``` STRING ```.

## ".zv" Format
This is a text file designed for Godot to store the information you need. The plugin creates, modifies, and reads it, so you don't usually have to touch it, but you can open it with any text editor and understand it at a glance (perfect for mods or community contributions).

##### SYNTAX
Data types in ".zv":

| **Godot**  | **.zv** |
| ---------- | ------- |
| int        | int     |
| float      | float   |
| bool       | bool    |
| string     | str     |
| vector2    | vec2    |
| vector3    | vec3    |
| color      | color   |
| dictionary | dict    |
| array      | array   |

**Composition** (Each line is a data type)
```
data type name : data

#Example
int points : 10
```

**VAR** If you don't want to specify the data type, use ``` var ``` and the plugin will infer it for you:
```
var lives : 3
var player name : z71
```

**STR/** If you want to have text organized across multiple lines, you can open a slash right after the ```STR``` type:
```
str/ description :
This is a very long text.
It can have quotation marks and apostrophes without any problem.
And occupy as many lines as you want.
/str
```
(**IMPORTANT:** It must be closed with ``` /str ```).

**DATA STRUCTURES** To group data, open the structure with its type followed by / (":" is not necessary):
```
dict/ options
int volume : 80
bool full_screen : false
/dict

# They can be nested
dict/ player
str name : z71
array/ items
str sword
/array
/dict
```
(**IMPORTANT:** It must be closed with a "/", followed by the type: ``` /dict ```).

### Errors
Errors are sent in two ways: they are printed to the output and returned in each API.
To access errors in the APIs, simply use ```.errors``` and it will return an array containing them.

```
var result = zvARCH.loadzv(path : String)

var errorsArray = result.errors # Array []
```

**Error List**
```
##Default
ERROR_C01 | Route misspelled or not exists
ERROR_C02 | Could not open file (permission/corruption)
ERROR_C03 | Incompatible version
ERROR_C04 | Version line missing or malformed
ERROR_C05 | The file does not end in `.zv`
##Load
ERROR_LD01 | Missign `:` or value
ERROR_LD02 | Invalid/maformed value (generic)
ERROR_LD03 | Invalid INT
ERROR_LD04 | Invalid FLOAT
ERROR_LD05 | Invalid BOOL
ERROR_LD06 | Invalid VEC2
ERROR_LD07 | Invalid VEC3
ERROR_LD08 | Invalid COLOR
ERROR_LD09 | Unclosed multiline string block
ERROR_LD10 | Orphaned closing tag or mismatch with opening tag
ERROR_LD11 | dict/array/ without closing at the end of the file
ERROR_LD12 | Unrecognized tag/type
##Save
ERROR_SV01 | Could not create/write file
ERROR_SV02 | Unsupported data type - value converted to a string
ERROR_SV03 | Dictionary key is not String
##Metadata
ERROR_MTDT01 | Metadata has not been properly closed
```

Default errors are common, and the others are generally generated by manual editing.

### RoadMap
**In no particular order**
- More data types:
	- VECTOR4, RECT2, QUATERNION, TRANSFORM2D, TRANSFORM3D, PACKED* ARRAY.
- Temporary file system (To prevent corruption)
- Temporary save system: (Deleted when the game is closed.)
- Steam cloud save compatibility.
- Encryption:
	- Basic: Godot native encryption, SHA-256 checksum
	- Advanced: Proprietary AES encryption, HMAC signature, User-derived key.
- Save to media file.
- Native mod system.
- Native save slot and multi-save system.
- API for updating previous versions (only if the syntax changes).

### Contribute and Support
If you like the plugin and want to support it, you can do so in the following ways:
- Contribute on GitHub: Bugs, ideas, or improvements.
https://github.com/z71dev/zvArch-Plugin.git
- Buy me a coffee on Ko-fi: It's optional, but greatly appreciated.
https://ko-fi.com/z71_official
- Share: Talking about the plugin with others who might find it useful is also a great help.
https://store.godotengine.org/asset/z71/save-system-zvarch/

> [!NOTE] THANK YOU
> This is a completely personal project, made with eart,and is constantly being updated.
> (Everything was translated using Google Translate)
