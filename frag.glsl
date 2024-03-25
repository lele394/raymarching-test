
precision mediump float;

#define COLOR_SIZE 256

uniform vec3 colors[COLOR_SIZE];




uniform vec2 uResolution;
uniform float col;

uniform float FOV;

uniform vec3 camPosition;


// OK SO THAT GETS THE COLOR WITHOUT UGLY IF ELSES
vec3 getColorFromBinary(int binaryIndex) {
    const int numColors = COLOR_SIZE; // Number of colors
    const vec3 defaultColor = vec3(0.0); // Default color if index is out of bounds

    // Loop through the colors array to find the matching index
    for (int i = 0; i < numColors; i++) {
        if (i == binaryIndex) {
            return colors[i];
        }
    }

    // Return default color if index is out of bounds
    return defaultColor;
}




// defines modulo
int mod(int x, int y) {
    int result = x - (x / y) * y;
    if (result < 0) {
        result += y;
    }
    return result;
}





void main(void) {

    ivec2 pixelPosition = ivec2(gl_FragCoord.xy); // Get the pixel position
    // int color_index = int(mod(float(pixelPosition.x + pixelPosition.y) , float(COLOR_SIZE))); // Calculate color_index using custom modulo function
    int color_index = int(mod(float(pixelPosition.y) / float(16), float(16))) * 16 + int(mod(float(pixelPosition.x) / float(16), float(16)));

    // Use dynamic indexing to access color using the variable index
    vec3 final = getColorFromBinary(color_index);

    // Use final color as needed
    // For example, set fragment color
    gl_FragColor = vec4(final, 1.0);

}