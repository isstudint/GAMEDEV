shader_type canvas_item;

uniform float squishedness : hint_range(0.0, 1.0) = 0.2;

void fragment() {
	// If we are in the top or bottom "squished" area, render black. Otherwise render fully transparent.
	if (UV.y < squishedness * 0.5 || UV.y > 1.0 - (squishedness * 0.5)) {
		COLOR = vec4(0.0, 0.0, 0.0, 1.0);
	} else {
		COLOR = vec4(0.0, 0.0, 0.0, 0.0);
	}
}