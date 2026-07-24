shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;

uniform float circle_radius : hint_range(0.0, 1.0) = 1.2;
uniform float softness : hint_range(0.0, 0.5) = 0.1;

uniform vec2 circle_center = vec2(0.5, 0.5);

uniform vec3 outside_color = vec3(0.0, 0.05, 0.1);

void fragment() {
	vec2 uv = SCREEN_UV;

	vec3 col = texture(
		screen_texture,
		uv
	).rgb;


	float dist = distance(
		uv,
		circle_center
	);


	float mask = smoothstep(
		circle_radius - softness,
		circle_radius,
		dist
	);


	col = mix(
		col,
		outside_color,
		mask
	);


	COLOR = vec4(col, 1.0);
}