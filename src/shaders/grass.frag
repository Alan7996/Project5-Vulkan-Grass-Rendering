#version 450
#extension GL_ARB_separate_shader_objects : enable

layout(set = 0, binding = 0) uniform CameraBufferObject {
    mat4 view;
    mat4 proj;
} camera;

// TODO: Declare fragment shader inputs
layout (location = 0) in vec3 pos;
layout (location = 1) in vec3 nor;
layout (location = 2) in vec2 uv;

layout(location = 0) out vec4 outColor;

const vec3 directionalLight = normalize(vec3(1, -3, 1));

void main() {
    // TODO: Compute fragment color
    vec3 grassAlbedo = vec3(0.0, 1.0, 0.0);

    // Directional lighting
    vec3 grassLit = grassAlbedo * max(0.2, abs(dot(directionalLight, nor)));

    outColor = vec4(grassLit, 1.0);
}
