shader_type canvas_item;

uniform vec4 armor_tint : source_color = vec4(1.5, 1.5, 1.8, 1.0);
uniform vec4 glow_color : source_color = vec4(0.2, 0.8, 3.0, 1.0);
uniform float light_threshold : hint_range(0.0, 1.0) = 0.55;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    if (tex_color.a > 0.1) {
        float brightness = max(max(tex_color.r, tex_color.g), tex_color.b);
        
        if (brightness > light_threshold) {
            COLOR = glow_color;
        } else {
            COLOR.rgb = tex_color.rgb * armor_tint.rgb;
            COLOR.a = tex_color.a;
        }
    } else {
        COLOR = tex_color;
    }
}
