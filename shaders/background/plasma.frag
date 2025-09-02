#version 320 es
precision highp float;

uniform vec2 u_resolution;
uniform float u_time;
uniform float u_speed;
uniform float u_intensity;

uniform vec2 u_touch;
uniform vec4 u_color1;
uniform vec4 u_color2;

out vec4 fragColor;

// Constants
const float PI = 3.14159265359;
const float TWO_PI = 6.28318530718;
const int OCTAVES = 1;

// Enhanced hash function
float hash(vec2 p) {
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

// Smooth noise function
float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);

    float a = hash(i);
    float b = hash(i + vec2(1.0, 0.0));
    float c = hash(i + vec2(0.0, 1.0));
    float d = hash(i + vec2(1.0, 1.0));

    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(a, b, u.x) + (c - a) * u.y * (1.0 - u.x) + (d - b) * u.x * u.y;
}

// Fractal Brownian Motion with flowing movement
float fbm(vec2 p, float time, vec2 flow) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 1.0;

    // Add time-based flow to the position
    p += flow * time;

    for (int i = 0; i < OCTAVES; i++) {
        value += amplitude * noise(p * frequency);
        amplitude *= 0.5;
        frequency *= 2.0;

        // Rotate the coordinates for each octave to create swirling
        p = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.5)) * p;
    }

    return value;
}

// Flowing plasma function with multiple scrolling patterns
float flowingPlasma(vec2 uv, float time) {
    float speed = u_speed;
    vec2 p = uv * 4.0;

    // Multiple flow directions for complex patterns
    vec2 flow1 = vec2(1.0, 0.5) * speed;
    vec2 flow2 = vec2(-0.7, 1.2) * speed;
    vec2 flow3 = vec2(0.3, -0.8) * speed;

    // Layer 1: Main flowing noise
    float layer1 = fbm(p, time, flow1);

    // Layer 2: Counter-rotating flow
    float layer2 = fbm(p * 1.3, time * 0.8, flow2);

    // Layer 3: Fast turbulent flow
    float layer3 = fbm(p * 2.1, time * 1.5, flow3);

    // Layer 4: Scrolling sine waves
    float wave1 = sin(p.x * 3.0 + time * speed * 2.0) * cos(p.y * 2.0 - time * speed * 1.5);
    float wave2 = sin(p.y * 3.5 - time * speed * 1.8) * cos(p.x * 2.5 + time * speed * 1.2);

    // Layer 5: Diagonal scrolling pattern
    float diagonal = sin((p.x + p.y) * 4.0 - time * speed * 3.0) *
    cos((p.x - p.y) * 3.0 + time * speed * 2.5);

    // Layer 6: Circular flowing pattern
    vec2 center = vec2(0.5);
    vec2 toCenter = uv - center;
    float angle = atan(toCenter.y, toCenter.x);
    float radius = length(toCenter);
    float circular = sin(angle * 6.0 + radius * 10.0 - time * speed * 4.0) *
    cos(radius * 8.0 - time * speed * 2.0);

    // Combine all layers with different weights
    float plasma = layer1 * 0.4 +
    layer2 * 0.3 +
    layer3 * 0.2 +
    wave1 * 0.25 +
    wave2 * 0.2 +
    diagonal * 0.15 +
    circular * 0.3;

    return plasma;
}

// Advanced domain warping for fluid motion
vec2 advancedWarp(vec2 p, float time) {
    float speed = u_speed;

    // Primary warp
    vec2 q = vec2(
    fbm(p, time * 0.3, vec2(1.0, 0.0) * speed),
    fbm(p + vec2(1.0), time * 0.3, vec2(0.0, 1.0) * speed)
    );

    // Secondary warp
    vec2 r = vec2(
    fbm(p + 4.0 * q + vec2(1.7, 9.2), time * 0.5, vec2(0.5, 1.0) * speed),
    fbm(p + 4.0 * q + vec2(8.3, 2.8), time * 0.5, vec2(1.0, 0.5) * speed)
    );

    return fbm(p + 4.0 * r, time * 0.2, vec2(0.3, 0.7) * speed) * vec2(1.0);
}

