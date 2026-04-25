shader_type canvas_item;

uniform vec4 fire_color : source_color = vec4(1.0, 0.4, 0.0, 1.0);
uniform vec4 edge_color : source_color = vec4(1.0, 0.8, 0.0, 1.0);

// --- Fire ---
uniform float fire_height : hint_range(0.0, 1.5) = 0.4; 
uniform float fire_intensity : hint_range(0.0, 1.0) = 1.0;
uniform float fire_speed = 3.0;
uniform float fire_scale = 6.0;
uniform float edge_thickness = 0.08;

// --- Top Cracks (static, subtle) ---
uniform float crack_opacity : hint_range(0.0, 1.0) = 0.25;
uniform vec4 crack_color : source_color = vec4(1.0, 0.3, 0.0, 0.6);
uniform float crack_scale = 5.0;

// Hash
vec2 hash(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return fract(sin(p) * 43758.5453) * 2.0 - 1.0;
}

// 2D Noise
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(dot(hash(i + vec2(0.0,0.0)), f - vec2(0.0,0.0)), 
                   dot(hash(i + vec2(1.0,0.0)), f - vec2(1.0,0.0)), u.x),
               mix(dot(hash(i + vec2(0.0,1.0)), f - vec2(0.0,1.0)), 
                   dot(hash(i + vec2(1.0,1.0)), f - vec2(1.0,1.0)), u.x), u.y);
}

// Static voronoi edge distance for cracks
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
    
    // --- Aspect correction ---
    vec2 aspect = vec2(TEXTURE_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.x, 1.0);
    
    // ========= FIRE (Bottom Half) =========
    vec2 noise_uv = UV * aspect * fire_scale;
    noise_uv.y -= TIME * fire_speed;
    float n = noise(noise_uv) * 0.5 + 0.5;
    
    float distance_from_bottom = 1.0 - UV.y;
    float current_height = fire_height * fire_intensity;
    float fire_shape = (n * 0.5) + current_height - distance_from_bottom;
    
    float is_fire = step(0.0, fire_shape);
    float is_edge = step(0.0, fire_shape) - step(edge_thickness, fire_shape);
    
    vec3 final_color = tex.rgb;
    
    if (is_fire > 0.0 && tex.a > 0.0 && current_height > 0.0) {
        if (is_edge > 0.0) {
            final_color = mix(final_color, edge_color.rgb, edge_color.a);
        } else {
            final_color = mix(final_color, fire_color.rgb, fire_color.a);
        }
    }
    
    // ========= CRACKS (Top Half — Static, Subtle) =========
    if (fire_intensity > 0.0 && crack_opacity > 0.0 && tex.a > 0.0) {
        // Only draw cracks where fire ISN'T covering
        float no_fire = 1.0 - is_fire;
        
        vec2 crack_uv = UV * aspect;
        float cn = noise(crack_uv * 12.0);
        vec2 distorted = crack_uv + vec2(cn) * 0.02;
        
        float edge_dist = voronoi_cracks(distorted * crack_scale);
        
        // Very thin hairline
        float line_w = 0.005 * fire_intensity;
        float crack_line = smoothstep(line_w, line_w * 0.2, edge_dist);
        
        // Subtle glow around crack
        float glow_w = 0.02 * fire_intensity;
        float glow = smoothstep(glow_w, line_w, edge_dist) - crack_line;
        
        // Darken along crack line
        final_color *= 1.0 - (crack_line * crack_opacity * no_fire * 0.5);
        // Add faint crack glow
        final_color += crack_color.rgb * glow * crack_opacity * no_fire * fire_intensity;
    }
    
    COLOR = vec4(final_color, tex.a);
}
