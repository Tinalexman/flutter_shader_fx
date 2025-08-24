#version 300 es
precision highp float;

uniform vec2 u_resolution;
uniform float u_time;
uniform vec2 u_touch;
uniform float u_intensity;
uniform vec4 u_color1;
uniform vec4 u_color2;
uniform float u_speed;
uniform float u_scale;


out vec4 fragColor;

// Constants
const float PI = 3.14159265359;
const int OCTAVES = 4;

// Enhanced hash function for better randomness
float hash(vec2 p) {
    p = fract(p * vec2(127.1, 311.7));
    p += dot(p, p + 19.19);
    return fract(p.x * p.y);
}

// Smooth noise function using cubic interpolation
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    // Four corner values
    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    // Smooth interpolation using cubic curve
    vec2 u = f * f * (3.0 - 2.0 * f);

    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

// Fractal Brownian Motion with multiple octaves
float fbm(vec2 p, float time) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;

    // Add time-based movement
    p += vec2(cos(time * 0.1) * 0.5, sin(time * 0.15) * 0.3);

    for (int i = 0; i < OCTAVES; i++) {
        value += amplitude * noise(p * frequency);
        amplitude *= 0.5;
        frequency *= 2.0;

        // Rotate coordinates for each octave to reduce artifacts
        float angle = 0.5;
        p = mat2(cos(angle), sin(angle), -sin(angle), cos(angle)) * p;
    }

    return value;
}

// Ridged noise for more dramatic variations
float ridgedNoise(vec2 p, float time) {
    return 1.0 - abs(fbm(p, time) * 2.0 - 1.0);
}

// Turbulent noise with domain warping
float turbulence(vec2 p, float time) {
    vec2 q = vec2(
    fbm(p, time),
    fbm(p + vec2(1.0), time)
    );

    vec2 r = vec2(
    fbm(p + 4.0 * q + vec2(1.7, 9.2), time),
    fbm(p + 4.0 * q + vec2(8.3, 2.8), time)
    );

    return fbm(p + 4.0 * r, time);
}

// Voronoi-like cellular noise
float cellularNoise(vec2 p, float time) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    float minDist = 1.0;

    for (int x = -1; x <= 1; x++) {
        for (int y = -1; y <= 1; y++) {
            vec2 neighbor = vec2(float(x), float(y));
            vec2 point = hash(i + neighbor) * vec2(1.0) + neighbor;

            // Animate the cellular points
            point += vec2(sin(time * 0.5 + hash(i + neighbor) * 6.28),
            cos(time * 0.3 + hash(i + neighbor) * 6.28)) * 0.3;

            float dist = length(f - point);
            minDist = min(minDist, dist);
        }
    }

    return minDist;
}

// Wood grain-like noise
float woodNoise(vec2 p, float time) {
    vec2 center = vec2(0.5);
    vec2 toCenter = p - center;
    float angle = atan(toCenter.y, toCenter.x);
    float radius = length(toCenter);

    // Create wood ring pattern
    float rings = sin(radius * 20.0 + fbm(p * 2.0, time) * 3.0 + time * 0.5);

    // Add wood grain texture
    float grain = fbm(vec2(radius * 10.0, angle * 5.0), time);

    return (rings + grain) * 0.5;
}

// Marble-like noise using sine waves and fbm
float marbleNoise(vec2 p, float time) {
    float marble = sin(p.x * 3.0 + fbm(p * 4.0, time) * 5.0 + time * 0.2);
    marble += sin(p.y * 2.0 + fbm(p * 3.0 + vec2(100.0), time) * 4.0 + time * 0.3);
    return marble * 0.5;
}

// Main noise function that combines different techniques
float mainNoise(vec2 uv, float time, float scale, float speed) {
    vec2 p = uv * scale;
    float animatedTime = time * speed;

    // Layer 1: Base fractal noise
    float base = fbm(p, animatedTime);

    // Layer 2: Ridged noise for sharp features
    float ridged = ridgedNoise(p * 0.7, animatedTime * 1.2);

    // Layer 3: Turbulent flow
    float turbulent = turbulence(p * 0.5, animatedTime * 0.8);

    // Layer 4: Cellular texture
    float cellular = cellularNoise(p * 2.0, animatedTime * 0.6);

    // Layer 5: Wood grain pattern
    float wood = woodNoise(p * 0.3, animatedTime * 0.4);

    // Layer 6: Marble veins
    float marble = marbleNoise(p * 0.8, animatedTime * 1.1);

    // Combine all layers with different weights
    float combined = base * 0.3 +
    ridged * 0.25 +
    turbulent * 0.2 +
    cellular * 0.1 +
    wood * 0.1 +
    marble * 0.05;

    // Add some flowing movement
    vec2 flow = vec2(
    sin(animatedTime * 0.3 + uv.x * 4.0),
    cos(animatedTime * 0.4 + uv.y * 3.0)
    ) * 0.02;

    combined += fbm(p + flow * scale, animatedTime) * 0.15;

    return combined;
}

// Convert noise to grayscale with contrast enhancement
vec3 noiseToColor(float noise, float intensity) {
    // Normalize noise to 0-1 range
    noise = noise * 0.5 + 0.5;

    // Apply intensity
    noise *= intensity;

    // Enhance contrast
    noise = smoothstep(0.2, 0.8, noise);

    // Convert to grayscale with subtle tinting
    vec3 color = vec3(noise);

    // Add subtle color variations
    color.r += sin(noise * PI * 2.0) * 0.05;
    color.g += cos(noise * PI * 3.0) * 0.03;
    color.b += sin(noise * PI * 4.0) * 0.04;

    return clamp(color, 0.0, 1.0);
}

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;

    // Calculate main noise
    float noise = mainNoise(uv, u_time, u_scale, u_speed);

    // Convert to color with intensity applied
    vec3 color = noiseToColor(noise, u_intensity);

    // Add subtle animation glow
    float glow = sin(noise * PI * 4.0 + u_time * u_speed) * 0.05 + 0.95;
    color *= glow;

    // Optional vignette effect
    vec2 center = vec2(0.5);
    float dist = distance(uv, center);
    float vignette = 1.0 - smoothstep(0.7, 1.4, dist);
    color *= vignette * 0.2 + 0.8;

    fragColor = vec4(color, 1.0);
}