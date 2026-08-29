shader_type canvas_item;
render_mode unshaded;

// Screen resolution in pixels, e.g. vec2(320.0, 180.0).
uniform vec2 screen_size = vec2(320.0, 180.0);

// Three-colour palette.
uniform vec4 light_colour : source_color = vec4(0.83, 0.89, 0.83, 1.0);
uniform vec4 mid_colour   : source_color = vec4(0.49, 0.52, 0.47, 1.0);
uniform vec4 dark_colour  : source_color = vec4(0.09, 0.11, 0.10, 1.0);

// 0 = nothing, 1 = almost entire screen covered.
uniform float intensity : hint_range(0.0, 1.0) = 0.0;

// Both textures should be seamless/repeating NoiseTexture2Ds.
uniform sampler2D noise_large : repeat_enable;
uniform sampler2D noise_small : repeat_enable;


// ------------------------------------------------------------
// Helpers
// ------------------------------------------------------------

// Sample noise in approximately square screen-space coordinates, so that
// changing the aspect ratio doesn't stretch the fire horizontally.
float noise_screen(
	sampler2D tex,
	vec2 uv,
	float scale,
	vec2 movement
) {
	vec2 p = uv * screen_size / min(screen_size.x, screen_size.y);
	return texture(tex, p * scale + movement).r;
}


// ------------------------------------------------------------
// Main
// ------------------------------------------------------------

void fragment() {
	vec2 uv = UV;

	// y = 0 at the bottom, y = 1 at the top.
	float y = 1.0 - uv.y;

	// --------------------------------------------------------
	// NOISE
	// --------------------------------------------------------

	// Slow upward drift gives the whole effect some movement.
	float t = TIME;

	float broad = noise_screen(
		noise_large,
		uv,
		1.25,
		vec2(0.05 * t, 0.10 * t)
	);

	float detail = noise_screen(
		noise_small,
		uv,
		3.8,
		vec2(-0.08 * t, 0.24 * t)
	);

	// Distort the broad noise with the fine noise.
	float turbulent = broad + (detail - 0.5) * 0.38;


	// --------------------------------------------------------
	// SMOKE
	//
	// Smoke starts before the actual flames. At first it appears
	// as sparse little dark islands. As intensity rises those
	// islands become progressively larger and join together.
	// --------------------------------------------------------

	float smoke_progress = smoothstep(0.02, 0.72, intensity);

	// Initially only unusually high noise values form smoke.
	// Lowering the threshold makes the patches expand.
	float smoke_threshold = mix(0.83, 0.34, smoke_progress);

	float smoke = smoothstep(
		smoke_threshold,
		smoke_threshold + 0.06,
		turbulent
	);

	// Smoke becomes somewhat more common towards the top.
	float smoke_height_bias = smoothstep(
		0.0,
		1.0,
		y + 0.20 * turbulent
	);

	smoke *= mix(0.45, 1.0, smoke_height_bias);

	// Prevent even rare noise peaks from appearing at exactly zero.
	smoke *= smoothstep(0.0, 0.06, intensity);


	// --------------------------------------------------------
	// FIRE FRONT
	//
	// Flames don't really get going until intensity is already
	// somewhat above zero. The front then rises from the bottom.
	// --------------------------------------------------------

	float fire_progress = smoothstep(0.14, 1.0, intensity);

	// At intensity=1 this deliberately passes slightly beyond
	// the top, so almost the whole screen can burn.
	float fire_height = fire_progress * 1.12;

	// Noise modifies the height of the flame front.
	float flame_shape =
		y
		- fire_height
		+ (turbulent - 0.5) * 0.42
		+ (detail - 0.5) * 0.12;

	float fire = 1.0 - smoothstep(-0.04, 0.05, flame_shape);
	fire *= smoothstep(0.10, 0.18, intensity);


	// --------------------------------------------------------
	// FIRE COLOUR
	//
	// Quantise the flame into light / mid / dark only.
	// Lightest towards the hottest, lowest regions.
	// --------------------------------------------------------

	float heat =
		(1.0 - y) * 0.55
		+ broad * 0.28
		+ detail * 0.17;

	vec4 fire_colour;

	if (heat > 0.60) {
		fire_colour = light_colour;
	} else if (heat > 0.39) {
		fire_colour = mid_colour;
	} else {
		fire_colour = dark_colour;
	}


	// --------------------------------------------------------
	// COMPOSITE
	//
	// Priority:
	//   fire > smoke > transparent
	// --------------------------------------------------------

	vec4 result = vec4(0.0);

	if (smoke > 0.5) {
		result = dark_colour;
	}

	if (fire > 0.5) {
		result = fire_colour;
	}

	// Make intensity=0 rigorously transparent.
	result.a *= step(0.0001, intensity);

	COLOR = result;
}