// Multi-directional flowing plasma
float multiFlowPlasma(vec2 uv, float time) {
    vec2 p = uv * 6.0;
    float speed = u_speed;

    // Apply advanced domain warping
    vec2 warped = p + advancedWarp(p * 0.5, time) * 2.0;

    // Horizontal flow (like lava flow)
    float horizontal = sin(warped.y * 2.0 + time * speed * 2.0) *
    cos(warped.x * 1.5 - time * speed * 0.5);

    // Vertical flow (like rising plasma)
    float vertical = sin(warped.x * 2.5 - time * speed * 1.5) *
    cos(warped.y * 2.0 + time * speed * 1.8);

    // Spiral flow
    vec2 center = vec2(3.0); // Center in warped space
    vec2 toCenter = warped - center;
    float angle = atan(toCenter.y, toCenter.x);
    float radius = length(toCenter);
    float spiral = sin(angle * 4.0 + radius * 2.0 - time * speed * 3.0) *
    cos(radius * 1.5 + time * speed * 1.0);

    // Turbulent flow
    float turbulent = fbm(warped + vec2(time * speed * 0.8, time * speed * 0.6),
                          time, vec2(1.0, 0.5) * speed);

    // Combine flows
    return (horizontal + vertical + spiral + turbulent * 2.0) / 5.0;
}


vec3 flowingPalette(float t, vec3 color1, vec3 color2, float time) {
    // Normalize t to 0-1 range
    t = t * 0.5 + 0.5;

    // Add subtle time-based animation to the interpolation point
    float animatedT = t + sin(time * 0.3) * 0.1;
    animatedT = clamp(animatedT, 0.0, 1.0);

    // Simple linear interpolation between your actual colors
    vec3 baseColor = mix(color1, color2, animatedT);

    // Optional: Add subtle variations while keeping your colors dominant
    vec3 variation = vec3(
    sin(t * PI * 3.0 + time * 0.5) * 0.05,
    cos(t * PI * 2.0 + time * 0.7) * 0.05,
    sin(t * PI * 4.0 + time * 0.3) * 0.05
    );

    return baseColor + variation;
}

// Touch ripple effect that flows with the plasma
float flowingTouchEffect(vec2 uv, vec2 touchPos, float time) {
    float dist = distance(uv, touchPos);

    // Multiple ripple frequencies for complex interaction
    float ripple1 = sin(dist * 20.0 - time * 8.0) * exp(-dist * 2.0);
    float ripple2 = sin(dist * 15.0 - time * 6.0) * exp(-dist * 1.5);
    float ripple3 = sin(dist * 10.0 - time * 10.0) * exp(-dist * 3.0);

    // Flow the ripples in different directions
    vec2 flow = vec2(sin(time * 2.0), cos(time * 1.5)) * 0.1;
    vec2 flowedUV = uv + flow;
    float flowDist = distance(flowedUV, touchPos);
    float flowRipple = sin(flowDist * 12.0 - time * 7.0) * exp(-flowDist * 2.5);

    return (ripple1 + ripple2 + ripple3 + flowRipple) * 0.2;
}

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float time = u_time;

    // Calculate main flowing plasma
    float plasma1 = flowingPlasma(uv, time);
    float plasma2 = multiFlowPlasma(uv, time * 0.7);

    // Combine plasma layers
    float finalPlasma = (plasma1 + plasma2 * 0.8) / 1.8;

    // Add flowing touch interaction
    finalPlasma += flowingTouchEffect(uv, u_touch, time * u_speed);

    // Apply intensity
    finalPlasma *= u_intensity;

    vec3 color = flowingPalette(finalPlasma, u_color1.rgb, u_color2.rgb, time);

    // Add dynamic glow that flows (reduced intensity to preserve your colors)
    float dynamicGlow = sin(finalPlasma * PI * 2.0 + time) * 0.15 + 0.85;
    color *= dynamicGlow;

    // Subtle vignette (reduced intensity to preserve colors)
    vec2 center = vec2(0.5);
    float dist = distance(uv, center);
    float vignette = 1.0 - smoothstep(0.5, 1.2, dist);
    color *= vignette * 0.3 + 0.7;

    // Add flowing highlights (reduced to preserve colors)
    float highlight = sin(finalPlasma * 8.0 + time * 2.0) * 0.05 + 0.95;
    color *= highlight;

    // Ensure valid range
    color = clamp(color, 0.0, 1.0);

    // Output final flowing color
    fragColor = vec4(color, u_color1.a);
}