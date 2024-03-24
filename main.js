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












var camera = {
  x: 0,
  y: 10,
  z: 0,
}






function render() {


  


  // Set the screen size and pass it to the shader
  UpdateGL2float('uResolution', canvas.width, canvas.height);



  UpdateGL1float('col', 0.3 );

  UpdateGL3float('camPosition', camera.x, camera.y, camera.z);




  UpdateGL1float('FOV', 90 );




  gl.clearColor(0.0, 0.0, 0.0, 1.0);
  gl.clear(gl.COLOR_BUFFER_BIT);
  gl.drawArrays(gl.TRIANGLE_STRIP, 0, 4);
  

  //requestAnimationFrame(render);
}



requestAnimationFrame(render);
