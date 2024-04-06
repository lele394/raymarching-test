
precision mediump float;

#define INFINITY +(1.0/0.0);
#define PI 3.1415926535897932384626433832795

#define COLOR_SIZE 256
uniform vec3 colors[COLOR_SIZE];

uniform int displayMode;

#define MAX_STEP 20


#define VOXEL_X 16 // Voxel space will be cubes of 14
#define VOXEL_Y 16 // Voxel space will be cubes of 14
#define VOXEL_Z 16 // Voxel space will be cubes of 14
uniform int volume[VOXEL_X*VOXEL_Y*VOXEL_Z];

uniform vec2 uResolution;
uniform float col;

uniform float FOV;

uniform vec3 camPosition;
uniform vec3 camRotation;


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



// Define rotation matrices
mat3 rotateX(float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return mat3(
        1.0, 0.0, 0.0,
        0.0, c, -s,
        0.0, s, c
    );
}

mat3 rotateY(float angle) {
    float c = cos(angle);
    float s = sin(angle);
    return mat3(
        c, 0.0, s,
        0.0, 1.0, 0.0,
        -s, 0.0, c
    );
}

vec3 GetRayDirection(void)
{

    // camera angles conversion
    float cam_theta = camRotation.x;
    float cam_phi = camRotation.y;


    // Define camera angles
    // float cam_phi = camRotation.y;
    // float cam_theta = 0.0;
    vec3 direction = vec3(
        sin(cam_phi)*cos(cam_theta),
        sin(cam_phi)*sin(cam_theta),
        cos(cam_phi)
    );
    
    direction = rotateY(cam_theta ) * rotateX(cam_phi ) * direction;
    // Ray direction of the camera ^


    vec3 rayDirection = direction;

    // Compute ray direction for each pixel
    vec2 uv = gl_FragCoord.xy / uResolution.xy;
    vec3 right = normalize(cross(vec3(0.0, 1.0, 0.0), direction)); // Compute the right vector perpendicular to the view direction
    vec3 up = normalize(cross(direction, right)); // Compute the up vector perpendicular to both view and right vector

    // Convert pixel coordinates to screen coordinates
    vec2 screenCoordinates = (uv - 0.5) * 2.0;
    vec3 pixelDirection = normalize(direction + screenCoordinates.x * right + screenCoordinates.y * up);

    











    return pixelDirection;
    // return direction;

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
int getVoxel(const int voxelIndex) {
    const int numVoxels = VOXEL_X*VOXEL_Y*VOXEL_Z; // Number of colors
    const int defaultVoxel = -1; // return -1 if there's no voxel here

    // if value is found to be out of bound already
    if (voxelIndex == -1 || voxelIndex>numVoxels){
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

















int steps = 0;
float dist;
int doTheMarchingThing(void) {
    // Says it all, do the marching thingy here
    // Might wanna return the distance value to implement some kind of "fog"
    
    // Background color, if no hit is reached, don't do anything
    int return_if_no_hit = 0;

    // initial values
    vec3 rayDirection = GetRayDirection();
    vec3 increment;
    vec3 currentPosition = camPosition;








    // Until we hit something or too many steps:
    for (int step_counter = 0; step_counter < MAX_STEP; step_counter++) {
        steps += 1;
        // do one step 
            // take the ray position, find interesction on x,y,z with the ray direction
            // Find the smallest between dx, dy and dz
            // advance by that one

        // Did we hit something?
            // if yes, stop loop and set index to color of the cube

        // returns position to a unit cube
        // vec3 posInUnitCube = vec3(
        //     mod_f(currentPosition.x, 1.0),
        //     mod_f(currentPosition.y, 1.0),
        //     mod_f(currentPosition.z, 1.0)
        // );


        vec3 posInUnitCube = vec3(
            -sign(currentPosition.x) * mod_f(currentPosition.x, 1.0),
            -sign(currentPosition.y) * mod_f(currentPosition.y, 1.0),
            -sign(currentPosition.z) * mod_f(currentPosition.z, 1.0)
        );





        // check where exit coordinates are
        // on x
        float crossX;
        if (rayDirection.x > 0.0) { // if positive, check intersection on 0 
            crossX = 1.0 - posInUnitCube.x;
        } else {
            crossX = -1.0 + posInUnitCube.x;
        }

        float crossY;
        if (rayDirection.y > 0.0) { // if positive, check intersection on 0 
            crossY = 1.0 - posInUnitCube.y;
        } else {
            crossY = -1.0 + posInUnitCube.y;
        }

        float crossZ;
        if (rayDirection.z > 0.0) { // if positive, check intersection on 0 
            crossZ = 1.0 - posInUnitCube.z;
        } else {
            crossZ = -1.0 + posInUnitCube.z;
        }


        // float rappX = crossX/rayDirection.x;
        // float rappY = crossY/rayDirection.y;
        // float rappZ = crossZ/rayDirection.z;

        float rappX = rayDirection.x != 0.0 ? crossX / rayDirection.x : 1e6;
        float rappY = rayDirection.y != 0.0 ? crossY / rayDirection.y : 1e6;
        float rappZ = rayDirection.z != 0.0 ? crossZ / rayDirection.z : 1e6;



        vec3 increment = rayDirection * min(rappX, min(rappY, rappZ)); // + vec3(1e-6);


        vec3 checkDirection;
        if(rappX<rappY && rappX<rappZ){ checkDirection = vec3(0.5, 0, 0); } // 100
        if(rappY<rappX && rappY<rappZ){ checkDirection = vec3(0, 0.5, 0); } // 010
        if(rappZ<rappX && rappZ<rappY){ checkDirection = vec3(0, 0, 0.5); } // 001


        /*

        issue when :  going -z, -y, -x

        */


        // ============================= wrong until here ===============================





        //overrides everything to use tiny steps
        // increment = rayDirection*0.1;
        // checkDirection = vec3(0, 0.5, 0);
        // vec3 checkDirection = vec3(0, 0.5, 0);
        // currentPosition += ray;

        vec3 checkPointPosition = currentPosition + 0.1*checkDirection;
        currentPosition += increment;



        // checkDirection = 0.000000000001*rayDirection;

        // collision check
        // vec3 checkPointPosition = currentPosition+checkDirection;
        int voxel = getVoxel(getVolumeIndex(
            int(floor(checkPointPosition.x)),
            int(floor(checkPointPosition.y)),
            int(floor(checkPointPosition.z))
        ));

        // if -1 then nothing in that cube
        // voxel = getVoxel(getVolumeIndex(10,10,10));
        if(voxel >= 0) {
            dist = length(currentPosition-camPosition);
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



    if (displayMode == 0) {
        // i'll modify the for loop while keeping the nested thingy cuz glsl mad >:(
        vec3 finalColor = getColorFromBinary(color_index);
        // Use final color as needed
        gl_FragColor = vec4(finalColor, 1.0);
    }
    else if (displayMode == 1) {
        // outputs the number of steps, whiter = more
        float step_perc = float(steps) / float(MAX_STEP);
        gl_FragColor = vec4(step_perc, step_perc, step_perc, 1.0);
    }
    else if (displayMode == 2) {
        // outputs the distance, further = whiter
        float dist_val = 1.0 - float(dist) / float(MAX_STEP);
        gl_FragColor = vec4(dist_val, dist_val, dist_val, 1.0);
    }


}