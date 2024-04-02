
precision mediump float;

#define INFINITY +(1.0/0.0);
#define PI 3.1415926535897932384626433832795

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
    const vec3 defaultColor = vec3(0.0, 1.0, 0.0); // Default color if index is out of bounds

    if (binaryIndex == -1) {
        return defaultColor;
    }


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
    vec3 direction = normalize(vec3(nearPlaneX, nearPlaneY, 0.0));


    direction = normalize(vec3(
        gl_FragCoord.xy/uResolution.xy, 0
    ));


    // ===========================================================================================================DEBUG TEST DIRECTION
    // return vec3(0, 1, 0);
    // float phi_step = 0.5;
    // float theta_step = 0.5;

    float phi_offset = 0.0;
    float theta_offset = 0.0;

    float phi =      (gl_FragCoord.x/uResolution.x *2.0*PI)/2.0+PI;// -uResolution.x/2.0;
    float theta =    (gl_FragCoord.y/uResolution.y *2.0*PI);// -uResolution.y/2.0;



    // phi = mod_f(float(phi), PI);
    // theta = mod_f(float(theta), PI);

    direction = vec3(
        sin(phi + phi_offset)*cos(theta+theta_offset),
        sin(phi + phi_offset)*sin(theta+theta_offset),
        cos(phi + phi_offset)
    );





    return direction;

}




int getVolumeIndex(int x, int y, int z) {
    // return outside of the array is we are out of the voxel box.
    if (x < 0 || x >= VOXEL_X || y < 0 || y >= VOXEL_Y || z < 0 || z >= VOXEL_Z) {
        // Return a value indicating out of bounds
        return -1;
    }
    return x + y * VOXEL_X + z * VOXEL_X * VOXEL_Y;
}



// OK SO THAT GETS THE COLOR WITHOUT UGLY IF ELSES
// VERY BAD OPTIMIZATION
int getVoxel(int voxelIndex) {
    const int numVoxels = VOXEL_X*VOXEL_Y*VOXEL_Z; // Number of colors
    const int defaultVoxel = -1; // return -1 if there's no voxel here

    // if value is found to be out of bound already
    if (voxelIndex == -1){
        return defaultVoxel;
    }


    // Loop through the colors array to find the matching index
    for (int i = 0; i < numVoxels; i++) {
        if (i == voxelIndex) {
            return volume[i];
        }
    }

    // Return default color if index is out of bounds
    // return defaultVoxel;
}




















#define MAX_STEP 500

int doTheMarchingThing(void) {
    // Says it all, do the marching thingy here
    // Might wanna return the distance value to implement some kind of "fog"
    
    // Background color, if no hit is reached, don't do anything
    int return_if_no_hit = 0;
    vec3 rayDirection = GetRayDirection();
    vec3 increment;

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




        // ================= SOMETHING WRONG HERE ======================
        // on x
        float crossX = rayDirection.x != 0.0 ? (sign(rayDirection.x) * (1.0 - abs(unitCube.x))) / abs(rayDirection.x) : INFINITY;

        // on y
        float crossY = rayDirection.y != 0.0 ? (sign(rayDirection.y) * (1.0 - abs(unitCube.y))) / abs(rayDirection.y) : INFINITY;

        // on z
        float crossZ = rayDirection.z != 0.0 ? (sign(rayDirection.z) * (1.0 - abs(unitCube.z))) / abs(rayDirection.z) : INFINITY;











        vec3 checkDirection;

        // If smallest is on X
        if (crossX < crossY && crossX < crossZ) {
            increment = vec3(
                crossX, // Adjust x component
                rayDirection.y * crossX / rayDirection.x, // Adjust y component
                rayDirection.z * crossX / rayDirection.x  // Adjust z component
            );
            checkDirection = sign(rayDirection) * vec3(0.5, 0, 0);
            // checkDirection = sign(rayDirection) * vec3(0, 0.5, 0);
            // checkDirection = sign(rayDirection) * vec3(0, 0, 0.5);
        }

        // If smallest is on Y
        if (crossY < crossX && crossY < crossZ) {
            increment = vec3(
                rayDirection.x * crossY / rayDirection.y, // Adjust x component
                crossY, // Adjust y component
                rayDirection.z * crossY / rayDirection.y  // Adjust z component
            );
            // checkDirection = sign(rayDirection) * vec3(0.5, 0, 0);
            checkDirection = sign(rayDirection) * vec3(0, 0.5, 0);
            // checkDirection = sign(rayDirection) * vec3(0, 0, 0.5);
        }

        // If smallest is on Z
        if (crossZ < crossX && crossZ < crossY) {
            increment = vec3(
                rayDirection.x * crossZ / rayDirection.z, // Adjust x component
                rayDirection.y * crossZ / rayDirection.z, // Adjust y component
                crossZ // Adjust z component
            );
            // checkDirection = sign(rayDirection) * vec3(0.5, 0, 0);
            // checkDirection = sign(rayDirection) * vec3(0, 0.5, 0);
            checkDirection = sign(rayDirection) * vec3(0, 0, 0.5);
        }

        /*
        */








        // ============================= wrong until here ===============================





        //overrides everything to use tiny steps
        increment = rayDirection*0.1;
        checkDirection = vec3(0, 0.5, 0);
        // vec3 checkDirection = vec3(0, 0.5, 0);

        currentPosition += increment;

        // collision check
        vec3 checkPointPosition = currentPosition+checkDirection;
        int voxel = getVoxel(getVolumeIndex(
            int(floor(checkPointPosition.x)),
            int(floor(checkPointPosition.y)),
            int(floor(checkPointPosition.z))
        ));

        // if -1 then nothing in that cube
        // voxel = getVoxel(getVolumeIndex(10,10,10));
        if(voxel >= 0) {
            return voxel;
        }
    }

    // return 3;
    // return int(currentPosition.y);
    return return_if_no_hit;
}








void main(void) {

    // ivec2 pixelPosition = ivec2(gl_FragCoord.xy); // Get the pixel position
    // int color_index = int(mod(float(pixelPosition.x + pixelPosition.y) , float(COLOR_SIZE))); // Calculate color_index using custom modulo function
    // int color_index = int(mod(float(pixelPosition.y) / float(16), float(16))) * 16 + int(mod(float(pixelPosition.x) / float(16), float(16)));




    int color_index = doTheMarchingThing();


    // escape for debugging so i can output shit as i wish in my marching DDA
    // return;

    // color_index = 100; // teal
    // color_index = 200; // kinda dark red
    // color_index = 50; // dark green

    // i'll modify the for loop while keeping the nested thingy cuz glsl mad >:(
    vec3 final = getColorFromBinary(color_index);

    // Use final color as needed
    // For example, set fragment color
    gl_FragColor = vec4(final, 1.0);

}