// Get a reference to the canvas
const canvas = document.getElementById("myCanvas");
var gl = canvas.getContext("webgl2");


// Webgl does not support compute shader unless you do some funky things, so in the frag it goes
// Vertex shader program
var vsSource;
var fsSource;


// Fetch the vertex shader source from a file
await fetch('vert.glsl')
  .then(response => response.text())
  .then(vertexShaderSource => {
    // Assign the shader source to the vsSource variable
    vsSource = vertexShaderSource;

    // Now you can use vsSource as your vertex shader source code
    console.log(vsSource);
  })
  .catch(error => {
    console.error('Error fetching vertex shader source:', error);
  });

// Fetch the vertex shader source from a file
await fetch('frag.glsl')
  .then(response => response.text())
  .then(vertexShaderSource => {
    // Assign the shader source to the vsSource variable
    fsSource = vertexShaderSource;

    // Now you can use vsSource as your vertex shader source code
    console.log(fsSource);
  })
  .catch(error => {
    console.error('Error fetching vertex shader source:', error);
  });





// Compile shader program
function compileShader(gl, source, type) {
    const shader = gl.createShader(type);
    gl.shaderSource(shader, source);
    gl.compileShader(shader);
    if (!gl.getShaderParameter(shader, gl.COMPILE_STATUS)) {
    console.error('An error occurred compiling the shaders: ' + gl.getShaderInfoLog(shader));
    gl.deleteShader(shader);
    return null;
    }
    return shader;
}

// Create shader programs
const vertexShader = compileShader(gl, vsSource, gl.VERTEX_SHADER);
const fragmentShader = compileShader(gl, fsSource, gl.FRAGMENT_SHADER);

const shaderProgram = gl.createProgram();
gl.attachShader(shaderProgram, vertexShader);
gl.attachShader(shaderProgram, fragmentShader);
gl.linkProgram(shaderProgram);

if (!gl.getProgramParameter(shaderProgram, gl.LINK_STATUS)) {
    console.error('Unable to initialize the shader program: ' + gl.getProgramInfoLog(shaderProgram));
}

gl.useProgram(shaderProgram);

// Set up the buffer to render a square
const positionBuffer = gl.createBuffer();
gl.bindBuffer(gl.ARRAY_BUFFER, positionBuffer);

const positions = [
    -1.0,  1.0,
    1.0,  1.0,
    -1.0, -1.0,
    1.0, -1.0,
];
gl.bufferData(gl.ARRAY_BUFFER, new Float32Array(positions), gl.STATIC_DRAW);

const positionAttributeLocation = gl.getAttribLocation(shaderProgram, 'aVertexPosition');
gl.enableVertexAttribArray(positionAttributeLocation);
gl.vertexAttribPointer(positionAttributeLocation, 2, gl.FLOAT, false, 0, 0);







function UpdateGL1float (name, value ){
  var variable = gl.getUniformLocation(shaderProgram, name);
  gl.uniform1f(variable, value)

}

function UpdateGL2float (name, value1, value2 ){
  var variable = gl.getUniformLocation(shaderProgram, name);
  gl.uniform2f(variable, value1, value2);

}

function UpdateGL3float (name, value1, value2, value3 ){
  var variable = gl.getUniformLocation(shaderProgram, name);
  gl.uniform3f(variable, value1, value2, value3);

}

function UpdateGL1int(name, value) {
  var variable = gl.getUniformLocation(shaderProgram, name);
  gl.uniform1i(variable, value);
}


// Define the colors array
// Colors available for rendering
function generateColors_Good() {
  const numColors = 16; // Number of colors
  const numShades = 16; // Number of shades for each color
  const colors = [];

  // Define base colors
  const baseColors = [
      { r: 1.0, g: 0.0, b: 0.0 },  // Red
      { r: 1.0, g: 0.5, b: 0.0 },  // Orange
      { r: 1.0, g: 1.0, b: 0.0 },  // Yellow
      { r: 0.5, g: 1.0, b: 0.0 },  // Lime
      { r: 0.0, g: 1.0, b: 0.0 },  // Green
      { r: 0.0, g: 1.0, b: 0.5 },  // Turquoise
      { r: 0.0, g: 1.0, b: 1.0 },  // Cyan
      { r: 0.0, g: 0.5, b: 1.0 },  // Azure
      { r: 0.0, g: 0.0, b: 1.0 },  // Blue
      { r: 0.5, g: 0.0, b: 1.0 },  // Indigo
      { r: 1.0, g: 0.0, b: 1.0 },  // Violet
      { r: 1.0, g: 0.0, b: 0.5 },  // Magenta
      { r: 0.5, g: 0.0, b: 0.0 },  // Maroon
      { r: 0.5, g: 0.25, b: 0.0 }, // Brown
      { r: 0.25, g: 0.25, b: 0.25 }, // Gray
      { r: 1.0, g: 1.0, b: 1.0 }   // White
  ];

  // Generate intermediate colors with different shades
  for (let i = 0; i < numColors; i++) {
      const baseColor = baseColors[i];
      for (let j = 0; j < numShades; j++) {
          const luminosity = j / (numShades - 1)*1.5; // Adjust luminosity from 0 to 1
          const r = baseColor.r * luminosity;
          const g = baseColor.g * luminosity;
          const b = baseColor.b * luminosity;
          colors.push({ r, g, b });
      }
  }

  return colors;
}






