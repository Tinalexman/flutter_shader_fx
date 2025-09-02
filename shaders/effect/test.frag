#version 320 es
precision highp float;

uniform vec2 u_resolution; // pass in physical pixels
out vec4 fragColor;

void main() {
    vec2 uv = gl_FragCoord.xy / u_resolution; // normalized 0..1

    // Background gradient
    fragColor = vec4(uv.x, uv.y, 0.5, 1.0);

    // Red border (5px thick)
    if (gl_FragCoord.x < 5.0 || gl_FragCoord.x > u_resolution.x - 5.0 ||
        gl_FragCoord.y < 5.0 || gl_FragCoord.y > u_resolution.y - 5.0) {
        fragColor = vec4(1.0, 0.0, 0.0, 1.0);
    }

    // Green crosshair (3px thick at center)
    vec2 center = u_resolution * 0.5;
    if (abs(gl_FragCoord.x - center.x) < 3.0 || abs(gl_FragCoord.y - center.y) < 3.0) {
        fragColor = vec4(0.0, 1.0, 0.0, 1.0);
    }
}
