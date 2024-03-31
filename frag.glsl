
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
// VERY BAD OPTIMIZATION
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

float mod_f(float x, float y) {
    return x - y * floor(x / y);
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


    // ===========================================================================================================DEBUG TEST DIRECTION
    // return vec3(0, 1, 0);

    return direction;
}




int getVolumeIndex(int x, int y, int z) {
    return x + y * VOXEL_X + z * VOXEL_X * VOXEL_Y;
}



// OK SO THAT GETS THE COLOR WITHOUT UGLY IF ELSES
// VERY BAD OPTIMIZATION
int getVoxel(int voxelIndex) {
    const int numVoxels = VOXEL_X*VOXEL_Y*VOXEL_Z; // Number of colors
    const int defaultVoxel = -1; // return -1 if there's no voxel here

    // Loop through the colors array to find the matching index
    for (int i = 0; i < numVoxels; i++) {
        if (i == voxelIndex) {
            return volume[i];
        }
    }

    // Return default color if index is out of bounds
    return defaultVoxel;
}




#define MAX_STEP 20

int doTheMarchingThing(void) {
    // Says it all, do the marching thingy here
    // Might wanna return the distance value to implement some kind of "fog"
    
    // Background color, if no hit is reached, don't do anything
    int index = 0;
    
    int step_counter = 0;

    vec3 rayDirection = GetRayDirection();

    // increments
    vec3 increments = vec3(0,0,0);


    // float dxdy = rayDirection.x/rayDirection.y;
    // float dxdz = rayDirection.x/rayDirection.z;

    // float dydz = rayDirection.y/rayDirection.z;
    // float dydx = rayDirection.y/rayDirection.x;

    // float dzdx = rayDirection.z/rayDirection.x;
    // float dzdy = rayDirection.z/rayDirection.y;



    vec3 currentPosition = camPosition;

    // Until we hit something or too many steps:
    for (int step_counter = 0; step_counter < MAX_STEP; step_counter++) {
        // do one step using DDA
            // take the ray position, find interesction on x,y,z with the ray direction
            // Find the smallest between dx, dy and dz
            // advance by that one

        // Did we hit something?
            // if yes, stop loop and set index to color of the cube


        // returns position to a unit cube
        vec3 unitCube = vec3(
            mod_f(currentPosition.x, 1.0),
            mod_f(currentPosition.y, 1.0),
            mod_f(currentPosition.z, 1.0)
        );

        // x = -b/a where b = unitCube coordinates, a = correct one from ray direction

        // on x
        float crossX = -unitCube.x/rayDirection.x;

        // on y
        float crossY = -unitCube.y/rayDirection.y;

        // on z
        float crossZ = -unitCube.z/rayDirection.z;


        // get the minimum increment 
        // float minCross = min(crossX, min(crossY, crossZ));


        vec3 checkDirection = vec3(0, 0, 0);

        // if smallest is on X
        if (crossX<crossY && crossX<crossZ) {
            vec3 increment = vec3(
                crossX,
                crossX*rayDirection.y,
                crossX*rayDirection.z
            );

            checkDirection = sign(crossX)*vec3(0.5, 0, 0);
            return 30;
            
        } 

        // if smallest is on Y
        if (crossY<crossX && crossY<crossZ) {
            vec3 increment = vec3(
                crossY*rayDirection.x,
                crossY,
                crossY*rayDirection.z
            );

            checkDirection = sign(crossY)*vec3(0, 0.5, 0);
            return 30;
            
        }


        // if smallest is on Z
        if (crossY<crossX && crossY<crossZ) {
            vec3 increment = vec3(
                crossZ*rayDirection.x,
                crossZ*rayDirection.y,
                crossZ
            );

            checkDirection = sign(crossZ)*vec3(0, 0, 0.5);
            return 30;
            
        }



        // increment the current position by the compute increment
        currentPosition += increments;


        // collision check
        vec3 checkPointPosition = currentPosition+checkDirection;
        int voxel = getVoxel(getVolumeIndex(
            int(floor(checkPointPosition.x)),
            int(floor(checkPointPosition.y)),
            int(floor(checkPointPosition.z))
        ));

        // if -1 then nothing in that cube
        if(voxel >= 0) {
            return voxel;
            return 200;
        }

    

    }




    return index;
}








void main(void) {

    ivec2 pixelPosition = ivec2(gl_FragCoord.xy); // Get the pixel position
    // int color_index = int(mod(float(pixelPosition.x + pixelPosition.y) , float(COLOR_SIZE))); // Calculate color_index using custom modulo function
    // int color_index = int(mod(float(pixelPosition.y) / float(16), float(16))) * 16 + int(mod(float(pixelPosition.x) / float(16), float(16)));

    // debug
    gl_FragColor = vec4(GetRayDirection(), 1.0);
    return;



    int color_index = doTheMarchingThing();



    // Use dynamic indexing to access color using the variable index
    vec3 final = getColorFromBinary(color_index);

    // Use final color as needed
    // For example, set fragment color
    gl_FragColor = vec4(final, 1.0);

}