shader_type canvas_item;

// --- Main Controls ---
// How intense the cracks are. 0.0 for "Past", 1.0 for "Present"
uniform float crack_intensity : hint_range(0.0, 1.0) = 1.0;
// The glowing color of the edges
uniform vec4 crack_color : source_color = vec4(1.0, 0.55, 0.15, 1.0); // Warm amber glow
// Speed at which the reality cracks shift
uniform float time_scale = 0.2;

// --- Cracks ---
uniform float crack_scale = 4.0;
uniform float jaggedness = 0.08;

// --- Glitch (Removed per request for cleaner look) ---
uniform float glitch_strength : hint_range(0.0, 0.1) = 0.0; 
uniform float glitch_frequency : hint_range(0.0, 20.0) = 0.0;

// --- Void Spots (Missing Reality) ---
uniform float void_threshold : hint_range(0.0, 1.0) = 0.7; // How rare the spots are (higher = more rare)
uniform float void_size : hint_range(0.0, 1.0) = 0.2; // Size of the transparent spots

// --- Optical ---
uniform float chromatic_aberration = 0.02;
uniform float blur_amount : hint_range(0.0, 5.0) = 0.0; // Adds depth of field!

// Pseudo-random hash function
vec2 hash(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)), dot(p, vec2(269.5, 183.3)));
    return fract(sin(p) * 43758.5453) * 2.0 - 1.0;
}

// 2D Noise for jagged cracks
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(dot(hash(i + vec2(0.0,0.0)), f - vec2(0.0,0.0)), 
                   dot(hash(i + vec2(1.0,0.0)), f - vec2(1.0,0.0)), u.x),
               mix(dot(hash(i + vec2(0.0,1.0)), f - vec2(0.0,1.0)), 
                   dot(hash(i + vec2(1.0,1.0)), f - vec2(1.0,1.0)), u.x), u.y);
}

// Generates defined circular void spots
float void_spots(vec2 uv) {
    vec2 g = floor(uv);
    vec2 f = fract(uv);
    float min_dist = 8.0;
    
    for(int y=-1; y<=1; y++) {
        for(int x=-1; x<=1; x++) {
            vec2 lattice = vec2(float(x), float(y));
            float cell_hash = hash(g + lattice).x * 0.5 + 0.5;
            
            if (cell_hash > void_threshold) {
                vec2 offset = hash(g + lattice + vec2(100.0)) * 0.5 + 0.5;
                offset = 0.5 + 0.5 * sin(TIME * time_scale + 6.2831 * offset);
                
                vec2 diff = lattice + offset - f;
                float d = length(diff); 
                
                if(d < min_dist) {
                    min_dist = d;
                }
            }
        }
    }
    return min_dist;
}

// Procedural Voronoi distance to edges
float voronoi_distance(vec2 uv) {
    vec2 g = floor(uv);
    vec2 f = fract(uv);
    
    vec2 min_p;
    float min_dist = 8.0;
    
    // First pass
    for(int y=-1; y<=1; y++) {
        for(int x=-1; x<=1; x++) {
            vec2 lattice = vec2(float(x), float(y));
            vec2 offset = hash(g + lattice) * 0.5 + 0.5;
            offset = 0.5 + 0.5 * sin(TIME * time_scale + 6.2831 * offset);
            vec2 diff = lattice + offset - f;
            float d = dot(diff, diff);
            if(d < min_dist) {
                min_dist = d;
                min_p = diff;
            }
        }
    }
    
    // Second pass
    min_dist = 8.0;
    for(int y=-2; y<=2; y++) {
        for(int x=-2; x<=2; x++) {
            vec2 lattice = vec2(float(x), float(y));
            vec2 offset = hash(g + lattice) * 0.5 + 0.5;
            offset = 0.5 + 0.5 * sin(TIME * time_scale + 6.2831 * offset);
            vec2 diff = lattice + offset - f;
            
            if(dot(min_p - diff, min_p - diff) > 0.00001) {
                float d = dot(0.5*(min_p + diff), normalize(diff - min_p));
                min_dist = min(min_dist, d);
            }
        }
    }
    return min_dist;
}

void fragment() {
    if (crack_intensity <= 0.0) {
        COLOR = textureLod(TEXTURE, UV, blur_amount);
    } else {
        vec2 aspect = vec2(TEXTURE_PIXEL_SIZE.y / TEXTURE_PIXEL_SIZE.x, 1.0);
        
        vec2 aspect_uv = UV * aspect;
        
        // --- 1. JAGGED CRACKS ---
        float n = noise(aspect_uv * 8.0);
        float n2 = noise(aspect_uv * 12.0 + vec2(100.0));
        vec2 distorted_uv = aspect_uv + vec2(n, n2) * jaggedness * crack_intensity;
        
        float edge_dist = voronoi_distance(distorted_uv * crack_scale);
        
        // Made cracks much thinner and more elegant
        float core_thickness = 0.005 * crack_intensity;
        float dissolve = smoothstep(core_thickness, core_thickness * 0.3, edge_dist); 
        
        float glow_thickness = 0.02 * crack_intensity;
        float glow_mask = smoothstep(glow_thickness, core_thickness, edge_dist) - dissolve;
        
        // --- 2. BASE TEXTURE SAMPLING (With Depth of Field Blur) ---
        vec2 tex_offset = vec2(glow_mask * 0.02 * crack_intensity);
        float r = textureLod(TEXTURE, UV + tex_offset + vec2(chromatic_aberration * glow_mask, 0.0), blur_amount).r;
        float g = textureLod(TEXTURE, UV + tex_offset, blur_amount).g;
        float b = textureLod(TEXTURE, UV + tex_offset - vec2(chromatic_aberration * glow_mask, 0.0), blur_amount).b;
        float a = textureLod(TEXTURE, UV, blur_amount).a;  
        
        vec3 tex_color = vec3(r, g, b);
        
        vec3 glow = crack_color.rgb * glow_mask * 3.5 * crack_intensity;
        tex_color += glow;
        
        // --- 4. VOID SPOTS (Sucked out of reality) ---
        // Get distance to nearest void spot (scaled by noise for jagged edges)
        float spot_dist = void_spots(aspect_uv * 3.0) + noise(aspect_uv * 10.0) * 0.05;
        
        // If spot_dist < void_size, it's a hole.
        float is_void = (1.0 - smoothstep(void_size * crack_intensity - 0.02, void_size * crack_intensity, spot_dist)) * crack_intensity;
        float void_glow = (1.0 - smoothstep(void_size * crack_intensity, (void_size + 0.08) * crack_intensity, spot_dist)) - is_void;
        
        tex_color += crack_color.rgb * void_glow * 3.0 * crack_intensity;
        
        // Apply crack dissolve and void holes
        float final_alpha = a * clamp(1.0 - (dissolve * crack_intensity * 1.5) - is_void, 0.0, 1.0);
        
        COLOR = vec4(tex_color, final_alpha);
    }
}