// Generate colors
// const colors = generateColors_Good();
const colors = generateColors_Good();


// Set uniform values in WebGL
function setUniformColors(gl, program) {
  const colorsLocation = gl.getUniformLocation(program, "colors");
  const colorsArray = colors.flatMap(color => [color.r, color.g, color.b]);
  gl.uniform3fv(colorsLocation, colorsArray);
}

setUniformColors(gl, shaderProgram);




// set volumetric data
let volume = [];
for (let i = 0; i < 14 * 14 * 14; i++) {
  // volume.push(Math.floor(Math.random() * 255)); // Generate a random number between 0 and 256
  volume.push(Math.floor(i % 255));
}
let rotatedVolume = [];
for (let z = 0; z < 14; z++) {
    for (let y = 0; y < 14; y++) {
        for (let x = 0; x < 14; x++) {
            let rotatedX = z;
            let rotatedY = 14 - x - 1;
            let rotatedZ = y;
            let index = x + y * 14 + z * 14 * 14;
            let rotatedIndex = rotatedX + rotatedY * 14 + rotatedZ * 14 * 14;
            rotatedVolume[rotatedIndex] = volume[index];
        }
    }
}





// adds a cube to the volume
// volume[14*7+14*7+14*7] = 100; // mid
// volume[14*0+14*0+14*0] = 100; //bot
// volume[14*0+14*1+14*0] = 10; //bot
// volume[14*0+14*0+14*1] = 10; //bot
// volume[14*0+14*1+14*1] = 10; //bot

// volume[14*1+14*0+14*0] = 10; //top
// volume[14*1+14*1+14*0] = 10; //top
// volume[14*1+14*0+14*1] = 10; //top
// volume[14*1+14*1+14*1] = 10; //top


const volumeLocation = gl.getUniformLocation(shaderProgram, "volume");
gl.uniform1iv(volumeLocation, rotatedVolume);

console.log(volume);



// ======= CAMERA STUFF ========
import { CamHandleKeyDown, CamHandleKeyUp, updateCamera } from './camera.js';
// Add event listener for keydown events for camera movements
document.addEventListener('keydown', (event) => CamHandleKeyDown(event, camera), false);
document.addEventListener('keyup', CamHandleKeyUp, false);
var camera = {
  position : {
    x: -10,
    y: 7,
    z: 7,
  },

  // position : {
  //   x: 0,
  //   y: 0,
  //   z: -10,
  // },

  rotation : {
    x: 0,
    y: 0,
    z: 0
  },

  rotation_polar : {
    x: 3.14/2+3.14,
    y: 0
  }
}






function render() {

  UpdateGL1float('col', 0.3 );

  UpdateGL3float('camPosition', camera.position.x, camera.position.y, camera.position.z);
  UpdateGL3float('camRotation', camera.rotation_polar.x, camera.rotation_polar.y, 0);

  UpdateGL1float('FOV', 100 );
  
  
  gl.clearColor(0.0, 0.0, 0.0, 1.0);
  gl.clear(gl.COLOR_BUFFER_BIT);
  gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
  return;
  

  //requestAnimationFrame(render);
}

// it's here for now
function cameraLoop() {
  var status = updateCamera(camera);

  if(status){
    // update the camera position // USELESSS here, it's in render()
    // UpdateGL3float('camPosition', camera.position.x, camera.position.y, camera.position.z);
    console.log("position", camera.position);
    console.log("rotation", camera.rotation_polar);
    render()
  }

  requestAnimationFrame(cameraLoop);
}
cameraLoop();
document.addEventListener('keydown', (event) => {if(event.key == "*"){render();console.log("rendering")}}, false);



// display mode switch
let displayMode = 0;
document.addEventListener('keydown', (event) => {if(event.key == "$"){ displayMode = (displayMode+1)%2; UpdateGL1int('displayMode', displayMode ); console.log(displayMode);render();}}, false);



// sets canva size
// Set the screen size and pass it to the shader
// canvas.width = window.innerWidth;
// canvas.height = window.innerHeight;
UpdateGL2float('uResolution', canvas.width, canvas.height);

console.log(canvas.width, canvas.height);

// window.addEventListener('resize', () => {
//   canvas.width = window.innerWidth;
//   canvas.height = window.innerHeight;
//   UpdateGL2float('uResolution', canvas.width, canvas.height);
//   console.log(canvas.width, canvas.height);
//   // requestAnimationFrame(render);
//   render();
// });

// requestAnimationFrame(render);
render();