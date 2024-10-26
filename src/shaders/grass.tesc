#version 450
#extension GL_ARB_separate_shader_objects : enable

layout(vertices = 1) out;

layout(set = 0, binding = 0) uniform CameraBufferObject {
    mat4 view;
    mat4 proj;
} camera;

// TODO: Declare tessellation control shader inputs and outputs
layout (location = 0) in vec4 iv0[];
layout (location = 1) in vec4 iv1[];
layout (location = 2) in vec4 iv2[];
layout (location = 3) in vec4 iv3[];

layout (location = 0) out vec4 ov0[];
layout (location = 1) out vec4 ov1[];
layout (location = 2) out vec4 ov2[];
layout (location = 3) out vec4 ov3[];

void main() {
	// Don't move the origin location of the patch
    gl_out[gl_InvocationID].gl_Position = gl_in[gl_InvocationID].gl_Position;

	// TODO: Write any shader outputs
    ov0[gl_InvocationID] = iv0[gl_InvocationID];
    ov1[gl_InvocationID] = iv1[gl_InvocationID];
    ov2[gl_InvocationID] = iv2[gl_InvocationID];
    ov3[gl_InvocationID] = iv3[gl_InvocationID];

	// TODO: Set level of tesselation
    // Convert point into view space, compute distance from camera (origin)
    float nearPlane = 0.1f;
    float farPlane = 20.0f;
    float dist = length((camera.view * vec4(iv0[gl_InvocationID].xyz, 1.0f)).xyz);
    
    // Linearly interpolate in view space
    float u = clamp((dist - nearPlane) / (farPlane - nearPlane), 0.0, 1.0);
    float closeLevel = 20.0f;
    float farLevel = 4.0f;
    int level = int(closeLevel * (1.0f - u) + farLevel * u);

    gl_TessLevelInner[0] = level;
    gl_TessLevelInner[1] = level;
    gl_TessLevelOuter[0] = level;
    gl_TessLevelOuter[1] = level;
    gl_TessLevelOuter[2] = level;
    gl_TessLevelOuter[3] = level;
}
