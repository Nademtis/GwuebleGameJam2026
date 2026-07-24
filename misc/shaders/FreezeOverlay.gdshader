shader_type canvas_item;
//freeze overlay shader - maybe works idk

uniform sampler2D screen_texture : hint_screen_texture, filter_linear;

// 0 = normal, 1 = grayscale
uniform float desaturation : hint_range(0.0, 1.0) = 0.0; 

// 0 = normal, 1 = completely black
uniform float darkness : hint_range(0.0, 1.0) = 0.0;

void fragment() {
	vec3 col = textureLod(screen_texture, SCREEN_UV, 0.0).rgb;

	// desaturate
	float gray = dot(col, vec3(0.299, 0.587, 0.114));
	col = mix(col, vec3(gray), desaturation);

	// darken
	col *= 1.0 - darkness;

	COLOR = vec4(col, 1.0);
}