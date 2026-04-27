shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(4.0, 0.2, 0.1, 1.0);
uniform float speed = 10.0;

void fragment() {
    vec4 tex_color = texture(TEXTURE, UV);
    if (tex_color.a > 0.1) {
        float pulse = (sin(TIME * speed) + 1.0) * 0.5;
        COLOR = glow_color * (1.0 + pulse * 0.5);
        COLOR.a = tex_color.a;
    } else {
        COLOR = tex_color;
    }
}
