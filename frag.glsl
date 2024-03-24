
precision mediump float;

uniform vec2 uResolution;
uniform float col;

uniform float FOV;

uniform vec3 camPosition;

void main(void) {
    // Normalize the fragment coordinates to range [0, 1]
    vec2 uv = gl_FragCoord.xy / vec2(1800.0, 600.0); // Adjust the resolution as needed

    // Define colors for different regions
    vec3 color1 = vec3(1.0, 0.0, 0.0); // Red
    vec3 color2 = vec3(0.0, 1.0, 0.0); // Green
    vec3 color3 = vec3(0.0, 0.0, 1.0); // Blue
    vec3 color4 = vec3(1.0, 1.0, 0.0); // Yellow







    // Mix the colors based on fragment coordinates
    vec3 finalColor = mix(mix(color1, color2, uv.x), mix(color3, color4, uv.x), uv.y);

    vec3 final = vec3 (col, col, col);

    // Output the final color
    gl_FragColor = vec4(final, 1.0);
}