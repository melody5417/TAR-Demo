attribute vec4 position;
attribute vec3 color;
attribute vec2 texcoord;

//uniform mat4 u_Matrix;
//uniform mat4 projectionMatrix;
//uniform mat4 cameraMatrix;
//uniform mat4 modelMatrix;

varying vec2 v_texcoord;

void main()
{
    gl_Position = position;
//    gl_Position = u_Matrix * position;
    v_texcoord = texcoord;


//    mat4 mvp = projectionMatrix * cameraMatrix * modelMatrix;
//    gl_Position = mvp * position;
}
