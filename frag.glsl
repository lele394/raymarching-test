
precision mediump float;

#define COLOR_SIZE 256
uniform vec3 colors[COLOR_SIZE];


#define VOXEL_X 14 // Voxel space will be cubes of 14
#define VOXEL_Y 14 // Voxel space will be cubes of 14
#define VOXEL_Z 14 // Voxel space will be cubes of 14
uniform int volume[VOXEL_X*VOXEL_Y*VOXEL_Z];

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
int mod_int(int x, int y) {
    int result = x - (x / y) * y;
    if (result < 0) {
        result += y;
    }
    return result;
}





vec3 GetRayDirection(void)
{
    // Calculate aspect ratio
    float aspectRatio = uResolution.x / uResolution.y;

    // Calculate normalized device coordinates (NDC) of the pixel
    vec2 ndc = gl_FragCoord.xy / uResolution;

    // Calculate the half FOV in radians
    float fovRadians = radians(FOV);
    float halfFovRadians = fovRadians / 2.0;

    // Calculate the coordinates on the near plane in camera space
    float nearPlaneX = tan(halfFovRadians) * (2.0 * ndc.x - 1.0) * aspectRatio;
    float nearPlaneY = tan(halfFovRadians) * (1.0 - 2.0 * ndc.y);

    // Construct the direction vector in camera space
    vec3 direction = normalize(vec3(nearPlaneX, nearPlaneY, -1.0));

    return direction;
}




int getVolumeIndex(int x, int y, int z) {
    return x + y * VOXEL_X + z * VOXEL_X * VOXEL_Y;
}



// OK SO THAT GETS THE COLOR WITHOUT UGLY IF ELSES
int getVoxel(int voxelIndex) {
    const int numVoxels = VOXEL_X*VOXEL_Y*VOXEL_Z; // Number of colors
    const int defaultVoxel = 0; // Default color if index is out of bounds

    // Loop through the colors array to find the matching index
    for (int i = 0; i < numVoxels; i++) {
        if (i == voxelIndex) {
            return volume[i];
        }
    }

    // Return default color if index is out of bounds
    return defaultVoxel;
}




#define MAX_STEP 30

int doTheMarchingThing(void) {
    // Says it all, do the marching thingy here
    // Might wanna return the distance value to implement some kind of "fog"
    
    // Background color, if no hit is reached, don't do anything
    int index = 200;
    
    int step_counter = 0;

    bool hit = false;

    vec3 rayDirection = GetRayDirection();
    // vec3 rayPosition = camPosition;

    // https://www.geeksforgeeks.org/dda-line-generation-algorithm-computer-graphics/

    // differentials
    vec3 endPoint = camPosition + rayDirection * float(MAX_STEP);


    // steps
    float steps = max(abs(endPoint.x), max(abs(endPoint.y), abs(endPoint.z)));

    // increments
    vec3 increments = endPoint / steps;





    vec3 currentPosition = camPosition;

    // Until we hit something or too many steps:
    for (int step_counter = 0; step_counter < MAX_STEP; step_counter++) {
        // do one step using DDA
            // take the ray position, find interesction on x,y,z with the ray direction
            // Find the smallest between dx, dy and dz
            // advance by that one

        // Did we hit something?
            // if yes, stop loop and set index to color of the cube

        currentPosition += increments;

        // collision check
        // check the voxel param
    
        int voxelID = getVoxel(getVolumeIndex(int(currentPosition.x), int(currentPosition.y), int(currentPosition.z)));



        if (voxelID != 0) {
            return voxelID;
        } 
    

    }




    return index;
}








void main(void) {

    ivec2 pixelPosition = ivec2(gl_FragCoord.xy); // Get the pixel position
    // int color_index = int(mod(float(pixelPosition.x + pixelPosition.y) , float(COLOR_SIZE))); // Calculate color_index using custom modulo function
    // int color_index = int(mod(float(pixelPosition.y) / float(16), float(16))) * 16 + int(mod(float(pixelPosition.x) / float(16), float(16)));


    int color_index = doTheMarchingThing();



    // Use dynamic indexing to access color using the variable index
    vec3 final = getColorFromBinary(color_index);

    // Use final color as needed
    // For example, set fragment color
    gl_FragColor = vec4(final, 1.0);

}