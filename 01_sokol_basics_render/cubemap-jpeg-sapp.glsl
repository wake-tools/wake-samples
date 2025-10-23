@ctype mat4 mat44_t

@vs vs
layout(binding=0) uniform vs_params {
    mat4 mvp;
};

in vec4 pos;
out vec3 uvw;

void main() {
    gl_Position = mvp * pos;
    uvw = normalize(pos.xyz);
}
@end

@fs fs
layout(binding=0) uniform textureCube tex;
layout(binding=0) uniform sampler smp;

in vec3 uvw;
out vec4 frag_color;

void main() {
    frag_color = texture(samplerCube(tex,smp), uvw);
}
@end

@program cubemap vs fs

