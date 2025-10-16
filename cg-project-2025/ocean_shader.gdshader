shader_type spatial;

// Varying to pass vertex position to fragment/light shader
varying vec3 world_pos;

// Wave parameters
uniform float wave_speed : hint_range(0.0, 5.0) = 1.0;
uniform float wave_amplitude : hint_range(0.0, 2.0) = 0.3;
uniform float wave_frequency : hint_range(0.1, 5.0) = 1.0;

// Water appearance
uniform vec3 water_color : source_color = vec3(0.04, 0.12, 0.24); // Dark blue for nighttime
uniform vec3 deep_water_color : source_color = vec3(0.01, 0.05, 0.15); // Even darker for depth
uniform float roughness : hint_range(0.0, 1.0) = 0.3;
uniform float metallic : hint_range(0.0, 1.0) = 0.0;

// Normal map strength
uniform float normal_strength : hint_range(0.0, 2.0) = 1.0;

// Moon reflection parameters
uniform float reflection_strength : hint_range(0.0, 5.0) = 2.0;
uniform float reflection_sharpness : hint_range(1.0, 256.0) = 32.0;
uniform vec3 moon_color : source_color = vec3(1.0, 0.98, 0.9); // Warm white

void vertex() {
	// Store world position for use in fragment/light shader
	world_pos = VERTEX;

	// Create multiple overlapping sine waves for realistic ocean motion
	float wave1 = sin(VERTEX.x * wave_frequency + TIME * wave_speed) * wave_amplitude;
	float wave2 = cos(VERTEX.z * wave_frequency * 0.7 + TIME * wave_speed * 1.3) * wave_amplitude * 0.5;
	float wave3 = sin((VERTEX.x + VERTEX.z) * wave_frequency * 0.5 + TIME * wave_speed * 0.8) * wave_amplitude * 0.3;

	// Combine waves and apply to vertex height (Y)
	VERTEX.y += wave1 + wave2 + wave3;

	// Calculate wave normals for proper lighting
	// This creates surface normals that follow the wave shape
	float wave_dx = cos(VERTEX.x * wave_frequency + TIME * wave_speed) * wave_frequency * wave_amplitude;
	wave_dx += -sin((VERTEX.x + VERTEX.z) * wave_frequency * 0.5 + TIME * wave_speed * 0.8) * wave_frequency * 0.5 * wave_amplitude * 0.3;

	float wave_dz = -sin(VERTEX.z * wave_frequency * 0.7 + TIME * wave_speed * 1.3) * wave_frequency * 0.7 * wave_amplitude * 0.5;
	wave_dz += -sin((VERTEX.x + VERTEX.z) * wave_frequency * 0.5 + TIME * wave_speed * 0.8) * wave_frequency * 0.5 * wave_amplitude * 0.3;

	vec3 wave_normal = normalize(vec3(-wave_dx, 1.0, -wave_dz));
	NORMAL = mix(NORMAL, wave_normal, normal_strength);
}

void fragment() {
	// Base water color
	ALBEDO = water_color;

	// Water is not metallic
	METALLIC = metallic;

	// Moderate roughness for some specular highlights
	ROUGHNESS = roughness;

	// Slightly transparent for depth effect
	ALPHA = 0.95;
}

void light() {
	// Calculate moon reflection using Blinn-Phong specular model

	// Get the halfway vector between light direction and view direction
	vec3 half_vector = normalize(LIGHT + VIEW);

	// Calculate specular reflection based on surface normal
	float specular = pow(max(dot(NORMAL, half_vector), 0.0), reflection_sharpness);

	// Add some variation based on wave movement for shimmer effect
	float shimmer = sin(TIME * 2.0 + world_pos.x * 0.5) * 0.1 + 0.9;
	specular *= shimmer;

	// Apply moon color and strength to create the reflection
	vec3 moon_reflection = moon_color * specular * reflection_strength;

	// Add the reflection to the light contribution
	// This creates the bright streak of moonlight on the water
	DIFFUSE_LIGHT += moon_reflection;
}
