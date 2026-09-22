# zvArch

The ReadMe will be recreated for the next update. (Sorry)

A save/load system for Godot 4 built around a custom file format (`.zv`), designed to be simple, human-readable, and easy to drop into any project.

This is an actively developed personal project — feedback and bug reports are welcome via [Issues](#contributing--reporting-bugs).

☕ If this plugin is useful to you, consider supporting development on [Ko-fi](#) — but only if you want to, no pressure.

---

## Table of Contents

- [Installation](#installation)
- [API Reference](#api-reference)
- [Supported Types](#supported-types)
- [The `.zv` File Format](#the-zv-file-format)
- [Usage Examples](#usage-examples)
- [Troubleshooting](#troubleshooting)
- [Roadmap](#roadmap)
- [Contributing / Reporting Bugs](#contributing--reporting-bugs)
- [License](#license)

---

## Installation

**Option A — Godot Asset Library**
1. In Godot, go to the **AssetLib** tab.
2. Search for `zvArch` (or `Save System: zvArch`).
3. Click **Download**, then **Install**.
4. Enable the plugin under **Project > Project Settings > Plugins**.

**Option B — Manual install**
1. Download or clone this repository.
2. Copy the `addons/zvArch` folder into your project's `addons/` directory.
3. Enable the plugin under **Project > Project Settings > Plugins**.

---

## API Reference

### `zvArch.savezv(path, name, data)`

Saves a dictionary of data to a `.zv` file.

| Parameter | Type | Description |
|---|---|---|
| `path` | `String` | File path to save to (e.g. `"user://save.zv"`) |
| `name` | `String` | Name of the data block being saved (used to identify it when loading) |
| `data` | `Dictionary` | The data to save |

Returns nothing. If the save fails, the error is printed to the console.

### `zvArch.loadzv(path, name)`

Loads a previously saved data block from a `.zv` file.

| Parameter | Type | Description |
|---|---|---|
| `path` | `String` | File path to load from |
| `name` | `String` | Name of the data block to load |

**Returns:** `{ data: Dictionary or null, error: String or null }`

- If loading succeeds, `data` contains your dictionary and `error` is `null`.
- If loading fails, `data` is `null` and `error` contains a description of what went wrong.

---

## Supported Types

| Type | Notes |
|---|---|
| `int` | |
| `float` | |
| `bool` | |
| `str` | Single-line or multi-line (see [file format](#the-zv-file-format)) |
| `Vector2` | |
| `Vector3` | |
| `Color` | |
| `var` | Untyped — value type is auto-inferred on load |
| `dict` / `array` | Nested structures — dictionaries and arrays can contain any of the above, including other nested `dict`/`array` blocks |

> **Unrecognized data:** Any data type not in the list above is saved as `var` inside the `.zv` file. When loaded back, it converts to `string`.

---

## The `.zv` File Format

Each line declares a typed value:

```
type name : value
```

### Multi-line text

For longer strings, open a block with `type/` and close it on its own line with `/type`. Everything between the two lines — including quotes and apostrophes — is taken literally, with no need to escape anything.

```
str/ notes :
Here I can write several lines
with "quotes" and apostrophes 'without any issue'.
/str
```

### Nested structures

`dict` and `array` blocks can contain any typed line, including other nested `dict`/`array` blocks:

```
dict/ inventory
    int gold : 120
    array/ items
        str sword
        str potion
    /array
/dict
```

---

## Usage Examples

### Quick save & load

```gdscript
var progress = {
    "level": 3,
    "health": 85.5,
    "player_name": "Ash",
    "position": Vector2(120, 340),
    "has_key": true
}
# Saves "progress" into save.zv
zvArch.savezv("user://save.zv", "progress", progress)

# Loads the data stored under "progress"
var loaded_progress = zvArch.loadzv("user://save.zv", "progress").data
print("Welcome back, ", loaded_progress.player_name)
```

### Checking for load errors

```gdscript
var result = zvArch.loadzv("user://save.zv", "progress")
if result.data != null:
    # Everything went fine, use the data normally
    var loaded_progress = result.data
    print("Level: ", loaded_progress.level)
else:
    # Something failed while reading or parsing the file
    print("Failed to load save: ", result.error)
```

### Full example `.zv` file

```
int level : 3
float health : 85.5
str player_name : Ash

str/ notes :
Here I can write several lines
with "quotes" and apostrophes 'without any issue'.
/str

dict/ inventory
    int gold : 120
    array/ items
        str sword
        str potion
    /array
/dict
```

---

## Troubleshooting

Most errors happen when a `.zv` file has been **edited by hand**. If `loadzv()` returns `data == null`, check the `error` field first — then look for these common causes:

- **Mismatched type tags** — the type used to open a block (`str/`, `dict/`, `array/`) must match the type used to close it (`/str`, `/dict`, `/array`).
- **Multi-line blocks not closed on their own line** — the closing tag (e.g. `/str`) must be the only thing on its line.
- **Malformed or incomplete type declarations** — every line must start with a recognized type followed by a name and, for single-line values, a `:` and a value.
- **Incorrect nesting** — every `dict/` or `array/` block must be closed before its parent block closes.

If none of the above resolves the issue, please open an [Issue](#contributing--reporting-bugs) with the `.zv` file (or the relevant snippet) attached.

---

## Roadmap

- Multiple save slots
- More types: `Vector4`, `Rect2`, `Transform2D` / `Transform3D`, packed arrays
- Integrated mod system
- Continued improvements to robustness and error handling
- Anti-corruption save safety (write-to-temp-then-merge strategy) — planned, not yet implemented

This list isn't exhaustive — check back here for updates as development continues.

---

## Contributing / Reporting Bugs

This is a personal project in active development. Bug reports, feature suggestions, and pull requests are welcome — please open an Issue on the GitHub repository.

---

## License

MIT