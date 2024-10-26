#version 450
#extension GL_ARB_separate_shader_objects : enable

layout(quads, equal_spacing, ccw) in;

layout(set = 0, binding = 0) uniform CameraBufferObject {
    mat4 view;
    mat4 proj;
} camera;

// TODO: Declare tessellation evaluation shader inputs and outputs
layout (location = 0) in vec4 iv0[];
layout (location = 1) in vec4 iv1[];
layout (location = 2) in vec4 iv2[];
layout (location = 3) in vec4 iv3[];

layout (location = 0) out vec3 pos;
layout (location = 1) out vec3 nor;
layout (location = 2) out vec2 uv;

float interpQuad(float u, float v) {
    return u;
}

float interpTri(float u, float v) {
    return u + 0.5f * v - u * v;
}

float interpQuadratic(float u, float v) {
    return u - u * v * v;
}

float interpTriTip(float u, float v, float tau) {
    return 0.5f + (u - 0.5f) * (1.0f - max(v - tau, 0) / (1.0f - tau));
}

void main() {
    float u = gl_TessCoord.x;
    float v = gl_TessCoord.y;

	// TODO: Use u and v to parameterize along the grass blade and output positions for each vertex of the grass blade
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
    // Blade geometry as in Section 6.3
    vec3 v0 = iv0[0].xyz;
    vec3 v1 = iv1[0].xyz;
    vec3 v2 = iv2[0].xyz;

    vec3 a = v0 + v * (v1 - v0);
    vec3 b = v1 + v * (v2 - v1);
    vec3 c = a + v * (b - a);
    
    // direction vector does not have vertical component
    float direction = iv0[0].w;
    vec3 t1 = vec3(cos(direction), 0.0, sin(direction));

    float width = iv2[0].w;
    vec3 c0 = c - width * t1;
    vec3 c1 = c + width * t1;

    vec3 t0 = (b - a) / length(b - a);
    vec3 n = cross(t0, t1) / length(cross(t0, t1));

    // float t = interpQuad(u, v);
    // float t = interpTri(u, v);
    float t = interpQuadratic(u, v);
    // float t = interpTriTip(u, v, 0.5f);

    vec3 p = (1.0f - t) * c0 + t * c1;

    gl_Position = camera.proj * camera.view * vec4(p, 1.0);

    pos = p;
    nor = n;
    uv = vec2(u, v);
}
