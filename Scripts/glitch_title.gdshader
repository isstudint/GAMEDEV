shader_type canvas_item;

// Corruption shader for the "Present" title state.
// Heavy block glitch, RGB split, scanlines, and jitter.

uniform float intensity : hint_range(0.0, 1.0) = 0.6;

float rand(vec2 co) {
	return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
	vec2 uv = UV;
	float time = TIME;

	// --- Heavy block displacement ---
	float block_y = floor(uv.y * 10.0) / 10.0;
	float block_rand = rand(vec2(floor(time * 12.0), block_y));
	float shift = 0.0;

	// Only some blocks glitch (makes it feel more broken)
	if (block_rand > 0.6) {
		shift = (block_rand - 0.5) * intensity * 0.2;
	}
	uv.x += shift;

	// --- Strong RGB split ---
	float split = intensity * 0.015;
	float r = texture(TEXTURE, uv + vec2(split, split * 0.3)).r;
	float g = texture(TEXTURE, uv).g;
	float b = texture(TEXTURE, uv - vec2(split, -split * 0.2)).b;
	float a = texture(TEXTURE, uv).a;

	// --- Scanlines ---
	float scanline = sin(FRAGCOORD.y * 3.0) * 0.5 + 0.5;
	float scan_flicker = step(0.97, rand(vec2(floor(time * 20.0), 0.0)));

	vec4 color = vec4(r, g, b, a);
	color.rgb -= scanline * (0.12 + scan_flicker * 0.2);

	// --- Random brightness jitter ---
	float brightness = 1.0 + (rand(vec2(time * 8.0, 1.0)) - 0.5) * 0.15;
	color.rgb *= brightness;

	COLOR = color;
}
