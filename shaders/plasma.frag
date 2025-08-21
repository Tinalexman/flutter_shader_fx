#version 460 core

// Precision qualifier for mobile performance
precision mediump float;

// Input from vertex shader
in vec2 v_tex_coord;

// Output to framebuffer
out vec4 fragColor;

// Uniforms (will be set by Flutter)
uniform vec2 u_resolution;    // Screen resolution
uniform float u_time;         // Time in seconds
uniform vec2 u_touch;         // Touch position (normalized)
uniform float u_intensity;    // Effect intensity (0.0-1.0)
uniform vec4 u_color1;        // Primary color (RGBA)
uniform vec4 u_color2;        // Secondary color (RGBA)

// Constants
const float PI = 3.14159265359;
const float TWO_PI = 6.28318530718;

// Noise function for organic movement
float noise(vec2 p) {
    return fract(sin(dot(p, vec2(12.9898, 78.233))) * 43758.5453);
}

// Smooth noise function
float smoothNoise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    
    float a = noise(i);
    float b = noise(i + vec2(1.0, 0.0));
    float c = noise(i + vec2(0.0, 1.0));
    float d = noise(i + vec2(1.0, 1.0));
    
    vec2 u = f * f * (3.0 - 2.0 * f);
    
    return mix(mix(a, b, u.x), mix(c, d, u.x), u.y);
}

// Fractal noise function
float fractalNoise(vec2 p, int octaves) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;
    
    for (int i = 0; i < octaves; i++) {
        value += amplitude * smoothNoise(p * frequency);
        amplitude *= 0.5;
        frequency *= 2.0;
    }
    
    return value;
}

// Plasma function
float plasma(vec2 uv, float time) {
    vec2 p = uv * 8.0;
    
    float v1 = fractalNoise(p + time * 0.5, 4);
    float v2 = fractalNoise(p - time * 0.3, 4);
    float v3 = fractalNoise(p + vec2(time * 0.2, time * 0.1), 4);
    
    return (v1 + v2 + v3) / 3.0;
}

// Color palette function
vec3 palette(float t) {
    vec3 a = u_color1.rgb;
    vec3 b = u_color2.rgb;
    vec3 c = vec3(1.0, 1.0, 1.0);
    vec3 d = vec3(0.0, 0.33, 0.67);
    
    return a + b * cos(TWO_PI * (c * t + d));
}

void main() {
    // Normalized coordinates
    vec2 uv = v_tex_coord;
    
    // Calculate plasma value
    float plasmaValue = plasma(uv, u_time);
    
    // Apply intensity
    plasmaValue *= u_intensity;
    
    // Create color from plasma value
    vec3 color = palette(plasmaValue);
    
    // Add some variation based on touch position
    float touchInfluence = 1.0 - distance(uv, u_touch) * 0.5;
    color += vec3(touchInfluence * 0.2);
    
    // Ensure color is in valid range
    color = clamp(color, 0.0, 1.0);
    
    // Output final color
    fragColor = vec4(color, 1.0);
} 