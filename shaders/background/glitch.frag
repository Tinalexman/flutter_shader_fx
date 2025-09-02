#version 320 es
precision mediump float;

uniform vec2 u_resolution;
uniform float u_time;
uniform float u_speed;
uniform float u_intensity;
uniform vec2 u_touch;
uniform vec4 u_color1;
uniform vec4 u_color2;
uniform float u_glitch_type;

out vec4 fragColor;

const float PI = 3.14159265359;

// Better random function
float random(vec2 st) {
    return fract(sin(dot(st.xy, vec2(12.9898, 78.233))) * 43758.5453123);
}

// Create a base texture pattern to glitch
vec3 createBaseTexture(vec2 uv, float time) {
    // Create a more interesting base pattern
    float pattern1 = sin(uv.x * 20.0 + time) * cos(uv.y * 15.0 + time * 0.7);
    float pattern2 = sin(uv.x * 8.0 - time * 0.5) * sin(uv.y * 12.0 + time);
    
    vec3 color1 = u_color1.rgb;
    vec3 color2 = u_color2.rgb;
    
    float mix_factor = (pattern1 + pattern2) * 0.5 + 0.5;
    return mix(color1, color2, mix_factor);
}

// Digital glitch type (RGB split + blocks)
vec3 digitalGlitch(vec2 uv, float time, float intensity) {
    vec2 originalUV = uv;
    
    // Random glitch triggers
    float glitchTrigger = step(0.9, random(vec2(time * 0.1, 0.0)));
    
    // Block displacement
    float blockSize = 20.0;
    vec2 blockID = floor(uv * blockSize);
    float blockRand = random(blockID + floor(time * 2.0));
    
    // Horizontal displacement for blocks
    float displacement = 0.0;
    if (blockRand > 0.95) {
        displacement = (random(blockID) - 0.5) * intensity * 0.1;
        uv.x += displacement;
    }
    
    // RGB channel splitting
    float splitAmount = intensity * 0.01 * glitchTrigger;
    
    vec3 baseColor = createBaseTexture(uv, time);
    vec3 rColor = createBaseTexture(uv + vec2(splitAmount, 0.0), time);
    vec3 gColor = createBaseTexture(uv, time);
    vec3 bColor = createBaseTexture(uv - vec2(splitAmount, 0.0), time);
    
    vec3 finalColor = vec3(rColor.r, gColor.g, bColor.b);
    
    // Add digital noise
    float noise = random(uv * 100.0 + time * 10.0);
    if (noise > 0.98) {
        finalColor = vec3(1.0, 0.0, 1.0); // Magenta artifacts
    }
    
    return finalColor;
}

// Analog/VHS glitch type
vec3 analogGlitch(vec2 uv, float time, float intensity) {
    vec2 originalUV = uv;
    
    // Horizontal sync issues
    float syncNoise = random(vec2(floor(uv.y * 50.0), floor(time * 5.0)));
    if (syncNoise > 0.95) {
        uv.x += sin(uv.y * 100.0 + time * 20.0) * intensity * 0.02;
    }
    
    // Vertical roll
    float rollAmount = sin(time * 2.0) * intensity * 0.05;
    uv.y += rollAmount;
    
    vec3 baseColor = createBaseTexture(uv, time);
    
    // Color bleeding/separation
    float bleeding = intensity * 0.3;
    baseColor.r = mix(baseColor.r, createBaseTexture(uv + vec2(0.005, 0.0), time).r, bleeding);
    baseColor.b = mix(baseColor.b, createBaseTexture(uv - vec2(0.005, 0.0), time).b, bleeding);
    
    // Add scanlines
    float scanline = sin(originalUV.y * 800.0 + time * 10.0);
    baseColor *= 0.9 + 0.1 * scanline;
    
    // VHS static
    float staticNoise = random(originalUV * 200.0 + time * 50.0);
    if (staticNoise > 0.97) {
        baseColor = mix(baseColor, vec3(staticNoise), 0.5);
    }
    
    return baseColor;
}

