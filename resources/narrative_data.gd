class_name NarrativeData
extends Resource

const DATA_PATH := "res://assets/data/presentations.json"

@export var id: String = ""
@export var palette: PaletteData.Palette = PaletteData.Palette.FIRE
@export var actions: Array[Dictionary] = []


## Reads every narrative from the shared JSON file and returns them keyed by ID.
## Keeping this here means users of NarrativeData never need to know its storage
## format or where the source file lives.
static func load_all() -> Dictionary[String, NarrativeData]:
	var result: Dictionary[String, NarrativeData] = {}
	var file: FileAccess = FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		push_error("Could not open narrative data at %s." % DATA_PATH)
		return result

	var parsed_data: Variant = JSON.parse_string(file.get_as_text())
	if not parsed_data is Dictionary:
		push_error("Narrative data must contain a JSON object at its root.")
		return result

	for id_value: Variant in parsed_data:
		var narrative_id: String = str(id_value)
		var raw_data: Variant = parsed_data[id_value]
		if not raw_data is Dictionary:
			push_warning("Ignoring narrative '%s' because its data is not an object." % narrative_id)
			continue

		var data := NarrativeData.new()
		data.id = narrative_id
		data.palette = PaletteData.from_name(str(raw_data.get("palette", "FIRE")))

		var raw_actions: Variant = raw_data.get("actions", [])
		if not raw_actions is Array:
			push_warning("Narrative '%s' has an invalid actions list." % narrative_id)
			continue
		for action: Variant in raw_actions:
			if action is Dictionary:
				data.actions.append(action.duplicate(true))
			else:
				push_warning("Ignoring a non-object action in narrative '%s'." % narrative_id)

		result[narrative_id] = data

	return result
