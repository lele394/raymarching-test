#version 300 es
precision lowp sampler3D; // sampler precision
precision mediump float;



// Input from vertex shader
in vec3 FragColor;

// Output to framebuffer
out vec4 FragColorOutput;




#define INFINITY +(1.0/0.0);
#define PI 3.1415926535897932384626433832795

uniform int displayMode;

#define MAX_STEP 200

#define EMPTY_SPACE vec4(-1.0, -1.0, -1.0, -1.0)
#define BACKGROUND_COLOR vec4(0.0, 0.0, 0.0, 1.0)

uniform sampler3D volume;

uniform vec2 uResolution;
uniform float col;

uniform float FOV;

uniform vec3 camPosition;
uniform vec3 camRotation;


vec4 debug = BACKGROUND_COLOR;



// defines modulo
int mod_int(int x, int y) {
    int result = x - (x / y) * y;
    if (result < 0) {
        result += y;
    }
    return result;
}

float mod_f(float x, float y) {
    float result = x - y * floor(x / y);

    // Adjust result to be in the range [0, y) if y > 0
    // or (y, 0] if y < 0
    if (result < 0.0 && y > 0.0) {
        result += y;
    } else if (result > 0.0 && y < 0.0) {
        result += y;
    }

    return result;
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

    

    // same issue here, I'm pretty sure something is up with the collision
    // // what if i just sweep
    // float phi_sweep = 3.14;
    // float theta_sweep = 3.14;

    // float phi = phi_sweep/uResolution.x * gl_FragCoord.x;
    // float theta = theta_sweep/uResolution.y * gl_FragCoord.y;

    // pixelDirection = vec3(
    //     sin(phi)*cos(theta),
    //     sin(phi)*sin(theta),
    //     cos(phi)
    // );









    return pixelDirection;
    // return direction;

}





vec4 getVoxel(vec3 position) {
    float volumeScale = 100.0;
    vec3 pos = position/volumeScale;

    vec4 status = texture(volume, pos);
    // if value is found to be out of bound already
    if (pos.x < 0.0 || pos.x > 1.0 ||
        pos.y < 0.0 || pos.y > 1.0 ||
        pos.z < 0.0 || pos.z > 1.0) {
        return EMPTY_SPACE;
    }

    if(status.x < 0.0){
        return EMPTY_SPACE;
    } else {
        return status;
    }
}

















int steps = 0;
float dist;
vec4 doTheMarchingThing(void) {
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



        vec3 posInUnitCube = vec3(
            -sign(currentPosition.x) * mod_f(currentPosition.x, 1.0),
            -sign(currentPosition.y) * mod_f(currentPosition.y, 1.0),
            -sign(currentPosition.z) * mod_f(currentPosition.z, 1.0)
        );





        // check where exit coordinates are
        // on x
        float border = 0.5;
        float crossX;
        if (rayDirection.x > 0.0) { // check intersection on 0 
            crossX = border - posInUnitCube.x;
        } else {
            crossX = -border + posInUnitCube.x;
        }

        float crossY;
        if (rayDirection.y > 0.0) { // check intersection on 0 
            crossY = border - posInUnitCube.y;
        } else {
            crossY = -border + posInUnitCube.y;
        }

        float crossZ;
        if (rayDirection.z > 0.0) { // check intersection on 0 
            crossZ = border - posInUnitCube.z;
        } else {
            crossZ = -border + posInUnitCube.z;
        }


        float rappX = rayDirection.x > 1e-6 ? crossX / rayDirection.x : 0.5;
        float rappY = rayDirection.y > 1e-6 ? crossY / rayDirection.y : 0.5;
        float rappZ = rayDirection.z > 1e-6 ? crossZ / rayDirection.z : 0.5;



        vec3 increment = rayDirection * min(rappX, min(rappY, rappZ)); // + vec3(1e-6);
        if(length(increment) <0.000000000001)
        {
            increment = rayDirection*1e-6;
        }



        vec3 checkDirection;
        if(rappX<rappY && rappX<rappZ){ checkDirection = vec3(0, 0, 0)*1e-6; } // 100
        if(rappY<rappX && rappY<rappZ){ checkDirection = vec3(0, 0, 0)*1e-6; } // 010
        if(rappZ<rappX && rappZ<rappY){ checkDirection = vec3(0, 0, 0)*1e-6; } // 001
        /*
        
        */




        // ============================= wrong until here ===============================

        // vec3 checkPointPosition = currentPosition + checkDirection;



        // increment = 0.1 * rayDirection;
        currentPosition += increment;

        // collision check
        vec3 checkPointPosition = currentPosition-(increment/2.0);
        vec4 voxel = getVoxel(checkPointPosition);


        // Take into account floating point noise
        if (abs(voxel.x - EMPTY_SPACE.x) > 0.0 ||
            abs(voxel.y - EMPTY_SPACE.y) > 0.0 ||
            abs(voxel.z - EMPTY_SPACE.z) > 0.0 ||
            abs(voxel.w - EMPTY_SPACE.w) > 0.0) {
            // If any component of voxel is not equal to EMPTY_SPACE, proceed
            dist = length(currentPosition - camPosition);
            return voxel;
        }
    }

    // return 3;
    // return int(currentPosition.y);
    return BACKGROUND_COLOR;
}




float AbsorptionLaw(float dist)
{
    return 1.0;
    // float absorption_rate = 0.17;
    float absorption_rate = 0.07;
    return exp(-dist * absorption_rate);
}







void main(void) {

    // ivec2 pixelPosition = ivec2(gl_FragCoord.xy); // Get the pixel position
    // int color_index = int(mod(float(pixelPosition.x + pixelPosition.y) , float(COLOR_SIZE))); // Calculate color_index using custom modulo function
    // int color_index = int(mod(float(pixelPosition.y) / float(16), float(16))) * 16 + int(mod(float(pixelPosition.x) / float(16), float(16)));




    vec4 finalColor = doTheMarchingThing();

    // Applies fog law based on a exp(-x)
    finalColor = BACKGROUND_COLOR + finalColor *  AbsorptionLaw(dist);
    // finalColor.z = 1.0; // restores transparency to 1




    // escape for debugging so i can output shit as i wish in my marching DDA
    // return;

    // color_index = 100; // teal
    // color_index = 200; // kinda dark red
    // color_index = 50; // dark green



    if (displayMode == 0) {
        // Use final color as needed
        FragColorOutput = finalColor;
        // FragColorOutput = vec4(1.0, 0.5, 0.0, 1.0);
    }
    else if (displayMode == 1) {
        // outputs the number of steps, whiter = more
        float step_perc = float(steps) / float(MAX_STEP);
        FragColorOutput = vec4(step_perc, step_perc, step_perc, 1.0);
    }
    else if (displayMode == 2) {
        // outputs the distance, further = whiter
        float dist_val = 1.0 - float(dist) / float(MAX_STEP);
        FragColorOutput = vec4(dist_val, dist_val, dist_val, 1.0);
    }
    else if (displayMode == 3) {
        FragColorOutput =  debug;
    }


}