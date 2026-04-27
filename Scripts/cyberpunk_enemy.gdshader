shader_type canvas_item;

uniform vec4 dark_tint : source_color = vec4(0.4, 0.25, 0.25, 1.0);
uniform vec4 glow_color : source_color = vec4(3.0, 0.2, 0.1, 1.0);
uniform float light_threshold : hint_range(0.0, 1.0) = 0.55;
uniform bool is_aggro = false;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    if (tex_color.a > 0.1) {
        float brightness = max(max(tex_color.r, tex_color.g), tex_color.b);
        
        if (brightness > light_threshold) {
            COLOR = is_aggro ? (glow_color * 1.8) : glow_color;
        } else {
            COLOR.rgb = tex_color.rgb * dark_tint.rgb * 1.5;
            COLOR.a = tex_color.a;
        }
    } else {
        COLOR = tex_color;
    }
}
