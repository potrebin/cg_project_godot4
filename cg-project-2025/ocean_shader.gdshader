shader_type spatial;

// ============================================
// SIMPLE REALISTIC OCEAN SHADER
// ============================================
// This shader creates realistic water using:
// 1. Sine waves for wave motion
// 2. Fresnel effect for realistic reflection
// 3. Specular highlights for moon reflection
// ============================================

// --------------------------------------------
// VARYING VARIABLES
// These pass data from vertex shader to fragment/light shader
// --------------------------------------------
varying vec3 vertex_position;  // World position of each vertex
varying float wave_y;          // Height of wave at this point

// ============================================
// WAVE PARAMETERS
// ============================================
// wave_speed: How fast waves move (0 = frozen, 1 = normal, 2 = fast)
uniform float wave_speed : hint_range(0.0, 3.0) = 0.8;

// wave_height: How tall the waves are (0 = flat, 1 = big waves)
uniform float wave_height : hint_range(0.0, 2.0) = 0.4;

// wave_scale: How spread out waves are (small = dense waves, large = wide waves)
uniform float wave_scale : hint_range(0.01, 0.5) = 0.08;

// ============================================
// WATER COLORS
// ============================================
// water_color: The main color of the water when looking down
uniform vec3 water_color : source_color = vec3(0.05, 0.15, 0.25);

// horizon_color: The color at the horizon (where water meets sky)
uniform vec3 horizon_color : source_color = vec3(0.02, 0.05, 0.1);

// ============================================
// FRESNEL EFFECT
// ============================================
// Fresnel makes water:
// - Transparent when looking straight down
// - Reflective when looking at an angle (toward horizon)
// This is how real water behaves!

// fresnel_strength: How reflective the horizon looks (higher = more mirror-like)
uniform float fresnel_strength : hint_range(1.0, 10.0) = 4.0;

// ============================================
// MOON REFLECTION
// ============================================
// reflection_brightness: How bright the moon reflection is
uniform float reflection_brightness : hint_range(0.0, 10.0) = 3.0;

// reflection_size: How focused the moon reflection is (higher = smaller/sharper)
uniform float reflection_size : hint_range(8.0, 256.0) = 50.0;

// moon_color: Color of the moonlight
uniform vec3 moon_color : source_color = vec3(1.0, 0.98, 0.9);

// ============================================
// MATERIAL
// ============================================
// water_opacity: How see-through the water is (0 = invisible, 1 = solid)
uniform float water_opacity : hint_range(0.5, 1.0) = 0.9;


// ============================================
// VERTEX SHADER
// ============================================
// This runs for every vertex (point) on the ocean mesh.
// We move vertices up and down to create waves.
void vertex() {
	// Save position for later use
	vertex_position = VERTEX;

	// Get the X and Z position (horizontal position on the ocean)
	float x = VERTEX.x;
	float z = VERTEX.z;

	// Create time variable for animation
	float t = TIME * wave_speed;

	// ----------------------------------------
	// CREATE WAVES AT DIFFERENT ANGLES
	// ----------------------------------------
	// The key to realistic waves: use DIFFERENT DIRECTIONS
	// Not aligned with X/Z axes - this removes the "straight line" look

	// Define wave directions using angles (in radians)
	// Each wave travels in a different direction
	vec2 dir1 = vec2(cos(0.4), sin(0.4));    // ~23 degrees
	vec2 dir2 = vec2(cos(2.2), sin(2.2));    // ~126 degrees
	vec2 dir3 = vec2(cos(4.1), sin(4.1));    // ~235 degrees
	vec2 dir4 = vec2(cos(5.5), sin(5.5));    // ~315 degrees
	vec2 dir5 = vec2(cos(1.3), sin(1.3));    // ~75 degrees

	// Position vector for dot product with directions
	vec2 pos = vec2(x, z);

	// Wave 1: Primary wave
	float wave1 = sin(dot(pos, dir1) * wave_scale + t) * wave_height;

	// Wave 2: Secondary wave, different direction and speed
	float wave2 = sin(dot(pos, dir2) * wave_scale * 1.3 + t * 1.1) * wave_height * 0.6;

	// Wave 3: Third wave, opposite-ish direction
	float wave3 = sin(dot(pos, dir3) * wave_scale * 0.8 + t * 0.9) * wave_height * 0.4;

	// Wave 4: Smaller detail wave
	float wave4 = sin(dot(pos, dir4) * wave_scale * 1.8 + t * 1.3) * wave_height * 0.25;

	// Wave 5: Fine detail wave
	float wave5 = sin(dot(pos, dir5) * wave_scale * 2.2 + t * 0.7) * wave_height * 0.15;

	// Add all waves together
	float total_wave = wave1 + wave2 + wave3 + wave4 + wave5;

	// Move the vertex up/down by the wave amount
	VERTEX.y += total_wave;

	// Save wave height for fragment shader
	wave_y = total_wave;

	// ----------------------------------------
	// CALCULATE NEW SURFACE NORMAL
	// ----------------------------------------
	// Normals determine how light bounces off the surface.
	// We calculate the derivative (slope) for each wave direction.

	// Derivative of each wave (using chain rule: cos * direction * scale)
	vec2 slope1 = dir1 * cos(dot(pos, dir1) * wave_scale + t) * wave_scale * wave_height;
	vec2 slope2 = dir2 * cos(dot(pos, dir2) * wave_scale * 1.3 + t * 1.1) * wave_scale * 1.3 * wave_height * 0.6;
	vec2 slope3 = dir3 * cos(dot(pos, dir3) * wave_scale * 0.8 + t * 0.9) * wave_scale * 0.8 * wave_height * 0.4;
	vec2 slope4 = dir4 * cos(dot(pos, dir4) * wave_scale * 1.8 + t * 1.3) * wave_scale * 1.8 * wave_height * 0.25;
	vec2 slope5 = dir5 * cos(dot(pos, dir5) * wave_scale * 2.2 + t * 0.7) * wave_scale * 2.2 * wave_height * 0.15;

	// Sum all slopes
	vec2 total_slope = slope1 + slope2 + slope3 + slope4 + slope5;

	// Create normal vector pointing perpendicular to the wave surface
	// slope.x affects the X component, slope.y affects the Z component
	NORMAL = normalize(vec3(-total_slope.x, 1.0, -total_slope.y));
}


