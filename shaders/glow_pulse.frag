#version 300 es
precision highp float;

uniform vec2 u_resolution;
uniform float u_time;
uniform float u_speed;        // Pulse speed
uniform float u_intensity;    // Glow intensity multiplier


uniform vec2 u_center;        // Center position of the glow (0.0 to 1.0)
uniform float u_size;         // Base size of the glow
uniform vec4 u_color;         // Glow color (RGB + Alpha)
uniform float u_pulseType;    // 0=sine, 1=heartbeat, 2=breathing, 3=electric

out vec4 fragColor;

const float PI = 3.14159265359;
const float TWO_PI = 6.28318530718;

// Enhanced smoothstep for softer gradients
float smoothGlow(float dist, float inner, float outer) {
    return 1.0 - smoothstep(inner, outer, dist);
}

// Sine wave pulse - smooth and continuous
float sinePulse(float time, float speed) {
    return sin(time * speed) * 0.5 + 0.5;
}

// Heartbeat pulse - double beat pattern
float heartbeatPulse(float time, float speed) {
    float t = mod(time * speed, TWO_PI);

    // First beat (stronger)
    float beat1 = exp(-pow((t - PI * 0.3) * 3.0, 2.0)) * 1.0;

    // Second beat (weaker, slightly delayed)
    float beat2 = exp(-pow((t - PI * 0.7) * 4.0, 2.0)) * 0.6;

    // Combine beats with baseline
    return (beat1 + beat2) * 0.8 + 0.2;
}

// Breathing pulse - slow inhale/exhale pattern
float breathingPulse(float time, float speed) {
    float t = time * speed * 0.5; // Slower than other pulses

    // Inhale (quick rise)
    if (mod(t, TWO_PI) < PI) {
        float inhale = sin(mod(t, TWO_PI)) * 0.6 + 0.4;
        return pow(inhale, 0.7); // Ease in
    }
    // Exhale (slow fall with pause)
    else {
        float exhale = cos(mod(t, TWO_PI) - PI) * 0.6 + 0.4;
        return pow(exhale, 2.0); // Ease out
    }
}

// Electric pulse - irregular, energetic bursts
float electricPulse(float time, float speed) {
    float t = time * speed;

    // Base sine wave
    float base = sin(t) * 0.5 + 0.5;

    // Add irregular spikes
    float spike1 = sin(t * 7.3) * sin(t * 3.7);
    float spike2 = cos(t * 11.1) * sin(t * 5.9);
    float spike3 = sin(t * 13.7) * cos(t * 2.3);

    // Combine with sharp transitions
    float electric = base + (spike1 + spike2 + spike3) * 0.3;

    // Add random flickers
    float flicker = step(0.85, sin(t * 17.3)) * 0.5;

    return clamp(electric + flicker, 0.0, 1.0);
}

// Get pulse value based on type
float getPulse(float time, float speed, float pulseType) {
    if (pulseType < 0.5) {
        return sinePulse(time, speed);
    } else if (pulseType < 1.5) {
        return heartbeatPulse(time, speed);
    } else if (pulseType < 2.5) {
        return breathingPulse(time, speed);
    } else {
        return electricPulse(time, speed);
    }
}

// Multiple layer glow for depth
float multiLayerGlow(float dist, float pulse, float size) {
    // Core glow (brightest, smallest)
    float core = smoothGlow(dist, 0.0, size * 0.3) * pulse;

    // Mid glow (medium brightness, medium size)
    float mid = smoothGlow(dist, size * 0.2, size * 0.7) * pulse * 0.7;

    // Outer glow (softest, largest)
    float outer = smoothGlow(dist, size * 0.5, size * 1.5) * pulse * 0.4;

    // Atmospheric halo (very soft, very large)
    float halo = smoothGlow(dist, size * 1.0, size * 3.0) * pulse * 0.2;

    return core + mid + outer + halo;
}

// Radial gradient with customizable falloff
float radialGradient(vec2 uv, vec2 center, float size, float softness) {
    float dist = distance(uv, center);
    return smoothGlow(dist, 0.0, size) * softness;
}

// Add subtle noise to the glow for more organic feel
float glowNoise(vec2 uv, float time) {
    vec2 p = uv * 10.0 + time * 0.5;
    return sin(p.x) * cos(p.y) * 0.1 + 0.9;
}

// Screen blend mode for multiple glows
vec3 screenBlend(vec3 base, vec3 blend) {
    return 1.0 - (1.0 - base) * (1.0 - blend);
}

// Add chromatic aberration effect for electric pulse
vec3 chromaticAberration(vec2 uv, vec2 center, float amount) {
    vec2 offset = (uv - center) * amount;

    float r = distance(uv - offset * 0.01, center);
    float g = distance(uv, center);
    float b = distance(uv + offset * 0.01, center);

    return vec3(r, g, b);
}

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;

    // Get the pulse value
    float pulse = getPulse(u_time, u_speed, u_pulseType);

    // Calculate distance from center
    float dist = distance(uv, u_center);

    // Apply pulsing to the size
    float animatedSize = u_size * (0.8 + pulse * 0.4);

    // Create multi-layer glow
    float glow = multiLayerGlow(dist, pulse, animatedSize);

    // Apply intensity
    glow *= u_intensity;

    // Add subtle noise for organic feel
    glow *= glowNoise(uv, u_time);

    // Start with base color
    vec3 color = u_color.rgb * glow;

    // Add special effects based on pulse type
    if (u_pulseType > 2.5) { // Electric pulse
                             // Add chromatic aberration
                             vec3 aberration = chromaticAberration(uv, u_center, glow * 0.02);
                             color += aberration * 0.1 * pulse;

                             // Add electric flicker highlights
                             float flicker = step(0.9, sin(u_time * u_speed * 23.7));
                             color += vec3(1.0, 0.8, 0.9) * flicker * glow * 0.3;
    }

    if (u_pulseType < 0.5) { // Sine pulse
                             // Add soft color shift
                             color += vec3(
                             sin(u_time + glow) * 0.1,
                             cos(u_time * 0.7 + glow) * 0.1,
                             sin(u_time * 1.3 + glow) * 0.1
                             ) * pulse;
    }

    // Add rim lighting effect
    float rim = smoothGlow(dist, animatedSize * 0.8, animatedSize * 1.2);
    color += u_color.rgb * rim * 0.3 * pulse;

    // Add center hotspot
    float hotspot = smoothGlow(dist, 0.0, animatedSize * 0.1);
    color += vec3(1.0) * hotspot * pulse * 0.5;

    // Apply gamma correction for better visual quality
    color = pow(color, vec3(0.8));

    // Calculate alpha with smooth falloff
    float alpha = smoothGlow(dist, 0.0, animatedSize * 2.0) * u_color.a * pulse;

    // Add subtle outer fade
    alpha *= smoothstep(0.8, 0.0, dist);

    // Ensure we don't exceed maximum values
    color = clamp(color, 0.0, 1.0);
    alpha = clamp(alpha, 0.0, 1.0);

    fragColor = vec4(color, alpha);
}