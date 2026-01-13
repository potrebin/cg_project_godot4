shader_type canvas_item;

uniform sampler2D screen_tex : hint_screen_texture;

uniform float strength : hint_range(0.0, 0.1) = 0.02;
uniform float speed : hint_range(0.0, 10.0) = 3.0;
uniform float frequency : hint_range(0.0, 200.0) = 30.0;

uniform float color_amount : hint_range(0.0, 0.5) = 1; // how strong the color noise is
uniform float noise_scale : hint_range(0.0, 2000.0) = 500.0; // size of speckles
uniform float noise_speed : hint_range(0.0, 20.0) = 6.0; // how fast it changes

float hash(vec2 p) {
    // cheap deterministic "random"
    return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453123);
}

void fragment() {
    vec2 uv = SCREEN_UV;

    // Motion distortion
    uv.x += sin(uv.y * frequency + TIME * speed) * strength;

    vec4 col = texture(screen_tex, uv);

    // Animated per-pixel RGB noise
    vec2 p = uv * noise_scale + vec2(TIME * noise_speed, -TIME * noise_speed * 0.7);
    float nr = hash(p + vec2(1.0, 0.0));
    float ng = hash(p + vec2(2.0, 0.0));
    float nb = hash(p + vec2(3.0, 0.0));
    vec3 noise_rgb = vec3(nr, ng, nb) - 0.5;

    col.rgb += noise_rgb * color_amount;

    COLOR = col;
}
