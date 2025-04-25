shader_type spatial;

render_mode blend_mix, cull_back, depth_prepass_alpha;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	//ALBEDO = vec3(0.0, 0.0, 0.0);

}

void light() {
	 ////Called for every pixel for every light affecting the material.
	 ////Uncomment to replace the default light processing function with this one.
	ALPHA = 1.0 - ATTENUATION;
}


//shader_type spatial;
//uniform vec3 shadow_color: source_color; //Color of the shadow
//uniform float shadow_opacity: hint_range(0, 1); //Opacity multiplier of the shadow
//uniform float shadow_max_opacity: hint_range(0, 1); //Maximum opacity of overlapping shadows
//
//void fragment() {
	//// simple single color albedo.
	//ALBEDO = shadow_color;
	//// start with 0 alpha so we can add multiple light shadows together in light()
	//ALPHA = 0.0;
//}
