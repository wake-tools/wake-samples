//------------------------------------------------------------------------------
//  shaders for mipmap-sapp sample
//------------------------------------------------------------------------------
@ctype mat4 mat44_t

@vs vs
layout(binding=0) uniform vs_params {
    mat4 mvp;
};

in vec4 pos;
in vec2 uv0;

out vec2 uv;

void main() {
    gl_Position = mvp * pos;
    uv = uv0;
}
@end

@fs fs
layout(binding=0) uniform texture2D tex;
layout(binding=0) uniform sampler smp;
in vec2 uv;
out vec4 frag_color;

void main() {
    frag_color = texture(sampler2D(tex, smp), uv);
}
@end

@program mipmap vs fs

