shader_type spatial;

uniform sampler2D grass_texture;
uniform sampler2D dirt_texture;

varying vec3 world_position;

void vertex() {
	world_position = (MODEL_MATRIX * vec4(VERTEX, 1.0)).xyz;
}

void fragment() {
	vec3 color;
	if (world_position.y < .01) {
		color = vec3(1.0, .5, 0.0);
	} else {
		color = vec3(0.0, 1.0, 0.0);
	}
	ALBEDO = color;
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
