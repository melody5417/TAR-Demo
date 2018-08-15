precision mediump float;

varying vec2 v_texcoord;

uniform sampler2D image0;

void main()
{
    // bgra
    // rgba
    gl_FragColor = texture2D(image0, v_texcoord);
}
