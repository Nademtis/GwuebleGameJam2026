shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, filter_linear_mipmap;
uniform sampler2D ice_noise : hint_default_white;
uniform sampler2D frost_texture : hint_default_white;
uniform float distortion_strength : hint_range(0.0, 0.1) = 0.02;
uniform float freeze_amount : hint_range(0.0, 1.0) = 0.5;

void fragment() {
    // 1. Distortion
    vec2 noise_val = texture(ice_noise, UV).rg;
    vec2 distortion = (noise_val * 2.0 - 1.0) * distortion_strength * freeze_amount;
    
    // 2. Sample screen behind the effect
    vec3 col = texture(screen_texture, SCREEN_UV + distortion).rgb;
    
    // 3. Frost / ice overlays
    vec4 frost_col = texture(frost_texture, UV);
    vec3 ice_color = vec3(0.6, 0.85, 1.0);
    
    // Mix screen with ice based on freeze_amount
    vec3 final_color = mix(col, ice_color, frost_col.r * freeze_amount);
    
    COLOR = vec4(final_color, 1.0);
}