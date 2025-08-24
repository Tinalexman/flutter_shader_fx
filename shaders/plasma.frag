#version 300 es
precision highp float;

uniform vec2 u_resolution;
uniform float u_time;
uniform vec2 u_touch;
uniform float u_intensity;
uniform vec4 u_color1;
uniform vec4 u_color2;
uniform float u_speed;

out vec4 fragColor;

// Constants
const float PI = 3.14159265359;
const float TWO_PI = 6.28318530718;
const int OCTAVES = 4;

// Enhanced hash function for better noise distribution
vec3 hash3(vec2 p) {
    vec3 q = vec3(
    dot(p, vec2(127.1, 311.7)),
    dot(p, vec2(269.5, 183.3)),
    dot(p, vec2(419.2, 371.9))
    );
    return fract(sin(q) * 43758.5453123);
}

float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

// Improved noise function with smoother interpolation
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    // Four corner values
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    // Smooth interpolation using quintic polynomial
    vec2 u = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);

    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

// Fractal Brownian Motion
float fbm(vec2 p, float lacunarity, float gain) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;

    for (int i = 0; i < OCTAVES; i++) {
        value += amplitude * noise(p * frequency);
        amplitude *= gain;
        frequency *= lacunarity;
    }

    return value;
}

// Domain warping for more organic movement
vec2 domainWarp(vec2 p, float time) {
    float scale = 4.0;
    vec2 q = vec2(
    fbm(p + vec2(0.0, 0.0), 2.0, 0.5),
    fbm(p + vec2(5.2, 1.3), 2.0, 0.5)
    );

    vec2 r = vec2(
    fbm(p + scale * q + vec2(1.7, 9.2) + 0.15 * time, 2.0, 0.5),
    fbm(p + scale * q + vec2(8.3, 2.8) + 0.126 * time, 2.0, 0.5)
    );

    return fbm(p + scale * r, 2.0, 0.5) * vec2(1.0);
}

// Multi-layer plasma function
float plasma(vec2 uv, float time) {
    vec2 p = uv * 6.0;
    float speed = u_speed;

    // Apply domain warping for organic movement
    vec2 warped = p + domainWarp(p * 0.5, time * speed * 0.5);

    // Multiple plasma layers with different frequencies and phases
    float layer1 = sin(warped.x + time * speed * 1.7) * cos(warped.y - time * speed * 1.3);
    float layer2 = sin(warped.x * 1.5 - time * speed * 1.1) * sin(warped.y * 1.2 + time * speed * 0.9);
    float layer3 = cos(length(warped) * 2.0 - time * speed * 2.0) * 0.7;

    // Fractal noise component
    float noiseComponent = fbm(warped * 0.8 + time * speed * 0.3, 2.0, 0.5);

    // Combine layers with different weights
    float plasma = (layer1 + layer2 * 0.8 + layer3 * 0.6 + noiseComponent * 1.2) / 3.6;

    // Add radial component for more interesting patterns
    vec2 center = vec2(0.5);
    float radial = distance(uv, center);
    plasma += sin(radial * 12.0 - time * speed * 3.0) * 0.3;

    // Add spiral component
    float angle = atan(uv.y - center.y, uv.x - center.x);
    plasma += sin(angle * 3.0 + radial * 8.0 - time * speed * 2.5) * 0.2;

    return plasma;
}

// Enhanced color palette with multiple color support
vec3 palette(float t, vec3 color1, vec3 color2) {
    // Normalize t to smooth range
    t = t * 0.5 + 0.5;
    t = fract(t);

    // Create complex color mapping using cosine palette
    vec3 a = color1;
    vec3 b = color2 - color1;
    vec3 c = vec3(1.0, 0.5, 0.5);
    vec3 d = vec3(0.0, 0.2, 0.5);

    vec3 color = a + b * cos(TWO_PI * (c * t + d));

    // Add additional color variation for more vibrant plasma
    color += vec3(
    sin(t * PI * 4.0) * 0.1,
    cos(t * PI * 3.0) * 0.1,
    sin(t * PI * 5.0) * 0.1
    );

    // Add some complementary colors for richer palette
    vec3 complement = vec3(1.0) - color1;
    color = mix(color, complement, sin(t * PI * 2.0) * 0.1 + 0.1);

    return color;
}

// Vignette effect for better visual focus
float vignette(vec2 uv, float strength) {
    vec2 center = vec2(0.5);
    float dist = distance(uv, center);
    return 1.0 - smoothstep(0.3, 1.0, dist * strength);
}

// Enhanced glow effect
float glow(float value, float intensity) {
    return pow(abs(sin(value * PI)), intensity);
}

// Touch interaction effect
float touchEffect(vec2 uv, vec2 touchPos, float time) {
    float dist = distance(uv, touchPos);
    float ripple = sin(dist * 15.0 - time * 8.0) * exp(-dist * 3.0);
    return ripple * 0.3;
}

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float time = u_time;

    // Calculate main plasma value
    float plasmaValue = plasma(uv, time);

    // Add touch interaction
    plasmaValue += touchEffect(uv, u_touch, time * u_speed);

    // Apply intensity
    plasmaValue *= u_intensity;

    // Create color from plasma value
    vec3 color = palette(plasmaValue, u_color1.rgb, u_color2.rgb);

    // Add enhanced glow effect
    float glowAmount = glow(plasmaValue, 2.0);
    color += vec3(glowAmount * 0.3);

    // Apply vignette for better visual focus
    float vignetteAmount = vignette(uv, 0.8);
    color *= vignetteAmount * 0.8 + 0.2;

    // Add subtle chromatic aberration for more realistic plasma look
    vec2 aberration = (uv - 0.5) * 0.02 * sin(time * 2.0);
    float r = palette(plasmaValue + aberration.x, u_color1.rgb, u_color2.rgb).r;
    float g = color.g;
    float b = palette(plasmaValue - aberration.x, u_color1.rgb, u_color2.rgb).b;
    color = vec3(r, g, b);

    // Add some energy spikes for more dynamic plasma
    float energy = sin(time * 3.0) * 0.1 + 0.9;
    color *= energy;

    // Ensure color is in valid range
    color = clamp(color, 0.0, 1.0);

    // Apply gamma correction for better visual appearance
    color = pow(color, vec3(1.0 / 2.2));

    // Add subtle film grain for texture
    float grain = hash(uv + time) * 0.05;
    color += vec3(grain);

    // Output final color
    fragColor = vec4(color, u_color1.a);
}