@ctype mat4 mat44_t

@block uniforms
layout(binding=0) uniform vs_params {
    mat4 mvp;
};
@end

@vs vs_offscreen
@include_block uniforms

in vec4 in_pos;
in vec3 in_nrm;
out vec3 nrm;

void main() {
    gl_Position = mvp * in_pos;
    nrm = in_nrm;
}
@end

@fs fs_offscreen
in vec3 nrm;
out vec4 frag_color;

void main() {
    frag_color = vec4(nrm * 0.5 + 0.5, 1.0);
}
@end

@program offscreen vs_offscreen fs_offscreen

@vs vs_display
@include_block uniforms

in vec4 in_pos;
in vec2 in_uv;
out vec2 uv;

void main() {
    gl_Position = mvp * in_pos;
    uv = in_uv;
}
@end

@fs fs_display
layout(binding=0) uniform texture2D tex;
layout(binding=0) uniform sampler smp;

in vec2 uv;
out vec4 frag_color;

void main() {
    frag_color = texture(sampler2D(tex, smp), uv);
}
@end

@program display vs_display fs_display

