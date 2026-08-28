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
			return Color("fce4a8")
		Palette.ASH:
			return Color("e5e1da")
		Palette.GREEN:
			return Color("d5e8bd")
	return Color.WHITE


static func get_medium(palette: Palette) -> Color:
	match palette:
		Palette.FIRE:
			return Color("df7857")
		Palette.ASH:
			return Color("85817d")
		Palette.GREEN:
			return Color("668f5b")
	return Color.GRAY


static func get_dark(palette: Palette) -> Color:
	match palette:
		Palette.FIRE:
			return Color("3f2029")
		Palette.ASH:
			return Color("29282d")
		Palette.GREEN:
			return Color("203c32")
	return Color.BLACK


static func from_name(palette_name: String) -> Palette:
	var normalised_name: String = palette_name.to_upper()
	if Palette.has(normalised_name):
		return Palette[normalised_name]
	push_warning("Unknown palette '%s'; using FIRE." % palette_name)
	return Palette.FIRE
