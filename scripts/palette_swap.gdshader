shader_type canvas_item;
render_mode unshaded;

// The palette used by the source images.
uniform vec4 source_light : source_color = vec4(1.0, 0.92549, 0.81569, 1.0);
uniform vec4 source_medium : source_color = vec4(0.88627, 0.29804, 0.21569, 1.0);
uniform vec4 source_dark : source_color = vec4(0.43922, 0.05882, 0.08627, 1.0);

// The palette the source image should be drawn with.
uniform vec4 target_light : source_color = vec4(1.0, 0.92549, 0.81569, 1.0);
uniform vec4 target_medium : source_color = vec4(0.88627, 0.29804, 0.21569, 1.0);
uniform vec4 target_dark : source_color = vec4(0.43922, 0.05882, 0.08627, 1.0);


void fragment() {
	vec4 source = texture(TEXTURE, UV);

	float light_distance = distance(source.rgb, source_light.rgb);
	float medium_distance = distance(source.rgb, source_medium.rgb);
	float dark_distance = distance(source.rgb, source_dark.rgb);

	vec4 target;
	if (light_distance < medium_distance && light_distance < dark_distance) {
		target = target_light;
	} else if (medium_distance < dark_distance) {
		target = target_medium;
	} else {
		target = target_dark;
	}

	COLOR = vec4(target.rgb, target.a * source.a);
}
