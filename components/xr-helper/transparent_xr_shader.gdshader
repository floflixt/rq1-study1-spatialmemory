shader_type spatial;

render_mode blend_mix, depth_draw_opaque, cull_back, shadow_to_opacity;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	ALBEDO = vec3(0.0, 0.0, 0.0);
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
