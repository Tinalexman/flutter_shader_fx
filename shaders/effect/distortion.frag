#version 320 es
precision highp float;

uniform vec2 u_resolution;
uniform float u_time;
uniform float u_speed;
uniform float u_intensity;
uniform sampler2D u_image;

out vec4 fragColor;

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution.xy;
    
    // Properly center the effect by accounting for aspect ratio
    vec2 center = (uv - 0.5) * 2.0; // Convert to -1 to 1 range
    
    // Adjust for aspect ratio to make circular effects truly circular
    float aspectRatio = u_resolution.x / u_resolution.y;
    if (aspectRatio > 1.0) {
        center.x *= aspectRatio;
    } else {
        center.y /= aspectRatio;
    }
    
    float dist = length(center);
    float time = u_time * u_speed;
    float angle = atan(center.y, center.x);
    
    // Create organic blob shape boundary - centered and larger
    float blobRadius = 0.8; // Increased base size
    
    // Multi-layered noise for organic blob edges
    float edge1 = sin(angle * 5.0 + time * 1.8) * 0.12;
    float edge2 = sin(angle * 11.0 + time * 1.2) * 0.06;
    float edge3 = sin(angle * 17.0 + time * 2.5) * 0.04;
    float edge4 = sin(angle * 23.0 + time * 0.8) * 0.02; // Extra detail
    
    // Combine edge variations
    float finalRadius = blobRadius + edge1 + edge2 + edge3 + edge4;
    finalRadius *= (0.8 + u_intensity * 0.4); // Better scaling
    
    // Discard pixels outside the blob boundary
    if (dist > finalRadius) {
        discard;
    }
    
    // Apply distortion to remaining pixels
    // Convert back to 0-1 UV space for texture sampling
    vec2 normalizedCenter = center * 0.5; // Scale back down
    
    // Adjust back for aspect ratio
    if (aspectRatio > 1.0) {
        normalizedCenter.x /= aspectRatio;
    } else {
        normalizedCenter.y *= aspectRatio;
    }
    
    vec2 normalizedUV = normalizedCenter + 0.5;
    
    // Swirl distortion
    float swirlAngle = dist * 6.0 + time * 0.8;
    float swirl = sin(swirlAngle) * u_intensity * 0.15;
    
    float cosSwirl = cos(swirl);
    float sinSwirl = sin(swirl);
    vec2 rotated = vec2(
        normalizedCenter.x * cosSwirl - normalizedCenter.y * sinSwirl,
        normalizedCenter.x * sinSwirl + normalizedCenter.y * cosSwirl
    );
    
    vec2 swirlUV = rotated + 0.5;
    
    // Noise distortion
    float noiseX = sin(swirlUV.x * 35.0 + time * 1.1) * sin(swirlUV.y * 28.0 + time * 0.9);
    float noiseY = cos(swirlUV.x * 32.0 + time * 0.7) * cos(swirlUV.y * 26.0 + time * 1.4);
    
    // Apply noise with proper falloff
    float edgeDistance = 1.0 - (dist / finalRadius);
    float noiseFalloff = smoothstep(0.1, 0.6, edgeDistance);
    
    vec2 distortedUV = swirlUV + vec2(noiseX, noiseY) * u_intensity * 0.03 * noiseFalloff;
    
    // Ensure UV coordinates stay in valid range
    distortedUV = clamp(distortedUV, 0.0, 1.0);
    
    // Sample texture
    fragColor = texture(u_image, distortedUV);
}