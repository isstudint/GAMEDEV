shader_type canvas_item;

// ============================================================
// 2D WATERFALL SHADER
// Apply to a Sprite2D or ColorRect. Assign a NoiseTexture2D
// (with "Seamless" ON) to the noise_texture slot in the Inspector.
// ============================================================

// --- WATER COLORS ---
// Main water body color
uniform vec4 water_color : source_color = vec4(0.15, 0.45, 0.85, 0.85);
// Lighter foam/streak color
uniform vec4 foam_color : source_color = vec4(0.7, 0.85, 1.0, 0.95);
// Edge highlight color (where water meets edges)
uniform vec4 edge_color : source_color = vec4(0.5, 0.75, 1.0, 0.6);

// --- NOISE TEXTURE ---
// Assign a NoiseTexture2D here (enable Seamless in its settings!)
uniform sampler2D noise_texture : repeat_enable, filter_linear;

// --- FLOW CONTROL ---
// How fast the water flows down (higher Y = faster fall)
uniform vec2 flow_speed = vec2(0.02, 0.6);
// Second layer scrolls at a different speed for depth
uniform vec2 flow_speed_2 = vec2(-0.03, 0.45);

// --- WAVE DISTORTION ---
// How much the water wobbles side-to-side
uniform float wave_strength : hint_range(0.0, 0.1) = 0.015;
// How many wave ripples across the width
uniform float wave_frequency : hint_range(1.0, 30.0) = 8.0;
// How fast the waves move
uniform float wave_speed : hint_range(0.0, 5.0) = 2.0;

// --- FOAM ---
// Noise values above this become foam streaks (lower = more foam)
uniform float foam_threshold : hint_range(0.0, 1.0) = 0.55;
// How soft/hard the foam edges are
uniform float foam_softness : hint_range(0.0, 0.3) = 0.08;

// --- TRANSPARENCY ---
// Fade out at the top edge (waterfall source)
uniform float top_fade : hint_range(0.0, 0.5) = 0.05;
// Fade out at the bottom edge (splash zone)
uniform float bottom_fade : hint_range(0.0, 0.5) = 0.1;
// Overall transparency
uniform float alpha_multiplier : hint_range(0.0, 1.0) = 0.9;

// --- EDGE GLOW ---
// How thick the bright edges are on left/right sides
uniform float edge_width : hint_range(0.0, 0.3) = 0.08;


void fragment() {
	vec2 uv = UV;

	// === SIDE-TO-SIDE WAVE ===
	// Sine wave makes the water wobble horizontally as it falls
	float wave = sin(uv.y * wave_frequency + TIME * wave_speed) * wave_strength;
	// Stronger wobble toward the bottom (water spreads as it falls)
	wave *= smoothstep(0.0, 1.0, uv.y);
	uv.x += wave;

	// === LAYER 1: Main water flow ===
	// Scroll UVs downward over time to simulate falling water
	vec2 scroll_uv_1 = uv + flow_speed * TIME;
	float noise_1 = texture(noise_texture, scroll_uv_1).r;

	// === LAYER 2: Secondary flow (creates depth) ===
	// Slightly different speed + offset so the two layers don't look identical
	vec2 scroll_uv_2 = uv * 1.3 + flow_speed_2 * TIME + vec2(0.5, 0.0);
	float noise_2 = texture(noise_texture, scroll_uv_2).r;

	// === BLEND THE TWO LAYERS ===
	// Average them for a richer, more complex water pattern
	float combined_noise = (noise_1 * 0.6 + noise_2 * 0.4);

	// === FOAM STREAKS ===
	// Where noise is bright enough, show foam color instead of water color
	float foam_mix = smoothstep(foam_threshold, foam_threshold + foam_softness, combined_noise);
	vec3 color = mix(water_color.rgb, foam_color.rgb, foam_mix);

	// === EDGE HIGHLIGHTS ===
	// Bright edges on the left and right sides of the waterfall
	float left_edge = smoothstep(0.0, edge_width, uv.x);
	float right_edge = smoothstep(1.0, 1.0 - edge_width, uv.x);
	float edge_mask = 1.0 - min(left_edge, right_edge);
	color = mix(color, edge_color.rgb, edge_mask * 0.5);

	// === VERTICAL FADE (top and bottom) ===
	// Fade transparent at top (water source) and bottom (splash)
	float v_fade = smoothstep(0.0, top_fade, uv.y) * smoothstep(1.0, 1.0 - bottom_fade, uv.y);

	// === ALPHA ===
	// Combine: base water alpha * vertical fade * overall multiplier
	// Also add some noise-based alpha variation for a "not solid" water feel
	float alpha = water_color.a * v_fade * alpha_multiplier;
	alpha *= (0.85 + combined_noise * 0.15); // subtle alpha variation from noise

	// === SPARKLE / SHIMMER ===
	// Occasional bright sparkles where noise peaks align between both layers
	float sparkle = step(0.78, noise_1) * step(0.78, noise_2);
	color += sparkle * 0.3;

	COLOR = vec4(color, alpha);
}
