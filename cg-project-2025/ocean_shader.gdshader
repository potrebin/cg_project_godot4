shader_type spatial;

// ============================================
// UNIFORMS- adjustable in inspector
// ============================================

// Wave motion
uniform float wave_speed : hint_range(0.0, 5.0) = 1.0;
uniform float wave_amplitude : hint_range(0.0, 2.0) = 0.3;
uniform float wave_frequency : hint_range(0.1, 5.0) = 1.0;

// Water appearance
uniform vec3 water_color : source_color = vec3(0.04, 0.12, 0.24);
uniform float roughness : hint_range(0.0, 1.0) = 0.3;

// Moon reflection
uniform float reflection_strength : hint_range(0.0, 5.0) = 2.0;
uniform float reflection_sharpness : hint_range(1.0, 256.0) = 32.0;
uniform vec3 moon_color : source_color = vec3(1.0, 0.98, 0.9);

// ============================================
// VERTEX SHADER - Runs for each vertex
// ============================================
void vertex() {
	// Time for animation
	float t = TIME * wave_speed;

	// Wave 1: Travels along X-axis
	float wave1 = sin(VERTEX.x * wave_frequency + t) * wave_amplitude;

	// Wave 2: Travels along Z-axis, half the height
	float wave2 = sin(VERTEX.z * wave_frequency + t) * wave_amplitude * 0.5;

	// Move vertex up/down by combined wave height
	VERTEX.y += wave1 + wave2;

	// Calculate surface normal using derivatives
	// Derivative of sin(x) is cos(x)
	float slope_x = cos(VERTEX.x * wave_frequency + t) * wave_frequency * wave_amplitude;
	float slope_z = cos(VERTEX.z * wave_frequency + t) * wave_frequency * wave_amplitude * 0.5;

	// Normal points perpendicular to the sloped surface
	NORMAL = normalize(vec3(-slope_x, 1.0, -slope_z));
}

// ============================================
// FRAGMENT SHADER - Runs for each pixel
// ============================================
void fragment() {
	ALBEDO = water_color;
	ROUGHNESS = roughness;
	ALPHA = 0.95;
}

// ============================================
// LIGHT SHADER - Runs for each light
// ============================================
void light() {
	// Blinn-Phong reflection model
	// Half-vector: direction between light and camera
	vec3 half_vector = normalize(LIGHT + VIEW);

	// Specular: bright when surface normal aligns with half-vector
	float specular = pow(max(dot(NORMAL, half_vector), 0.0), reflection_sharpness);

	// Apply moon color and add to lighting
	DIFFUSE_LIGHT += moon_color * specular * reflection_strength;
}