// Data corruption glitch type
vec3 corruptionGlitch(vec2 uv, float time, float intensity) {
    // Pixel corruption in blocks
    float blockSize = 8.0;
    vec2 blockUV = floor(uv * blockSize) / blockSize;
    float corruption = random(blockUV + floor(time * 10.0));
    
    vec3 baseColor = createBaseTexture(uv, time);
    
    // Corrupt certain blocks
    if (corruption > 0.9) {
        // Replace with corrupted data
        float corruptType = random(blockUV + 100.0);
        if (corruptType < 0.33) {
            baseColor = vec3(1.0, 0.0, 0.0); // Red corruption
        } else if (corruptType < 0.66) {
            baseColor = vec3(0.0, 1.0, 0.0); // Green corruption
        } else {
            baseColor = vec3(random(blockUV), random(blockUV + 1.0), random(blockUV + 2.0)); // Random colors
        }
    }
    
    // Add bit-shift artifacts
    float bitShift = step(0.98, random(uv * 50.0 + time * 5.0));
    if (bitShift > 0.0) {
        baseColor = floor(baseColor * 4.0) / 4.0; // Posterize
    }
    
    return baseColor;
}

// Screen tearing glitch type
vec3 tearingGlitch(vec2 uv, float time, float intensity) {
    // Horizontal tears
    float tearLine = sin(time * 3.0 + uv.y * 2.0);
    float tearTrigger = step(0.8, tearLine);
    
    // Displace sections horizontally
    float displacement = tearTrigger * intensity * 0.1 * sin(time * 10.0);
    uv.x += displacement;
    
    vec3 baseColor = createBaseTexture(uv, time);
    
    // Add tearing artifacts at discontinuities
    if (tearTrigger > 0.0) {
        float edgeNoise = random(vec2(uv.y * 100.0, time * 5.0));
        if (edgeNoise > 0.7) {
            baseColor = mix(baseColor, vec3(1.0, 1.0, 0.0), 0.5); // Yellow tears
        }
    }
    
    return baseColor;
}

// Wave glitch type
vec3 waveGlitch(vec2 uv, float time, float intensity) {
    // Sine wave distortion
    float waveFreq = 5.0;
    float wavePhase = time * 2.0;
    float wave = sin(uv.y * waveFreq + wavePhase) * intensity * 0.05;
    
    // Apply wave distortion
    uv.x += wave;
    
    vec3 baseColor = createBaseTexture(uv, time);
    
    // Add wave-based color shifts
    float colorShift = sin(uv.y * 10.0 + time * 5.0) * intensity;
    baseColor.r += colorShift * 0.1;
    baseColor.b -= colorShift * 0.1;
    
    // Add interference patterns
    float interference = sin(uv.x * 50.0 + time * 15.0) * sin(uv.y * 30.0 + time * 8.0);
    baseColor += vec3(interference * intensity * 0.1);
    
    return baseColor;
}

// Touch-based glitch enhancement
vec3 applyTouchGlitch(vec3 color, vec2 uv, vec2 touchPos, float time, float intensity) {
    float dist = distance(uv, touchPos);
    float touchInfluence = smoothstep(0.3, 0.0, dist);
    
    if (touchInfluence > 0.0) {
        // Radial distortion around touch
        vec2 direction = normalize(uv - touchPos);
        vec2 distortion = direction * touchInfluence * intensity * 0.02;
        
        // Create ripple effect
        float ripple = sin(dist * 20.0 - time * 10.0) * touchInfluence;
        color += vec3(ripple * 0.2);
        
        // Add color inversion in touch area
        color = mix(color, vec3(1.0) - color, touchInfluence * 0.3);
    }
    
    return color;
}

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    float time = u_time * u_speed;
    
    vec3 glitchColor;
    
    // Apply different glitch types
    int glitchTypeInt = int(u_glitch_type);
    
    if (glitchTypeInt == 0) {
        // Digital
        glitchColor = digitalGlitch(uv, time, u_intensity);
    } else if (glitchTypeInt == 1) {
        // Analog
        glitchColor = analogGlitch(uv, time, u_intensity);
    } else if (glitchTypeInt == 2) {
        // Corruption
        glitchColor = corruptionGlitch(uv, time, u_intensity);
    } else if (glitchTypeInt == 3) {
        // Tearing
        glitchColor = tearingGlitch(uv, time, u_intensity);
    } else {
        // Wave
        glitchColor = waveGlitch(uv, time, u_intensity);
    }
    
    // Apply touch interaction
    glitchColor = applyTouchGlitch(glitchColor, uv, u_touch, time, u_intensity);
    
    // Ensure valid range
    glitchColor = clamp(glitchColor, 0.0, 1.0);
    
    fragColor = vec4(glitchColor, 1.0);
}