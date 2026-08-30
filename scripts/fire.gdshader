shader_type canvas_item;
render_mode unshaded;

// Screen resolution in pixels, e.g. vec2(320.0, 180.0).
uniform vec2 screen_size = vec2(320.0, 180.0);

// Three-colour palette.
uniform vec4 light_colour : source_color = vec4(0.83, 0.89, 0.83, 1.0);
uniform vec4 mid_colour   : source_color = vec4(0.49, 0.52, 0.47, 1.0);
uniform vec4 dark_colour  : source_color = vec4(0.09, 0.11, 0.10, 1.0);

// 0 = nothing, 1 = almost entire screen covered.
uniform float intensity : hint_range(0.0, 3.0) = 0.0;

// Both textures should be seamless/repeating NoiseTexture2Ds.
uniform sampler2D noise_large : repeat_enable;
uniform sampler2D noise_small : repeat_enable;


// ------------------------------------------------------------
// Helpers
// ------------------------------------------------------------

// Sample noise in approximately square screen-space coordinates, so that
// changing the aspect ratio doesn't stretch the fire horizontally.
float noise_screen(sampler2D tex, vec2 uv, vec2 movement) {
	vec2 p = uv * screen_size / min(screen_size.x, screen_size.y);
	return texture(tex, p + movement).r;
}

float get_base_heat(vec2 uv) {
	float sq_dist = 4.0 * (uv.x - 0.5) * (uv.x - 0.5) + uv.y * uv.y;
	float base = clamp(intensity / 9.0 +  sq_dist / 10.0 - 0.15, 0.0, 1.0);
	float agg = clamp(sq_dist + intensity - 0.9, 0.0, 1.0) / 4.0;
	return base + agg;
}


// ------------------------------------------------------------
// Main
// ------------------------------------------------------------

void fragment() {
	float t = TIME;

	float broad = noise_screen(noise_large,	UV,	vec2(0.05 * t, 0.10 * t));
	float detail = noise_screen(noise_small, UV, vec2(-0.08 * t, 0.24 * t));

	float heat = get_base_heat(UV) + broad * 0.28 + detail * 0.17;

	vec4 fire_colour;

	if (heat > 0.5) {
		COLOR = light_colour;
	} else if (heat > 0.39) {
		COLOR = mid_colour;
	} else {
		COLOR = vec4(0, 0, 0, 0);
	}
}