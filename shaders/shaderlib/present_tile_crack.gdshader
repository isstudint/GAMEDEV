shader_type canvas_item;

// Subtle tile crack overlay for Present timeline.
// Uses world coordinates so cracks flow seamlessly across tile boundaries.

uniform float crack_intensity : hint_range(0.0, 1.0) = 0.0;
uniform vec4 crack_color : source_color = vec4(1.0, 0.55, 0.15, 1.0);
uniform float crack_scale = 0.015; // World-space scale (smaller = bigger cells)
uniform float crack_opacity : hint_range(0.0, 1.0) = 0.2;
uniform float glow_strength : hint_range(0.0, 5.0) = 1.0;

// Pass world position from vertex to fragment
varying vec2 world_pos;

void vertex() {
    world_pos = (MODEL_MATRIX * vec4(VERTEX, 0.0, 1.0)).xy;
}

// Hash
vec2 hash(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return fract(sin(p) * 43758.5453) * 2.0 - 1.0;
}

// Voronoi edge distance
float voronoi_cracks(vec2 uv) {
    vec2 g = floor(uv);
    vec2 f = fract(uv);
    vec2 min_p;
    float min_dist = 8.0;
    for(int y = -1; y <= 1; y++) {
        for(int x = -1; x <= 1; x++) {
            vec2 lattice = vec2(float(x), float(y));
            vec2 offset = hash(g + lattice) * 0.5 + 0.5;
            vec2 diff = lattice + offset - f;
            float d = dot(diff, diff);
            if(d < min_dist) { min_dist = d; min_p = diff; }
        }
    }
    min_dist = 8.0;
    for(int y = -2; y <= 2; y++) {
        for(int x = -2; x <= 2; x++) {
            vec2 lattice = vec2(float(x), float(y));
            vec2 offset = hash(g + lattice) * 0.5 + 0.5;
            vec2 diff = lattice + offset - f;
            if(dot(min_p - diff, min_p - diff) > 0.00001) {
                float d = dot(0.5 * (min_p + diff), normalize(diff - min_p));
                min_dist = min(min_dist, d);
            }
        }
    }
    return min_dist;
}

void fragment() {
    vec4 tex = texture(TEXTURE, UV);
    
    if (crack_intensity <= 0.0 || tex.a <= 0.0) {
        COLOR = tex;
    } else {
        vec2 scaled_pos = world_pos * crack_scale;
        float edge_dist = voronoi_cracks(scaled_pos);
        
        // Hairline cracks
        float line_w = 0.006 * crack_intensity;
        float crack_line = smoothstep(line_w, line_w * 0.15, edge_dist);
        
        // Soft glow halo
        float glow_w = 0.025 * crack_intensity;
        float glow = smoothstep(glow_w, line_w, edge_dist) - crack_line;
        
        // Darken along the crack
        vec3 result = tex.rgb * (1.0 - crack_line * crack_opacity * 0.6);
        
        // Add faint colored glow
        result += crack_color.rgb * glow * glow_strength * crack_intensity * crack_opacity;
        
        COLOR = vec4(result, tex.a);
    }
}
