
#version 450
#extension GL_ARB_separate_shader_objects : enable

layout(set = 1, binding = 0) uniform ModelBufferObject {
    mat4 model;
};

// TODO: Declare vertex shader inputs and outputs
/* From Blades.h
    // Position and direction
    glm::vec4 v0;
    // Bezier point and height
    glm::vec4 v1;
    // Physical model guide and width
    glm::vec4 v2;
    // Up vector and stiffness coefficient
    glm::vec4 up;
*/
layout(location = 0) in vec4 v0;
layout(location = 1) in vec4 v1;
layout(location = 2) in vec4 v2;
layout(location = 3) in vec4 up;

layout (location = 0) out vec4 ov0;
layout (location = 1) out vec4 ov1;
layout (location = 2) out vec4 ov2;
layout (location = 3) out vec4 ov3;

void main() {
	// TODO: Write gl_Position and any other shader outputs
    vec4 v0Trans = model * vec4(v0.xyz, 1.0);
    vec4 v1Trans = model * vec4(v1.xyz, 1.0);
    vec4 v2Trans = model * vec4(v2.xyz, 1.0);
    vec4 upTrans = model * vec4(up.xyz, 0.0);

    ov0 = vec4(v0Trans.xyz / v0Trans.w, v0.w);
    ov1 = vec4(v1Trans.xyz / v1Trans.w, v1.w);
    ov2 = vec4(v2Trans.xyz / v2Trans.w, v2.w);
    ov3 = vec4(upTrans.xyz / upTrans.w, up.w);
}
