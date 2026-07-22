shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest;
uniform sampler2D ice_noise : hint_default_white;
uniform sampler2D frost_texture : hint_default_white;
uniform float distortion_strength : hint_range(0.0, 0.1) = 0.02;
uniform float freeze_amount : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    // 1. Distortion
    vec4 screen_color = textureLod(screen_texture, SCREEN_UV, 0.0);
    COLOR = screen_color; 
	
    vec2 noise_val = texture(ice_noise, UV).rg;
    vec2 distortion = (noise_val * 2.0 - 1.0) * distortion_strength * freeze_amount;
    
    // 2. Sample screen behind the effect
	vec2 screen_uv = clamp(
	    SCREEN_UV + distortion,
	    vec2(0.0),
	    vec2(1.0)
	);

	vec3 col = textureLod(screen_texture, screen_uv, 0.0).rgb;
    
    // 3. Frost / ice overlays
    vec4 frost_col = texture(frost_texture, UV);
    vec3 ice_color = vec3(0.6, 0.85, 1.0);
    
    // Mix screen with ice based on freeze_amount
    vec3 final_color = mix(col, ice_color, frost_col.r * freeze_amount);
    
    COLOR = vec4(final_color, 1.0);
}