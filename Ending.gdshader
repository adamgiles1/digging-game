shader_type canvas_item;

uniform sampler2D noise: repeat_enable;
uniform sampler2D static_noise: repeat_enable;

uniform float speed = .05;
uniform float speed_y = .05;
uniform float speed_x = .02;

void fragment() {
	float time = TIME;
	vec2 shifted_uv = UV + time * speed;
	vec2 other_shifted_uv = UV + vec2(time * speed_x, time * speed_y);
	
	float moving_noise_val = texture(noise, shifted_uv).r;
	float moving_noise_other_val = texture(noise, other_shifted_uv).r;
	float static_noise_val = texture(static_noise, UV).r;
	
	float full_moving_noise = mix(moving_noise_val, moving_noise_other_val, .5);
	
	float result = mix(full_moving_noise, static_noise_val, .5);
	
	COLOR = vec4(vec3(result), 1.0);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