// ============================================
// FRAGMENT SHADER
// ============================================
// This runs for every pixel on screen.
// We determine the final color of each pixel here.
void fragment() {
	// Get the view direction (which way the camera is looking)
	vec3 view_dir = normalize(VIEW);
	vec3 normal = normalize(NORMAL);

	// ----------------------------------------
	// FRESNEL CALCULATION
	// ----------------------------------------
	// Dot product tells us the angle between view and surface normal:
	// - Looking straight down: dot product = 1 (transparent)
	// - Looking at horizon: dot product = 0 (reflective)

	float view_angle = max(dot(normal, view_dir), 0.0);

	// Fresnel formula: more reflection at grazing angles
	// pow() makes the transition sharper
	float fresnel = pow(1.0 - view_angle, fresnel_strength);

	// ----------------------------------------
	// MIX WATER COLORS
	// ----------------------------------------
	// Blend between water_color (looking down) and horizon_color (looking away)
	vec3 final_color = mix(water_color, horizon_color, fresnel);

	// ----------------------------------------
	// OUTPUT
	// ----------------------------------------
	ALBEDO = final_color;          // Base color
	METALLIC = 0.0;                // Water is not metallic
	ROUGHNESS = 0.1;               // Low roughness = shiny/reflective
	SPECULAR = 0.5;                // Medium specular for reflections
	ALPHA = mix(water_opacity, 1.0, fresnel * 0.3);  // More opaque at horizon
}


// ============================================
// LIGHT SHADER
// ============================================
// This runs for each light affecting the water.
// We use it to create the moon reflection on the water.
void light() {
	// ----------------------------------------
	// CALCULATE SPECULAR HIGHLIGHT
	// ----------------------------------------
	// Specular = bright spot where light reflects directly into camera

	// Half-vector: direction halfway between light and view
	// This is where the surface would need to point to reflect light to camera
	vec3 half_vec = normalize(LIGHT + VIEW);

	// How much does the surface normal align with the half-vector?
	float alignment = max(dot(NORMAL, half_vec), 0.0);

	// Raise to a power to make the highlight smaller/sharper
	// Higher reflection_size = smaller, more focused highlight
	float specular = pow(alignment, reflection_size);

	// ----------------------------------------
	// ADD SHIMMER EFFECT
	// ----------------------------------------
	// Make the reflection sparkle by varying brightness over time and position
	float shimmer = sin(TIME * 2.0 + vertex_position.x * 0.5) * 0.15 + 0.85;
	specular *= shimmer;

	// ----------------------------------------
	// APPLY MOON REFLECTION
	// ----------------------------------------
	// Multiply by moon color and brightness, then add to specular light
	vec3 moon_reflection = moon_color * specular * reflection_brightness;
	SPECULAR_LIGHT += moon_reflection * ATTENUATION;

	// Add subtle diffuse lighting (so water isn't completely black)
	float diffuse = max(dot(NORMAL, LIGHT), 0.0);
	DIFFUSE_LIGHT += LIGHT_COLOR * diffuse * 0.1 * ATTENUATION;
}
