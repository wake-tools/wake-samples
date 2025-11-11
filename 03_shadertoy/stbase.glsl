//------------------------------------------------------------------------------
//  Shadertoy base shader
//------------------------------------------------------------------------------

//--- vertex shader
@vs vs
in vec4 position;
//
out vec4 pos;
//
void main() {
   gl_Position = position;
   gl_Position.z = 0.5;
   pos = gl_Position;
}
@end


//--- fragment shader
@fs fs
layout(binding=0) uniform fs_params {
   vec4 iMouse;      // mouse pixel coords .xy: current (if MLB down), zw: click
   vec4 iResolution; // viewport resolution (in pixels)
   vec4 iSize;       // viewport offset (in pixels)
   float iTime;      // shader playback time (in seconds)
};
in vec4 pos;

out vec4 frag_color;

//!Shadertoy START
@include shadertoy.fs
//!Shadertoy END

void main() {
    vec2 fragCoord = (pos.xy*0.5+0.5) * iResolution.xy ;
    mainImage(frag_color, fragCoord);
}
@end

@program shadertoy vs fs

