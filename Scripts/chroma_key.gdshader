shader_type canvas_item;

uniform vec4 key_color : source_color = vec4(1.0, 1.0, 1.0, 1.0);
uniform float tolerance : hint_range(0.0, 1.0) = 0.1;

void fragment() {
	vec4 tex_color = texture(TEXTURE, UV);
	if (distance(tex_color.rgb, key_color.rgb) < tolerance) {
		discard;
	}
	COLOR = tex_color;
}
