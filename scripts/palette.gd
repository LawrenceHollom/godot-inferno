class_name PaletteData
extends RefCounted

enum Palette {
	FIRE,
	ASH,
	GREEN,
}


static func get_light(palette: Palette) -> Color:
	match palette:
		Palette.FIRE:
			return Color("FFECD0")
		Palette.ASH:
			return Color("d3e4d3")
		Palette.GREEN:
			return Color("eed7ac")
	return Color.WHITE


static func get_medium(palette: Palette) -> Color:
	match palette:
		Palette.FIRE:
			return Color("e24c37")
		Palette.ASH:
			return Color("7e4f58")
		Palette.GREEN:
			return Color("8b9525")
	return Color.GRAY


static func get_dark(palette: Palette) -> Color:
	match palette:
		Palette.FIRE:
			return Color("700F16")
		Palette.ASH:
			return Color("1a1d24")
		Palette.GREEN:
			return Color("2a1f07")
	return Color.BLACK


static func from_name(palette_name: String) -> Palette:
	var normalised_name: String = palette_name.to_upper()
	if Palette.has(normalised_name):
		return Palette[normalised_name]
	push_warning("Unknown palette '%s'; using FIRE." % palette_name)
	return Palette.FIRE
