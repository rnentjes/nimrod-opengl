#version 120

uniform float u_angle;
uniform float u_scale;

attribute vec4 a_position;
attribute vec3 a_color;

varying vec3 v_color;
varying vec2 v_position;

mat4 translate(float x, float y, float z) {
    return mat4(
        vec4(1.0, 0.0, 0.0, 0.0),
        vec4(0.0, 1.0, 0.0, 0.0),
        vec4(0.0, 0.0, 1.0, 0.0),
        vec4(x,   y,   z,   1.0)
    );
}

mat4 scale(float scale) {
    return mat4(
        vec4(scale, 0.0,   0.0,   0.0),
        vec4(0.0,   scale, 0.0,   0.0),
        vec4(0.0,   0.0,   scale, 0.0),
        vec4(0.0,   0.0,   0.0,   1.0)
    );
}

mat4 rotate(float angle) {
    return mat4(
        vec4(cos(angle),   sin(angle),  0.0,  0.0),
        vec4(-sin(angle),  cos(angle),  0.0,  0.0),
        vec4(0.0,          0.0,         1.0,  0.0),
        vec4(0.0,          0.0,         0.0,  1.0)
    );
}

void main() {
    mat4 mvp = mat4(1);
    mat4 scale = scale(u_scale);
    mat4 rotate = rotate(u_angle);
    
    gl_Position = mvp * scale * rotate * a_position;
    
    v_color = a_color;
    v_position = a_position.xy;
}
