#version 120

attribute vec4 a_position;
attribute vec3 a_color;

uniform mat4 u_pMatrix;
uniform mat4 u_mMatrix;

varying vec3 v_color;

mat4 translate(float x, float y, float z) {
    return mat4(
        vec4(1.0, 0.0, 0.0, 0.0),
        vec4(0.0, 1.0, 0.0, 0.0),
        vec4(0.0, 0.0, 1.0, 0.0),
        vec4(x,   y,   z,   1.0)
    );
}

void main() {
    gl_Position =  u_pMatrix * u_mMatrix * a_position;
    v_color = a_color;
}
