@ctype mat4 mat44_t

// shared data structures
@block common
struct particle {
    vec4 pos;
    vec4 vel;
};
@end

// compute-shader for initializing pseudo-random particle velocities
@cs cs_init
@include_block common

layout(binding=0) buffer cs_ssbo { particle prt[]; };
layout(local_size_x=64, local_size_y=1, local_size_z=1) in;

uint xorshift32(uint x) {
    x ^= x<<13;
    x ^= x>>17;
    x ^= x<<5;
    return x;
}

void main() {
    uint idx = gl_GlobalInvocationID.x;
    uint x = xorshift32(0x12345678 + idx);
    uint y = xorshift32(x);
    uint z = xorshift32(y);

    // Map idx to 3 letters: N, A, N
    // Use vel.xyz to store the target position for each particle
    const float letter_spacing = 1.4f;
    const float letter_width = 1.0f;
    const float jitter_scale = 0.02f;

    // Pseudo-random in [0,1)
    float ru = float(x & 0xFFFFu) / 65535.0f;
    float rv = float(y & 0xFFFFu) / 65535.0f;
    float rz = float(z & 0xFFFFu) / 65535.0f;

    // Choose which stroke within a letter (0,1,2)
    uint rsel = (x ^ y ^ z) % 3u;

    // Determine letter index 0..2
    uint letter_idx = (idx / 256u) % 3u; // ~256 particles per letter stroke group

    // Base local coordinates per letter in [0,1]
    float u = ru;
    float v = rv;

    // Snap (u,v) to letter strokes
    if (letter_idx == 0u || letter_idx == 2u) {
        // 'N' strokes: left vertical (u=0), right vertical (u=1), diagonal (v=u)
        if (rsel == 0u) {
            u = 0.0f;
            v = rv;
        } else if (rsel == 1u) {
            u = 1.0f;
            v = rv;
        } else {
            // diagonal from (0,0) to (1,1)
            u = ru;
            v = u;
        }
    } else {
        // 'A' strokes: left diag (from (0,0) to (0.5,1)), right diag (from (1,0) to (0.5,1)), crossbar (v=0.5)
        if (rsel == 0u) {
            // left diagonal: interpolate between (0,0) and (0.5,1)
            float t = ru;
            u = mix(0.0f, 0.5f, t);
            v = mix(0.0f, 1.0f, t);
        } else if (rsel == 1u) {
            // right diagonal: interpolate between (1,0) and (0.5,1)
            float t = ru;
            u = mix(1.0f, 0.5f, t);
            v = mix(0.0f, 1.0f, t);
        } else {
            // crossbar at v=0.5 across u in [0.2,0.8]
            u = mix(0.2f, 0.8f, ru);
            v = 0.5f;
        }
    }

    // Add small jitter to avoid perfectly thin lines
    u += (rz - 0.5f) * jitter_scale;
    v += (rv - 0.5f) * jitter_scale;

    // Position letter centers around x in [-letter_spacing, 0, +letter_spacing]
    float letter_offset_x = (float(int(letter_idx) - 1) * letter_spacing);

    // Map local [0,1] to letter size and world space
    vec3 target = vec3(letter_offset_x + (u - 0.5f) * letter_width,
                       (v - 0.5f) * letter_width,
                       (rz - 0.5f) * 0.05f);

    // Start particles slightly offset so they move into place
    vec3 start_pos = target + vec3((ru - 0.5f) * 0.5f, 0.8f + rv * 0.5f, (rz - 0.5f) * 0.5f);
    prt[idx].pos = vec4(start_pos, 0.0f);
    // Store target in vel.xyz, keep w unused
    prt[idx].vel = vec4(target, 0.0f);
}
@end
@program init cs_init

// compute-shader for updating particle positions
@cs cs_update
@include_block common

layout(binding=0) uniform cs_params {
    float dt;
    int num_particles;
};
layout(binding=0) buffer cs_ssbo { particle prt[]; };
layout(local_size_x=64, local_size_y=1, local_size_z=1) in;

void main() {
    uint idx = gl_GlobalInvocationID.x;
    if (idx >= num_particles) {
        return;
    }
    // Interpret vel.xyz as the per-particle target position
    vec3 target = prt[idx].vel.xyz;
    vec3 pos = prt[idx].pos.xyz;
    // Smoothly move towards target; speed scales with distance for quick settling
    vec3 delta = target - pos;
    float dist = max(length(delta), 1e-5f);
    float speed = clamp(dist * 6.0f, 0.5f, 20.0f);
    vec3 step = delta * min(1.0f, dt * speed);
    pos += step;
    prt[idx].pos = vec4(pos, 0.0f);
}
@end
@program update cs_update

// vertex- and fragment-shader for rendering the particles
@vs vs

layout(binding=0) uniform vs_params { mat4 mvp; };

in vec3 pos;
in vec4 color0;
in vec4 inst_pos;

out vec4 color;

void main() {
    vec4 pos = vec4(pos +  inst_pos.xyz, 1.0);
    gl_Position = mvp * pos;
    color = color0;
}
@end

@fs fs
in vec4 color;
out vec4 frag_color;
void main() {
    frag_color = color;
}
@end

@program display vs fs

