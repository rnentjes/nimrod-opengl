#version 120

uniform mat4  u_mvp;
uniform vec3  u_position;
uniform vec3  u_rotation;
uniform float u_scale;

attribute vec4 a_position;
attribute vec3 a_color;

varying vec3 v_color;

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

mat4 rotateX(float angle) {
    return mat4(
        vec4(1.0,          0.0,         0.0,         0.0),
        vec4(0.0,          cos(angle),  sin(angle),  0.0),
        vec4(0.0,          -sin(angle), cos(angle),  0.0),
        vec4(0.0,          0.0,         0.0,         1.0)
    );
}

mat4 rotateY(float angle) {
    return mat4(
        vec4(cos(angle),   0.0,    -sin(angle), 0.0),
        vec4(0.0,          1.0,    0.0,         0.0),
        vec4(sin(angle),   0.0,    cos(angle),  0.0),
        vec4(0.0,          0.0,    0.0,         1.0)
    );
}

mat4 rotateZ(float angle) {
    return mat4(
        vec4(cos(angle),   sin(angle),  0.0,  0.0),
        vec4(-sin(angle),  cos(angle),  0.0,  0.0),
        vec4(0.0,          0.0,         1.0,  0.0),
        vec4(0.0,          0.0,         0.0,  1.0)
    );
}

void main() {
    mat4 scale = scale(u_scale);
    mat4 rotate = rotateX(u_rotation.x) * rotateY(u_rotation.y) * rotateZ(u_rotation.z);
    mat4 translate = translate(u_position.x, u_position.y, u_position.z);

    //gl_Position = translate * a_position;
    //gl_Position = u_mvp * translate * a_position;
    //gl_Position = translate * scale * rotate * a_position;
    gl_Position = u_mvp * translate * scale * rotate * a_position;
    //gl_Position = translate * scale * rotate * a_position;
    mat4 test = mat4(1);
    
    gl_Position = u_mvp * translate * a_position;

    v_color = a_color;
}
