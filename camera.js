// Define movement speed and rotation speed
const movementSpeed = 0.1;
const rotationSpeed = 0.02;











let keysPressed = {}; // Object to keep track of pressed keys

export function CamHandleKeyDown(event) {
    keysPressed[event.key] = true;
}

export function CamHandleKeyUp(event) {
    delete keysPressed[event.key];
}

export function updateCamera(camera) {

    var status = false;
    const keyboard =  {
        up : "r",
        down : "f",
        right : "d",
        left : "q",
        front : "z",
        back : "s",
        r_right :"e",
        r_left : "a",
        r_up : "t",
        r_down : "g"
    };


    if (keysPressed[keyboard.r_left]) {
        // Rotate camera left
        camera.rotation_polar.x += rotationSpeed;
        status = true;
    }
    if (keysPressed[keyboard.r_right]) {
        // Rotate camera right
        camera.rotation_polar.x -= rotationSpeed;
        status = true;
    }


    // up dwon rotations
    if (keysPressed[keyboard.r_up]) {
        // Rotate camera left
        camera.rotation_polar.y += rotationSpeed;
        status = true;
    }
    if (keysPressed[keyboard.r_down]) {
        // Rotate camera right
        camera.rotation_polar.y -= rotationSpeed;
        status = true;
    }




    
    if (keysPressed[keyboard.front]) {
        // Go forward
        camera.position.x -= Math.sin(camera.rotation_polar.x) * movementSpeed;
        camera.position.z += Math.cos(camera.rotation_polar.x) * movementSpeed;
        status = true;
    }
    if (keysPressed[keyboard.back]) {
        // Go backward
        camera.position.x += Math.sin(camera.rotation_polar.x) * movementSpeed;
        camera.position.z -= Math.cos(camera.rotation_polar.x) * movementSpeed;
        status = true;
    }
    if (keysPressed[keyboard.left]) {
        // Go right
        camera.position.x += Math.sin(camera.rotation_polar.x - Math.PI / 2) * movementSpeed;
        camera.position.z -= Math.cos(camera.rotation_polar.x - Math.PI / 2) * movementSpeed;
        status = true;
    }
    if (keysPressed[keyboard.right]) {
        // Go left
        camera.position.x += Math.sin(camera.rotation_polar.x + Math.PI / 2) * movementSpeed;
        camera.position.z -= Math.cos(camera.rotation_polar.x + Math.PI / 2) * movementSpeed;
        status = true;
    }
    

    if (keysPressed[keyboard.up]) {
        // Go up
        camera.position.y += movementSpeed;
        status = true;
    }
    if (keysPressed[keyboard.down]) {
        // Go down
        camera.position.y -= movementSpeed;
        status = true;
    }

    return status;

}